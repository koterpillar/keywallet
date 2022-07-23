include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>
include <keys.scad>
use <battery.scad>
use <cutout.scad>
use <plate.scad>

$fa = 1;
$fs = 0.2;

module support(key) {
  inset = key[KEY_SUPPORT_INSET];
  x = key[KEY_LENGTH] + hole_x;
  width = 2;
  length = 8;
  rounding = 1;

  assert(inset + length < plate_height / 2);

  y = plate_height / 2 - inset;

  translate([x - plate_width / 2, length - y, plate_thickness - e])
    cuboid(
      [width, length, key_max_thickness + e],
      align = V_RIGHT + V_FWD + V_UP,
      fillet = rounding,
      edges = EDGES_Z_ALL
    );
}

module supports() {
  support(key_L_D);
  xflip() support(key_R_D);
  yflip() support(key_L_U);
  yflip() xflip() support(key_R_U);
}

module pad(key) {
  width = hole_x * 2;
  chamfer = 1;

  xflip()
  yflip()
  translate([plate_width / 2 - hole_x, plate_height / 2 - hole_y(), plate_thickness - e])
    tube(
      h = key_max_thickness - key[KEY_THICKNESS],
      id = screw_d,
      od = width,
      od2 = width - chamfer,
      align = V_UP
    );
}

module pads() {
  pad(key_L_D);
  xflip() pad(key_R_D);
  yflip() pad(key_L_U);
  yflip() xflip() pad(key_R_U);
}

module plate_cutout(key1, key2) {
  length1 = key1[KEY_LENGTH];
  length2 = key2[KEY_LENGTH];

  key_space = plate_width - 2 * hole_x;
  width = key_space - length1 - length2;
  assert(width > 0, "Not enough space for keys");
  depth = max(key1[KEY_CUTOUT], key2[KEY_CUTOUT]);

  translate([(length1 - length2) / 2, -plate_height / 2, 0])
    cutout(width, depth);
}

module cutouts() {
  plate_cutout(key_L_D, key_R_D);
  yflip()
    plate_cutout(key_L_U, key_R_U);
}

module notches(key) {
  start_x = 10;
  depth = 1;
  interval = 4;
  rounding = 0.5;

  count = key[KEY_NOTCHES];

  if (count > 0)
    yflip()
    for (i = [0 : count - 1])
    translate([-plate_width / 2 + start_x + interval * i, -plate_height / 2, 0])
    cutout(interval / 2, depth, rounding = rounding);
}

module all_notches() {
  notches(key_L_D);
  xflip() notches(key_R_D);
  yflip() notches(key_L_U);
  yflip() xflip() notches(key_R_U);
}

module battery_attach() {
  translate([0, 0, plate_thickness])
    zrot(180)
    children();
}

module key_plate() {
  difference() {
    union() {
      plate();
      supports();
      pads();
      battery_attach()
        holder(CR2032, max_thickness = key_max_thickness);
    }
    {
      cutouts();
      all_notches();
      screw_cap_2_clearance();
      battery_attach()
        switch_cutout(CR2032);
    }
  }
  // enable to see screw caps
  *color("red", 0.5) screw_cap_2();
}

key_plate();
