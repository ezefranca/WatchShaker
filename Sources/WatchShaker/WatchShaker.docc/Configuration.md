# Configuration

Choose meaningful detector behavior without exposing implementation constants at every call site.

## Start balanced

The default configuration is the recommended starting point:

```swift
let shaker = WatchShaker()
```

Its expanded form contains only semantic choices:

```swift
let configuration = WatchShakerConfiguration(
    sensitivity: .normal,
    sampling: .balanced,
    detection: .balanced
)
```

## Choose sensitivity

Sensitivity controls the acceleration required to begin a candidate gesture. From gentlest to strongest, the choices are `.veryHigh`, `.high`, `.normal`, `.low`, and `.veryLow`.

Start with `.normal`. Increase sensitivity only when deliberate shakes are missed, and decrease it when ordinary wrist movement crosses the threshold.

## Choose sampling

Sampling controls how often WatchShaker asks Core Motion for data:

| Choice | Requested rate | Use when |
| --- | ---: | --- |
| `.lowPower` | 25 Hz | Reaction time is less important than energy use. |
| `.balanced` | 50 Hz | General-purpose shake recognition. |
| `.responsive` | 100 Hz | A measured interaction requires the shortest sampling interval. |

Core Motion may adjust the delivered rate. A higher requested rate also increases processing and energy cost.

## Choose detection behavior

A detection profile keeps peak capture, hysteresis, cooldown, and direction classification coherent:

| Choice | Behavior |
| --- | --- |
| `.responsive` | Shorter peak capture and faster rearming. |
| `.balanced` | General-purpose timing and duplicate suppression. |
| `.conservative` | Stronger release and directional-dominance requirements. |

Sensitivity and detection behavior are independent. For example, `.high` sensitivity with `.conservative` detection recognizes gentler motion while still suppressing ambiguous repeats.

## Use custom tuning deliberately

Custom values are available as progressive disclosure. Construction throws if a value is outside the detector's safe operating range, and the resulting values are immutable:

```swift
let sampling = try WatchShakerConfiguration.SamplingRate.custom(hertz: 60)
let detection = try WatchShakerConfiguration.DetectionProfile.custom(
    cooldown: 0.25,
    peakCaptureDuration: 0.08,
    releaseThresholdRatio: 0.55,
    directionDominance: 1.15
)

let configuration = WatchShakerConfiguration(
    sensitivity: .high,
    sampling: sampling,
    detection: detection
)
```

Custom timing uses seconds because Core Motion timestamps and update intervals use seconds. Keep custom tuning in a feature-level configuration boundary instead of scattering numeric constants through views.

> Important: Record false-positive and missed-gesture results on physical Apple Watch hardware before replacing a preset. Simulator tests can verify state transitions, but they cannot validate human motion or energy behavior.
