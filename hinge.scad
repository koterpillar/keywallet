include <BOSL/constants.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>

$fa = 1;
$fs = 0.2;

threshold = 0.3;

side_width = 1;
middle_width = 1.5;

function hinge_middle_width() = middle_width;

axis_d = 2;
axis_r = axis_d / 2;

hinge_wall = 0.5;

hole_r = axis_r + threshold;
hole_d = hole_r * 2;

hinge_r = hole_r + hinge_wall;
hinge_d = hinge_r * 2;

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
      h = h + axis_r,
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
  xrot(rotation)
  difference() {
    yflip()
    hinge_support(
      h = h + hole_d / 2 + hinge_wall,
      thickness = middle_width,
      d = hole_d + hinge_wall * 2
    );
    cyl(
      orient = ORIENT_X,
      l = middle_width + 2 * e,
      d = hole_d
    );
  }
}

function hinge_offset_y_min() = hinge_r;

function hinge_offset_y_max(h) = hinge_r * sin(slant_angle) + (h + hinge_r * cos(slant_angle)) / tan(slant_angle);

function hinge_offset_x(wall = true) = slot_width / 2 + (wall ? side_width : 0);

module hinge_attach(hinge_origin, hinge_h, target_x, target_z) {
  hinge_x = hinge_origin[0];
  hinge_y = hinge_origin[1];
  hinge_z = hinge_origin[2];
  arm_x = hinge_x - hinge_middle_width() / 2;
  arm_y1 = hinge_y - hinge_offset_y_min();
  arm_y2 = hinge_y + hinge_offset_y_max(hinge_h);
  arm_z = hinge_z + hinge_h;
  translate([arm_x, arm_y1, arm_z - e])
    cuboid(
      [
        target_x - arm_x + e,
        arm_y2 - arm_y1,
        target_z - arm_z + e
      ],
      align = V_ALLPOS
    );
}

module hinge_test() {
  plate_width = 40;
  plate_height = 10;
  plate_thickness = 1.2;
  spacing = 4.5;
  hinge_axis_x = hinge_offset_x() - plate_width / 2;
  hinge_axis_y = hinge_offset_y_min() - plate_height / 2;
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
