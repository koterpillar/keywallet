include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>

$fa = 1;
$fs = 0.2;

switch_cut = 1;
switch_length_l = 4;
switch_length_r = 9;
switch_width = 6;
switch_gap = 2;

battery_threshold = 0.1;
wall_thickness = 2;
bed_inset_r = 2;

cap_thickness = 1;
cap_width = 0.5;
cap_count = 3;

wire_outer_length = 5;
wire_thickness = 0.5;

module battery(size, align = V_CENTER) {
  zcyl(
    d = size[0],
    h = size[1],
    align = align
  );
}

module holder(size, battery = 0) {
  od = size[0] + battery_threshold + wall_thickness;
  difference() {
    union() {
      difference() {
        // bottom pad
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
          h = size[1],
          id = od - wall_thickness,
          od = od
        );
      // cap holder
      translate([0, 0, switch_gap + size[1] - e])
        intersection() {
          zcyl(
            h = cap_thickness,
            d = od,
            align = V_UP
          );
          union() {
            tube(
              h = cap_thickness,
              id = od - wall_thickness,
              od = od,
              align = V_UP
            );
            for(cap_angle = [0 : 360 / cap_count : 360])
              zrot(cap_angle)
              translate([-size[0] / 2 + cap_width, 0, 0])
              cuboid(
                [100, od, cap_thickness],
                align = V_LEFT + V_UP
              );
          }
        }
    }
    // wire cutout
    translate([0, 0, -e])
    cuboid(
      [
        size[0] / 2 + wall_thickness + wire_outer_length,
        wire_thickness,
        size[1] + switch_gap + wire_thickness + 2 * e
      ],
      align = V_RIGHT + V_UP
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
  cuboid(
    [40, 40, plate_thickness],
    align = V_DOWN
  );
  switch_cutout();
}

holder(CR2032);
