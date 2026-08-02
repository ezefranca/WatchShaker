#if os(watchOS)
  import CoreMotion
  import Foundation

  final class CoreMotionSource: @unchecked Sendable {
    typealias DetectionHandler = @Sendable (DetectedShake) -> Void
    typealias FailureHandler = @Sendable (WatchShakerError) -> Void

    static let shared = CoreMotionSource()

    private let manager = CMMotionManager()
    private let queue: OperationQueue = {
      let queue = OperationQueue()
      queue.name = "com.ezefranca.WatchShaker.motion"
      queue.maxConcurrentOperationCount = 1
      queue.qualityOfService = .userInitiated
      return queue
    }()
    private let lock = NSLock()

    private var detector = ShakeDetector(configuration: .init())
    private var gravityFilter = GravityRemovalFilter()
    private var didReportFailure = false
    private var activeOwner: UUID?

    private init() {}

    var isAvailable: Bool {
      manager.isDeviceMotionAvailable || manager.isAccelerometerAvailable
    }

    func start(
      owner: UUID,
      configuration: WatchShakerConfiguration,
      onDetection: @escaping DetectionHandler,
      onFailure: @escaping FailureHandler
    ) throws {
      guard isAvailable else { throw WatchShakerError.motionUnavailable }

      let acquiredOwnership = lock.withLock {
        guard activeOwner == nil else { return false }
        activeOwner = owner
        detector = ShakeDetector(configuration: configuration)
        gravityFilter = GravityRemovalFilter()
        didReportFailure = false
        return true
      }
      guard acquiredOwnership else { throw WatchShakerError.monitoringAlreadyActive }

      if manager.isDeviceMotionAvailable {
        manager.deviceMotionUpdateInterval = configuration.updateInterval
        manager.startDeviceMotionUpdates(
          using: .xArbitraryZVertical,
          to: queue
        ) { [weak self] motion, error in
          guard let self else { return }
          if let error {
            report(error, owner: owner, to: onFailure)
            return
          }
          guard let motion else { return }

          processUserAcceleration(
            MotionSample(
              acceleration: ShakeCoordinates(
                x: motion.userAcceleration.x,
                y: motion.userAcceleration.y,
                z: motion.userAcceleration.z
              ),
              timestamp: motion.timestamp
            ),
            owner: owner,
            onDetection: onDetection
          )
        }
      } else {
        manager.accelerometerUpdateInterval = configuration.updateInterval
        manager.startAccelerometerUpdates(to: queue) { [weak self] data, error in
          guard let self else { return }
          if let error {
            report(error, owner: owner, to: onFailure)
            return
          }
          guard let data else { return }

          let rawSample = MotionSample(
            acceleration: ShakeCoordinates(
              x: data.acceleration.x,
              y: data.acceleration.y,
              z: data.acceleration.z
            ),
            timestamp: data.timestamp
          )
          processRawAcceleration(
            rawSample,
            owner: owner,
            onDetection: onDetection
          )
        }
      }
    }

    func updateConfiguration(
      _ configuration: WatchShakerConfiguration,
      owner: UUID
    ) {
      let didUpdate = lock.withLock {
        guard activeOwner == owner else { return false }
        detector.updateConfiguration(configuration)
        return true
      }
      guard didUpdate else { return }
      manager.deviceMotionUpdateInterval = configuration.updateInterval
      manager.accelerometerUpdateInterval = configuration.updateInterval
    }

    func stop(owner: UUID) {
      let releasedOwnership = lock.withLock {
        guard activeOwner == owner else { return false }
        activeOwner = nil
        detector.reset()
        gravityFilter = GravityRemovalFilter()
        return true
      }
      guard releasedOwnership else { return }

      manager.stopDeviceMotionUpdates()
      manager.stopAccelerometerUpdates()
      queue.cancelAllOperations()
    }

    private func processUserAcceleration(
      _ sample: MotionSample,
      owner: UUID,
      onDetection: DetectionHandler
    ) {
      let detection: DetectedShake? = lock.withLock {
        guard activeOwner == owner else { return nil }
        return detector.process(sample)
      }
      if let detection {
        onDetection(detection)
      }
    }

    private func processRawAcceleration(
      _ sample: MotionSample,
      owner: UUID,
      onDetection: DetectionHandler
    ) {
      let detection: DetectedShake? = lock.withLock {
        guard activeOwner == owner else { return nil }
        let filtered = gravityFilter.process(sample)
        return detector.process(filtered)
      }
      if let detection {
        onDetection(detection)
      }
    }

    private func report(
      _ error: any Error,
      owner: UUID,
      to handler: FailureHandler
    ) {
      let shouldReport = lock.withLock {
        guard activeOwner == owner, !didReportFailure else { return false }
        didReportFailure = true
        return true
      }
      guard shouldReport else { return }
      handler(.motionFailure(error.localizedDescription))
    }
  }
#endif
