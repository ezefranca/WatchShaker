# Detection Model

Understand how WatchShaker turns noisy sensor samples into one stable event per gesture.

## Remove gravity

WatchShaker prefers `CMDeviceMotion.userAcceleration`, which removes gravity from raw acceleration. This prevents wrist angle and ordinary static orientation from looking like a shake. If processed device motion is unavailable, a low-pass gravity estimate is subtracted from raw accelerometer samples.

## Capture the gesture peak

When vector magnitude crosses the configured sensitivity threshold, the detector opens a short peak-capture window. The strongest sample in that window becomes ``Shake/acceleration``. Capturing the peak produces more stable direction and intensity than reporting whichever sample happened to cross the threshold first.

## Rearm with hysteresis

After an event, magnitude must fall below a lower release threshold and the cooldown must elapse before the detector rearms. This two-part rule prevents a single oscillating movement from producing a burst of events.

All timing decisions use Core Motion's monotonic sensor timestamp. Wall-clock changes therefore cannot skip or duplicate cooldown behavior.

## Classify direction

Direction is derived from the dominant x or y component of the peak acceleration. If neither axis dominates sufficiently—or z-axis movement dominates—the result is ``ShakeDirection/unknown``. This is deliberate: returning `unknown` is safer than presenting a confident but unstable direction.

Choose ``WatchShakerConfiguration/detection`` to tune the detector as a cohesive behavior instead of changing isolated constants. Applications with hardware measurements can supply a validated custom profile. Applications that need their own gesture vocabulary can classify ``Shake/acceleration`` directly.
