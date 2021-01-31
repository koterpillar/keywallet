include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>

hole_spacing_y = 30;
function hole_spacing_y() = hole_spacing_y;

hole_y = (plate_height - hole_spacing_y) / 2;
function hole_y() = hole_y;

hole_spacing_x = plate_width - 2 * hole_x;
function hole_spacing_x() = hole_spacing_x;

module hole() {
  translate([0, 0, -e])
  zcyl(
    h = plate_thickness + 2 * e,
    d = screw_d + 0.8,
    align = V_TOP
  );
}

module at_holes() {
  xyflip_copy()
    translate([hole_spacing_x / 2, hole_spacing_y / 2, 0])
    children();
}

module holes() {
  at_holes()
    hole();
}

module screw_cap(height = screw_cap_h, threshold = 0) {
  side = screw_cap_side + 2 * threshold;
  at_holes()
    translate([0, 0, plate_thickness - screw_inset + e])
    cuboid(
      [side, side, height],
      align = V_TOP
    );
}

module screw_cap_2(height = screw_2_cap_h, threshold = 0) {
  at_holes()
    translate([0, 0, screw_2_inset - e])
    zcyl(
      d = screw_2_cap_d,
      h = height,
      align = V_BOTTOM
    );
}

module screw_cap_clearance() {
  screw_cap(height = 20, threshold = 0.3);
}

module screw_cap_2_clearance() {
  screw_cap_2(height = 20, threshold = 0.3);
}

rounding = 5;

module plate() {
  difference() {
    cuboid(
      [plate_width, plate_height, plate_thickness],
      align = V_UP,
      fillet = rounding,
      edges = EDGES_Z_ALL
    );
    holes();
  }
}
