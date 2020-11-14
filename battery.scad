include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>

$fa = 1;
$fs = 0.2;

switch_cut = 1.6;
switch_length_l = 4;
switch_length_r = 9;
switch_width = 6;
switch_gap = 1;

battery_threshold = 0.1;
wall_thickness = 0.6;
bed_inset_r = 2;

cap_thickness = 0.8;
cap_width = 5;

wire_outer_length = 5;
wire_thickness = 0.4;
wire_wall_gap = 0.6;

pick_cut_angle = 160;

diode_short_leg_length = 26;
diode_long_leg_length = 28;
diode_leg_inset = 0.7;
diode_head_w = 4.9;
diode_head_wall_thickness = 2;

module battery(size, align = V_CENTER) {
  zcyl(
    d = size[0],
    h = size[1],
    align = align
  );
}

module holder(size, battery = 0) {
  battery_d = size[0];
  battery_h = size[1];
  id = battery_d + battery_threshold;
  od = id + wall_thickness * 2;
  diode_x = diode_short_leg_length - switch_length_l;

  module wire_cutout(x, bottom, top, width = 8, align = V_ZERO) {
    translate([x - align[0] * e, 0, bottom - e])
      cuboid(
        [width + 2 * e, wire_wall_gap, top - bottom + 2 * e],
        align = V_UP + align
      );
  }

  difference() {
    union() {
      // bottom pad
      difference() {
        zcyl(
          h = switch_gap,
          d = od,
          align = V_UP
        );
        // space for switch to flex
        translate([0, 0, switch_gap])
          switch_cutout(
            thickness = switch_gap,
            shell = 1
          );
      }
      // main part of side wall
      translate([0, 0, switch_gap - e])
        tube(
          h = battery_h,
          id = id,
          od = od
        );
      // cap holder
      translate([0, 0, switch_gap + battery_h - e])
        intersection() {
          zcyl(
            h = cap_thickness,
            d = od,
            align = V_UP
          );
          cuboid(
            [infinity, cap_width, cap_thickness],
            align = V_UP
          );
        }
      // diode holder - wire side
      translate([diode_x, 0, -e])
        cuboid(
          [diode_head_wall_thickness, diode_head_w + 2 * wall_thickness, switch_gap + battery_h],
          align = V_LEFT + V_UP
        );
    }
    // wire cutout - battery wall, bottom
    wire_cutout(
      x = id / 2,
      bottom = 0,
      top = diode_leg_inset + wire_thickness
    );
    // wire cutout - battery wall and cover
    wire_cutout(
      x = id / 2 + wall_thickness,
      bottom = switch_gap + battery_h / 2,
      top = switch_gap + battery_h + wire_thickness / 3,
      width = wall_thickness + id - 8 * e,
      align = V_LEFT
    );
    // wire cutout - diode holder
    wire_cutout(
      x = diode_x,
      bottom = 0,
      top = infinity,
      width = diode_head_wall_thickness,
      align = V_LEFT
    );
    // cutouts to insert the battery
    sz1 = cap_width / 2 + e;
    sz2 = od / 2 + e;
    tn = tan(pick_cut_angle / 2);
    translate([0, 0, switch_gap + e])
      yflip_copy()
      translate([0, sz1, 0])
      prismoid(
        size1 = [sz1 * tn, infinity],
        size2 = [sz2 * tn, infinity],
        h = sz2 - sz1,
        orient = ORIENT_Y,
        align = V_BACK + V_UP
      );
  }
}

module switch_cutout(thickness = plate_thickness, shell = 0) {
  thickness = thickness + 2 * e;
  module s(width, ee = 0) {
    translate([-switch_length_l, 0, -ee]) {
      zcyl(
        h = thickness + 2 * ee,
        d = width,
        align = V_DOWN
      );
      cuboid(
        [switch_length_l + switch_length_r, width, thickness + 2 * ee],
        align = V_DOWN + V_RIGHT
      );
    }
  }
  translate([0, 0, e]) {
    difference() {
      s(switch_width + switch_cut);
      if (!shell) { s(switch_width, e); }
    }
  }
}

difference() {
  union() {
  cuboid(
    [25, 25, plate_thickness],
    align = V_DOWN,
    fillet = 10,
    edges = EDGES_Z_ALL
  );
  translate([10, 0, 0])
  cuboid(
    [40, 12, plate_thickness],
    align = V_DOWN,
    fillet = 5,
    edges = EDGES_Z_ALL
  );
  }
  switch_cutout();
}

holder(CR2032);
