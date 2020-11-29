include <BOSL/constants.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

module xyflip_copy() {
  xflip_copy() yflip_copy() children();
}

module ycut() {
  intersection() {
    union() {
      children();
    }
    cuboid([1000, 1000, 1000], align = V_BACK);
  }
}
