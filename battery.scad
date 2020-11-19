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
switch_gap = 0.7;

battery_threshold = 0.1;
wall_thickness = 1.2;
wall_width = 6;
wall_rot = -5;

cap_thickness = 1;
cap_width = 3;

wire_thickness = 0.4;
wire_wall_gap = 0.6;
wire_trench_depth = wire_thickness;
wire_trench_width = 0.8;

diode_short_leg_length = 26;
diode_long_leg_length = 28;
diode_leg_inset = 0.7;
diode_head_w = 4.9;
diode_head_wall_thickness = 2;
diode_head_trench_length = 8.5;
diode_head_trench_width = 5;
diode_head_trench_depth = 0.4;

module battery(size, align = V_CENTER, threshold = 0) {
  zcyl(
    d = size[0] + 2 * threshold,
    h = size[1],
    align = align
  );
}

module wire_cutout(x, bottom, top, width, align = V_ZERO, gap = wire_wall_gap) {
  translate([x - align[0] * e, 0, bottom - e])
    cuboid(
      [width + 2 * e, gap, top - bottom + 2 * e],
      align = V_UP + align
    );
}

diode_x = diode_short_leg_length - switch_length_l;

module holder(size, battery = 0) {
  battery_d = size[0];
  battery_h = size[1];
  id = battery_d + battery_threshold;
  od = id + wall_thickness * 2;

  difference() {
    union() {
      // bottom pad
      difference() {
        zcyl(
          h = switch_gap,
          d = id,
          align = V_UP
        );
        // space for switch to flex
        translate([0, 0, switch_gap])
          switch_cutout(
            size,
            thickness = switch_gap,
            shell = 1
          );
      }
      // side wall
      translate([0, 0, -e])
        intersection() {
          tube(
            h = battery_h + switch_gap,
            id = id,
            od = od
          );
          zrot(wall_rot)
            cuboid(
              [infinity, wall_width, battery_h + switch_gap],
              align = V_UP
            );
        }
      // cap bridge
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
          [diode_head_wall_thickness, diode_head_w + wall_thickness, switch_gap + battery_h],
          align = V_LEFT + V_UP
        );
    }
    // battery
    translate([0, 0, switch_gap - e])
      battery(size, align = V_UP, threshold = battery_threshold);
    // wire cutout - battery wall, bottom
    wire_cutout(
      x = od / 2,
      bottom = 0,
      top = diode_leg_inset + wire_thickness,
      width = od / 2 - switch_length_r,
      align = V_LEFT
    );
    // wire cutout - battery wall and cover
    wire_cutout(
      x = id / 2 + wall_thickness,
      gap = wire_trench_width,
      bottom = switch_gap + battery_h / 2,
      top = switch_gap + battery_h + wire_trench_depth,
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
  }
}

module switch_cutout(size, thickness = plate_thickness, shell = 0) {
  battery_d = size[0];
  id = battery_d + battery_threshold;
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
  if (!shell) {
    translate([diode_x, 0, e])
      cuboid(
        [
          diode_head_trench_length,
          diode_head_trench_width,
          diode_head_trench_depth
        ],
        align = V_DOWN + V_RIGHT
      );
    wire_cutout(
      x = id / 2,
      gap = wire_trench_width,
      bottom = -wire_trench_depth,
      top = e,
      width = id / 2 + switch_length_l,
      align = V_LEFT
    );
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
    translate([12, 0, 0])
      cuboid(
        [40, 12, plate_thickness],
        align = V_DOWN,
        fillet = 5,
        edges = EDGES_Z_ALL
      );
  }
  switch_cutout(CR2032);
}

holder(CR2032);
