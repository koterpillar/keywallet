use <BOSL/transforms.scad>

module xyflip_copy() {
  xflip_copy() yflip_copy() children();
}

