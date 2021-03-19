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

// Standard used: USB 3.1 Legacy Connector and Cable Specification
// https://xdevs.com/doc/Standards/USB%203.1/usb_31_030215/USB_3_1_r1.0.pdf
// See Figure 5-4

module usb_holder() {
  chip_thickness = 1.4;
  chip_length = 24.9;
  chip_width = 11.3;

  slot_thickness = 2.0;
  width = 12; // from standard

  dip_offset_x = 5.18; // from standard
  dip_offset_y = 3; // from standard
  dip_size_x = 2; // from standard
  dip_size_y = 2.45; // from standard

  length = 35;

  difference() {
    union() {
      // body
      cuboid(
        [length, width, slot_thickness],
        align = V_RIGHT + V_BOTTOM,
        fillet = width / 2 - e,
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
        translate([dip_offset_x, dip_offset_y, e])
        cuboid(
          [dip_size_x, dip_size_y, slot_thickness + 2 * e],
          align = V_RIGHT + V_BOTTOM
        );
      // screw hole
      translate([length - width / 2, 0, -slot_thickness])
        hole(thickness = slot_thickness);
    }
  }
}

usb_holder();
