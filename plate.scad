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
  zcyl(
    h = plate_thickness + 2 * e,
    d = screw_d,
    align = V_TOP
  );
}

module holes() {
  xyflip_copy()
    translate([hole_spacing_x / 2, hole_spacing_y / 2, -e])
    hole();
}

module screws() {
  xyflip_copy()
    translate([hole_spacing_x / 2, hole_spacing_y / 2, plate_thickness])
    color("red")
    cuboid(
      [screw_cap_side, screw_cap_side, screw_cap_h],
      align = V_TOP
    );
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
