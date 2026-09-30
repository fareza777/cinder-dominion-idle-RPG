package com.cinderdominion.ads;
final class BannerInsets {
 static int bottomMargin(int parentBottom,int windowBottom,int inset,int gap) {
  return Math.max(0,parentBottom-(windowBottom-inset))+gap;
 }
}
