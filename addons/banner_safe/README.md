# Android banner navigation clearance

Small project-owned Godot v2 Android plugin for the vendored Poing5.1.0 / Google Ads Mobile SDK1.4.0 banner. It does not request ads or change their contents.

The vendor positions BOTTOM using Godot's safe rectangle. That rectangle alone can omit transient/hidden Android navigation insets. This bridge reads Android WindowInsets ignoring navigation-bar visibility (API30+), mandatory gesture space and cutouts; API24–29 uses stable insets. It applies an8dp gap above system navigation, correcting margins before drawing. Parent offsets avoid double-counting insets already consumed by fitted windows. Resize/resume/inset changes are recalculated on pre-draw; layout parameters mutate only when changed. Tree searches are cached and throttled to250ms while waiting for a newly created banner.

Godot waits for the bridge before showing the banner and reserves its measured height plus corrected clearance, subtracting shell safe-area padding already present. The existing14 logical-pixel separation from game buttons remains. Missing bridge fails closed (banner hidden). No SDK binary was modified.

Rebuild after native-source changes:

```
python tools/build_banner_safe.py --jdk <JDK17-root> --sdk <Android-SDK-root>
```

Requires matching Godot4.7.1 Android template installed under android/build and Android platform36. Committed banner-safe.aar is built from the two Java sources; build tool compiles in a fresh temporary directory so test classes are never included. APK export merges its manifest automatically via plugin.gd.

Source: https://developer.android.com/reference/android/view/WindowInsets#getInsetsIgnoringVisibility(int)

The SDK banner class name and FrameLayout parent are deliberately version-specific. Reverify if upgrading AdMob. No physical-device validation was available during0.55.1; device navigation modes must still be checked.
