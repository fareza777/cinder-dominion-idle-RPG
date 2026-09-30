package com.cinderdominion.ads;

import android.app.Activity;
import android.graphics.Insets;
import android.os.Build;
import android.view.*;
import android.widget.FrameLayout;
import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.UsedByGodot;
import java.lang.ref.WeakReference;

/** Keeps the vendored SDK banner above persistent system navigation insets. */
public final class BannerSafe extends GodotPlugin implements ViewTreeObserver.OnPreDrawListener {
    private View decor;
    private WeakReference<View> banner = new WeakReference<>(null);
    private long nextSearch;
    private volatile int bottomMarginPixels = -1;
    private final int[] origin = new int[2];
    private final int[] parentOrigin = new int[2];
    public BannerSafe(Godot godot) { super(godot); }
    @Override public String getPluginName() { return "BannerSafe"; }
    @Override public View onMainCreate(Activity activity) {
        decor = activity.getWindow().getDecorView();
        decor.getViewTreeObserver().addOnPreDrawListener(this);
        return null;
    }
    @Override public void onMainDestroy() {
        if (decor != null && decor.getViewTreeObserver().isAlive())
            decor.getViewTreeObserver().removeOnPreDrawListener(this);
        decor = null; banner.clear(); bottomMarginPixels = -1;
    }
    @UsedByGodot public int get_bottom_margin_pixels() { return bottomMarginPixels; }
    private View findBanner(View view) {
        if (view.getClass().getName().equals("com.google.android.libraries.ads.mobile.sdk.banner.AdView")) return view;
        if (view instanceof ViewGroup) {
            ViewGroup group = (ViewGroup)view;
            for (int i=0;i<group.getChildCount();i++) {
                View found = findBanner(group.getChildAt(i));
                if (found != null) return found;
            }
        }
        return null;
    }
    @Override public boolean onPreDraw() {
        if (decor == null) return true;
        View ad = banner.get();
        if (ad == null || !ad.isAttachedToWindow()) {
            bottomMarginPixels = -1;
            long now = android.os.SystemClock.uptimeMillis();
            if (now < nextSearch) return true;
            nextSearch = now + 250;
            ad = findBanner(decor); banner = new WeakReference<>(ad);
        }
        if (ad == null || !(ad.getParent() instanceof View) || !(ad.getLayoutParams() instanceof FrameLayout.LayoutParams)) return true;
        WindowInsets wi = decor.getRootWindowInsets();
        if (wi == null) return true;
        int bottom, left, right;
        if (Build.VERSION.SDK_INT >= 30) {
            Insets stable = wi.getInsetsIgnoringVisibility(WindowInsets.Type.navigationBars() | WindowInsets.Type.displayCutout());
            Insets gestures = wi.getInsets(WindowInsets.Type.mandatorySystemGestures());
            bottom=Math.max(stable.bottom, gestures.bottom); left=stable.left; right=stable.right;
        } else {
            bottom=wi.getStableInsetBottom(); left=wi.getStableInsetLeft(); right=wi.getStableInsetRight();
            if (Build.VERSION.SDK_INT >= 28 && wi.getDisplayCutout()!=null) {
                bottom=Math.max(bottom,wi.getDisplayCutout().getSafeInsetBottom());
                left=Math.max(left,wi.getDisplayCutout().getSafeInsetLeft());
                right=Math.max(right,wi.getDisplayCutout().getSafeInsetRight());
            }
        }
        int gap=Math.round(8*decor.getResources().getDisplayMetrics().density);
        View parent=(View)ad.getParent();
        decor.getLocationOnScreen(origin); parent.getLocationOnScreen(parentOrigin);
        // Subtract insets already consumed by the parent; never double-inset fitted windows.
        int bm=BannerInsets.bottomMargin(parentOrigin[1]+parent.getHeight(),origin[1]+decor.getHeight(),bottom,gap);
        int lm=Math.max(0,origin[0]+left-parentOrigin[0]);
        int rm=Math.max(0,parentOrigin[0]+parent.getWidth()-(origin[0]+decor.getWidth()-right));
        FrameLayout.LayoutParams lp=(FrameLayout.LayoutParams)ad.getLayoutParams();
        bottomMarginPixels=bm;
        int gravity=Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL;
        if(lp.bottomMargin!=bm || lp.leftMargin!=lm || lp.rightMargin!=rm || lp.topMargin!=0 || lp.gravity!=gravity) {
            lp.bottomMargin=bm;lp.leftMargin=lm;lp.rightMargin=rm;lp.topMargin=0;lp.gravity=gravity;
            ad.setLayoutParams(lp);
            return false; // Apply the safe layout before this banner can be drawn.
        }
        return true;
    }
}
