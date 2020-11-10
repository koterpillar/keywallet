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
switch_gap = 2;

battery_threshold = 0.1;
wall_thickness = 0.6;
bed_inset_r = 2;

cap_thickness = 0.6;
cap_width = 0.5;
cap_angle = 30;

wire_outer_length = 5;
wire_thickness = 0.8;

pick_cut_angle = 60;
pick_cut_width = 6;

diode_leg_length = 26;
diode_leg_inset = 0.7;
diode_head_w = 4.9;
diode_holder_x = 2;
diode_holder_w = 2;

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
  diode_x = diode_leg_length - switch_length_l;
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
          union() {
            tube(
              h = cap_thickness,
              id = id,
              od = od,
              align = V_UP
            );
            xflip_copy()
              zrot(cap_angle)
              translate([-battery_d / 2 + cap_width, 0, 0])
              cuboid(
                [infinity, od, cap_thickness],
                align = V_LEFT + V_UP
              );
          }
        }
      // diode holder - wire side
      translate([diode_x - e, 0, -e])
        cuboid(
          [wall_thickness, diode_head_w + 2 * wall_thickness, switch_gap + battery_h],
          align = V_LEFT + V_UP
        );
      // diode holder - sides
      yflip_copy()
        translate([diode_x + diode_holder_x, diode_head_w / 2, -e])
        cuboid(
          [diode_holder_w, wall_thickness, switch_gap + battery_h],
          align = V_RIGHT + V_FWD + V_UP
        );
    }
    // wire cutout
    translate([diode_x, 0, -e]) {
      // bottom
      cuboid(
        [
          diode_leg_length,
          wire_thickness,
          wire_thickness + diode_leg_inset + 2 * e
        ],
        align = V_LEFT + V_UP
      );
      // top
      translate([0, 0, switch_gap + 2 * e])
      cuboid(
        [
          diode_leg_length,
          wire_thickness,
          battery_h + wire_thickness
        ],
        align = V_LEFT + V_UP
      );
    }
    // cutout to pick the battery out
    translate([0, 0, switch_gap + e])
    zrot(pick_cut_angle)
      cuboid(
        [pick_cut_width, infinity, infinity],
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
  translate([10, 0, 0])
  cuboid(
    [45, 25, plate_thickness],
    align = V_DOWN,
    fillet = 5,
    edges = EDGES_Z_ALL
  );
  switch_cutout();
}

holder(CR2032);
