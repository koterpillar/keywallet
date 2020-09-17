include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>

use <cutout.scad>
use <plate.scad>

$fa = 1;
$fs = 0.2;

module support(inset) {
  translate([support_x - plate_width / 2, 0, plate_thickness - e])
    cuboid(
      [support_width, plate_height / 2 - inset, support_thickness + e],
      align = V_RIGHT + V_FWD + V_UP,
      fillet = support_rounding,
      edges = EDGES_Z_FR
    );
}

module supports() {
  support(17);
  xflip() support(17);
  yflip() support(13);
  yflip() xflip() support(9.5);
}

module plate_cutout(width, depth) {
  translate([0, -plate_height / 2, 0])
    cutout(width, depth);
}

module cutouts() {
  width_1 = 25;
  depth_1 = 15;
  width_2 = 25;
  depth_2 = 7.5;

  plate_cutout(width_1, depth_1);
  yflip() plate_cutout(width_2, depth_2);
}

module asymmetry() {
  start_x = 10;
  depth = 1;
  interval = 4;
  rounding = 0.5;
  count = 3;

  xflip_copy()
    for (i = [0 : count - 1])
      translate([-plate_width / 2 + start_x + interval * i, -plate_height / 2, 0])
        cutout(interval / 2, depth, rounding = rounding);
}

module key_plate() {
  difference() {
    union () {
      plate();
      supports();
    }
    {
      cutouts();
      asymmetry();
    }
  }
}

key_plate();
