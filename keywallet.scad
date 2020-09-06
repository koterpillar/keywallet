include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

$fa = 1;
$fs = 0.2;

e = 0.001;

// ISO/IEC_7810 ID-1
card_thickness = 0.76;
card_width = 85.60;
card_height = 53.98;

card_count = 3;

card_tolerance = 0.2;
card_tolerance_z = card_tolerance;

cards_thickness = 3.4;

card_wall = 1.5;

plate_width = 105;
plate_height = card_height + 2 * card_wall + 2 * card_tolerance;
plate_thickness = 1.2;
plate_rounding = 5;

slant_angle = 70;
cutout_rounding = 3;

plate_border = 5;
thin_thickness = 0.6;
thin_chamfer = 2;

module xyflip_copy() {
  xflip_copy() yflip_copy() children();
}

hole_x = 5;
hole_radius = 2.15;
hole_spacing_y = 30;
hole_y = (plate_height - hole_spacing_y) / 2;
hole_spacing_x = plate_width - 2 * hole_x;

module hole(radius = hole_radius) {
  zcyl(
    h = plate_thickness + 2 * e,
    r = radius,
    align = V_TOP
  );
}

module holes() {
  xyflip_copy()
    translate([hole_spacing_x / 2, hole_spacing_y / 2, -e])
    hole();
}

screw_diameter = 9.4;

module screws() {
  xyflip_copy()
    translate([hole_spacing_x / 2, hole_spacing_y / 2, plate_thickness])
    color("red")
    zcyl(
      h = plate_thickness + 2 * e,
      d = screw_diameter,
      align = V_TOP
  );
}

module plate() {
  difference() {
    cuboid(
      [plate_width, plate_height, plate_thickness],
      align = V_UP,
      fillet = plate_rounding,
      edges = EDGES_Z_ALL
    );
    holes();
  }
}

function slant(depth) = depth / tan(slant_angle);

module cutout(width = undef, depth, base_width = undef, rounding = cutout_rounding, thickness = plate_thickness, center = false, mask = true) {
  slant = slant(depth);
  fillet_angle = 180 - slant_angle;
  width_ = is_undef(width) ? base_width - 2 * slant - 2 * rounding / tan(fillet_angle / 2) : width;
  thickness_ = mask ? thickness + 2 * e : thickness;
  translate([0, mask ? -e : 0, center ? 0 : thickness / 2]) {
    difference() {
      prismoid(
        size1 = [width_ + 2 * slant, thickness_],
        size2 = [width_, thickness_],
        h = depth + (mask ? 2 * e : 0),
        orient = ORIENT_Y
      );
      xflip_copy()
      translate([-width_ / 2, depth, 0])
        fillet_angled_edge_mask(
          h = thickness_ + 2 * e,
          r = rounding,
          ang = 180 - slant_angle
        );
    }
    xflip_copy()
    translate([width_ / 2 + slant, 0, 0])
      fillet_angled_edge_mask(
        h = thickness_,
        r = rounding,
        ang = 180 - slant_angle
      );
  }
}

module plate_cutout(width, depth, thickness = plate_thickness) {
  translate([0, -plate_height / 2, 0])
    cutout(width, depth, thickness = thickness);
}

module cutouts() {
  rounding = 3;
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

support_thickness = 4.5;
support_x = 40;
support_width = 2;
support_rounding = 1;

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

card_width_t = card_width + 2 * card_tolerance;
card_height_t = card_height + 2 * card_tolerance;

module plate_thinning() {
  thinning_width = card_width_t + 2 * card_wall - 2 * plate_border;
  thinning_height = card_height_t + 2 * card_wall - 2 * plate_border;

  thinning_width_inner = thinning_width - 2 * thin_chamfer;
  thinning_height_inner = thinning_height - 2 * thin_chamfer;

