include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>

use <plate.scad>

$fa = 1;
$fs = 0.2;

module usb_holder() {
  chip_thickness = 1.4;
  chip_length = 24.9;
  chip_width = 11.3;

  slot_thickness = 2.0;
  slot_width = 11.9;
  slot_depth = 12.5;

  length = 35;

  difference() {
    union() {
      // body
      cuboid(
        [length, slot_width, slot_thickness],
        align = V_RIGHT + V_BOTTOM,
        fillet = slot_width / 2 - e,
        edges = EDGES_Z_RT
      );
    }
    union() {
      // chip
      translate([-e, 0, e])
      cuboid(
        [chip_length, chip_width, chip_thickness],
        align = V_RIGHT + V_BOTTOM
      );
      // usb fit holes
      yflip_copy()
        translate([5.2, 1.7, e])
        cuboid(
          [1.8, 2.2, slot_thickness + 2 * e],
          align = V_RIGHT + V_BACK + V_BOTTOM
        );
      // screw hole
      translate([length - slot_width / 2, 0, -slot_thickness])
        hole(thickness = slot_thickness);
    }
  }
}

usb_holder();
