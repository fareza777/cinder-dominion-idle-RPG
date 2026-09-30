package com.cinderdominion.ads;
public final class BannerInsetsTest {
 public static void main(String[] args) {
  int[][] cases={{2400,2400,144,24,168},{2400,2400,72,24,96},{2256,2400,144,24,24},{2352,2400,144,24,120},{1600,1600,0,16,16},{1200,1200,60,16,76}};
  for(int[] c:cases) if(BannerInsets.bottomMargin(c[0],c[1],c[2],c[3])!=c[4]) throw new AssertionError();
  System.out.println("BANNER INSETS: 6 cases passed (buttons, gesture, fitted/part-fitted window, zero inset, resized window)");
 }
}