  translate([0, 0, thin_thickness])
  prismoid(
    size1 = [thinning_width_inner, thinning_height_inner],
    size2 = [thinning_width, thinning_height],
    h = plate_thickness - thin_thickness + e,
    align = V_UP
    );
}

top_lock_width = 20;
top_lock_height = 20;
top_lock_inset = card_thickness * 2;

module top_lock() {
  slant = slant(top_lock_height);
  prismoid(
    size1 = [top_lock_width, 0],
    size2 = [top_lock_width + 2 * slant, top_lock_height],
    h = top_lock_inset,
    shift = [0, -top_lock_height / 2],
    align = V_BACK + V_DOWN
  );
}

card_box_width = card_width_t + 2 * card_wall;
card_box_height = card_height_t + 2 * card_wall;
card_box_thickness = cards_thickness + thin_thickness;
card_box_x = (plate_width - card_box_width) / 2;

flip_spacing = 0.5; // TODO

flip_offset = card_box_thickness + flip_spacing;

hinge_support_width = 1;
hinge_width = 1.5;

hinge_threshold = 0.3;
hinge_axis_d = 2;

hinge_wall = 0.5;

hinge_slant_angle = 60;

hinge_slot_width = hinge_threshold * 2 + hinge_width;

hinge_axis_x = -card_box_width / 2 - hinge_slot_width / 2;
hinge_axis_y = hinge_wall + hinge_threshold + hinge_axis_d / 2 - plate_height / 2; // TODO this should be absolute
hinge_axis_z = flip_offset / 2;

module hinge_support_slant(h, thickness, d, a = hinge_slant_angle, w = undef) {
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

module hinge_support(h, thickness, d, a = hinge_slant_angle, opposite_w = undef) {
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
      h = h + hinge_axis_d / 2,
      thickness = hinge_support_width,
      d = hinge_axis_d,
      opposite_w = hinge_threshold + hinge_wall
    );
  }
  cyl(
    orient = ORIENT_X,
    l = hinge_slot_width + 2 * e,
    d = hinge_axis_d
  );
  support_offset = (hinge_slot_width + hinge_support_width) / 2;
  if (left_wall)
    translate([-support_offset, 0, 0])
      support();
  if (right_wall)
    translate([support_offset, 0, 0])
      support();
}

module hinge(h, rotation = 0) {
  outer_d = hinge_axis_d + 2 * hinge_threshold;
  xrot(rotation)
  difference() {
    yflip()
    hinge_support(
      h = h + outer_d / 2 + hinge_wall,
      thickness = hinge_width,
      d = outer_d + hinge_wall * 2
    );
    cyl(
      orient = ORIENT_X,
      l = hinge_width + 2 * e,
      d = outer_d
    );
  }
}

module card_plate() {
  push_cutout_width = 30;
  push_cutout_depth = 10;

  difference() {
    plate();
    plate_thinning();
  }
  // enable screws to see clearance
  // screws();

  translate([0, 0, plate_thickness]) {
    xflip_copy()
    translate([hinge_axis_x, hinge_axis_y, hinge_axis_z]) {
      hinge_base(
        h = hinge_axis_z,
        right_wall = false
      );
      hinge(
        h = flip_offset - hinge_axis_z,
        rotation = 180
      );
    }

    difference() {
      union() {
        // card box walls
        difference() {
          cuboid(
            [card_box_width, card_box_height, cards_thickness],
            align = V_UP,
            fillet = card_wall,
            edges = EDGES_Z_ALL
          );
          // card space box
          translate([0, card_wall / 2, -e])
            cuboid(
              [card_width_t, card_height_t + card_wall + e, cards_thickness + 2 * e],
              align = V_UP
            );
        }
        // card box roof
        translate([0, 0, cards_thickness - e])
        difference() {
          union() {
              cuboid(
                [card_box_width, card_box_height, thin_thickness + e],
                align = V_UP,
                fillet = card_wall,
                edges = EDGES_Z_ALL
              );
            // top lock - inner
            translate([0, card_box_height / 2, e])
              top_lock();
          }
          translate([0, card_box_height / 2, thin_thickness + 2 * e])
            top_lock();
        }
      }
      union() {
        // cutout for pushing cards out
        translate([0, -plate_height / 2, 0])
          cutout(push_cutout_width, push_cutout_depth, thickness = card_box_thickness + 2 * e);
        // cutouts for screws
        screw_cutout_width = 6;
        screw_cutout_depth = 3;
        xyflip_copy()
        translate([-card_box_width / 2, -hole_spacing_y / 2, 0])
          zrot(-90)
          cutout(screw_cutout_width, screw_cutout_depth, thickness = card_box_thickness + e, rounding = 2);
      }
    }
  }
}

ydistribute(plate_height + 10) {
  card_plate();
  key_plate();
}
