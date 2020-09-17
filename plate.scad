include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>

hole_x = 5;
hole_radius = 2.15;
hole_spacing_y = 30;
hole_y = (plate_height - hole_spacing_y) / 2;
hole_spacing_x = plate_width - 2 * hole_x;

function hole_x() = hole_x;
function hole_spacing_y() = hole_spacing_y;

module hole(radius = hole_radius) {
  zcyl(
    h = plate_thickness + 2 * e,
    r = radius,
    align = V_TOP
  );
}

module holes() {
  xyflip_copy()
    translate([hole_spacing_x / 2, hole_spacing_y / 2, -e])
    hole();
}

screw_diameter = 9.4;

module screws() {
  xyflip_copy()
    translate([hole_spacing_x / 2, hole_spacing_y / 2, plate_thickness])
    color("red")
    zcyl(
      h = plate_thickness + 2 * e,
      d = screw_diameter,
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
