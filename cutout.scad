include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
include <constants.scad>

module cutout(width = undef, depth, base_width = undef, rounding = cutout_rounding, thickness = plate_thickness, center = false, mask = true) {
  slant = slant(depth);
  fillet_angle = 180 - slant_angle;
  width_ = is_undef(width) ? base_width - 2 * slant - 2 * rounding / tan(fillet_angle / 2) : width;
  thickness_ = mask ? thickness + 2 * e : thickness;
  translate([0, mask ? -e : 0, center ? 0 : thickness / 2]) {
    difference() {
      prismoid(
        size1 = [width_ + 2 * slant, thickness_],
        size2 = [width_, thickness_],
        h = depth + (mask ? 2 * e : 0),
        orient = ORIENT_Y
      );
      xflip_copy()
      translate([-width_ / 2, depth, 0])
        fillet_angled_edge_mask(
          h = thickness_ + 2 * e,
          r = rounding,
          ang = 180 - slant_angle
        );
    }
    xflip_copy()
    translate([width_ / 2 + slant, 0, 0])
      fillet_angled_edge_mask(
        h = thickness_,
        r = rounding,
        ang = 180 - slant_angle
      );
  }
}
