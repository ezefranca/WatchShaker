import Foundation

public struct Shake: Equatable {
    public let sensibility: ShakeSensibility
    public let direction: ShakeDirection
    public let time: Date
    
    public static func == (lhs: Shake, rhs: Shake) -> Bool {
        lhs.direction == rhs.direction && lhs.sensibility == rhs.sensibility && lhs.time == rhs.time
    }
}
