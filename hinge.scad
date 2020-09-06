include <BOSL/constants.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>

$fa = 1;
$fs = 0.2;

threshold = 0.3;

side_width = 1;
middle_width = 1.5;

axis_d = 2;

hinge_wall = 0.5;

slant_angle = 60;

slot_width = threshold * 2 + middle_width;

module hinge_support_slant(h, thickness, d, a = slant_angle, w = undef) {
  module tr() {
    if (a > 0) children(); else yflip() children();
  }
  r = d / 2;
  t_h = (h - r) + r * cos(a);
  t_w = t_h / tan(a);
  intersection() {
    translate([0, r * sin(a), -(h - r) - e])
      tr()
      right_triangle(
        [thickness, abs(t_w), t_h + e],
        orient = ORIENT_X,
        align = V_UP + V_BACK
      );
    if (!is_undef(w)) {
      tr()
        translate([0, 0, -(h - r) - e])
        cuboid(
          [thickness, r + w, t_h + e],
          align = V_UP + V_BACK
        );
    }
  }
}

module hinge_support(h, thickness, d, a = slant_angle, opposite_w = undef) {
  r = d / 2;
  cuboid(
    [thickness, d, h - r + e],
    align = V_DOWN
  );
  cyl(
    orient = ORIENT_X,
    l = thickness,
    d = d
  );
  hinge_support_slant(h = h, thickness = thickness, d = d, a = a);
  if (!is_undef(opposite_w)) {
    hinge_support_slant(h = h, thickness = thickness, d = d, a = -a, w = opposite_w);
  }
}

module hinge_base(h, left_wall = true, right_wall = true) {
  module support() {
    hinge_support(
      h = h + axis_d / 2,
      thickness = side_width,
      d = axis_d,
      opposite_w = threshold + hinge_wall
    );
  }
  cyl(
    orient = ORIENT_X,
    l = slot_width + 2 * e,
    d = axis_d
  );
  support_offset = (slot_width + side_width) / 2;
  if (left_wall)
    translate([-support_offset, 0, 0])
      support();
  if (right_wall)
    translate([support_offset, 0, 0])
      support();
}

module hinge(h, rotation = 0) {
  outer_d = axis_d + 2 * threshold;
  xrot(rotation)
  difference() {
    yflip()
    hinge_support(
      h = h + outer_d / 2 + hinge_wall,
      thickness = middle_width,
      d = outer_d + hinge_wall * 2
    );
    cyl(
      orient = ORIENT_X,
      l = middle_width + 2 * e,
      d = outer_d
    );
  }
}

function hinge_offset_y() = hinge_wall + threshold + axis_d / 2;

function hinge_offset_x(wall = true) = slot_width / 2 + (wall ? side_width : 0);

module hinge_test() {
  plate_width = 40;
  plate_height = 10;
  plate_thickness = 1.2;
  spacing = 4.5;
  hinge_axis_x = hinge_offset_x() - plate_width / 2;
  hinge_axis_y = hinge_offset_y() - plate_height / 2;
  hinge_axis_z = spacing / 2;
  module plate() {
    cuboid(
      [plate_width, plate_height, plate_thickness],
      align = V_UP
    );
  }
  module bottom_part() {
    plate();
    translate([0, 0, plate_thickness])
      xflip_copy()
        translate([hinge_axis_x, hinge_axis_y, hinge_axis_z])
          hinge_base(
            h = hinge_axis_z
          );
  }
  module top_part(rot) {
    translate([0, 0, plate_thickness]) {
      xflip_copy()
        translate([hinge_axis_x, hinge_axis_y, hinge_axis_z])
          hinge(
            h = spacing - hinge_axis_z,
            rotation = 180 + rot
          );
      translate([0, hinge_axis_y, hinge_axis_z])
      xrot(rot)
      translate([0, 0, spacing])
      translate([0, -hinge_axis_y, -hinge_axis_z])
        plate();
    }
  }
  union() {
    bottom_part();
    top_part(rot = 0);
  }
}

hinge_test();
