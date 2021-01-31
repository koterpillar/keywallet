include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>

use <card_slider.scad>
use <cutout.scad>
use <hinge.scad>
use <indentation.scad>
use <plate.scad>

$fa = 1;
$fs = 0.2;

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

card_box_width = card_width_t + 2 * card_wall;
card_box_height = card_height_t + 2 * card_wall;
card_box_thickness = cards_thickness + thin_thickness;
card_box_x = (plate_width - card_box_width) / 2;

assert(card_box_width <= plate_width - 2 * hole_x - screw_cap_side + 2 * card_wall,
  "Not enough space for card box between screws");

flip_spacing = 0.5;

flip_offset = card_box_thickness + flip_spacing;

snap_fit_threshold = 0.1;
tooth_width = 0.6;
tooth_height = 1.9;
snap_width = 0.3;
snap_edge_width = 0.3;
snap_twist_height = 5;

wall_length = card_box_height - card_wall - 2 * snap_fit_threshold;

TOOTH_CUT = -1;
TOOTH_ADD = 1;

snap_x = card_width_t / 2 + tooth_width / 2 + card_wall;

module tooth(o) {
  sp = snap_fit_threshold;

  tooth_x = snap_x + (o + 1) * sp + e;
  tooth_h = cards_thickness + (o - 1) * snap_fit_threshold + 2 * e;
  tooth_length = o == TOOTH_ADD ? wall_length - snap_twist_height : wall_length + 2 * e;

  xflip_copy() {
    translate([tooth_x, -wall_length / 2 - e + card_wall / 2, -e]) {
      difference() {
        cuboid(
          [tooth_width, tooth_length, tooth_height - o * sp],
          align = V_UP + V_LEFT + V_BACK
        );
        translate([-tooth_width, 0, tooth_height - o * sp])
          chamfer_mask_y(
            l = tooth_length,
            chamfer = tooth_width,
            align = V_BACK
          );
        if (o == TOOTH_ADD) {
        }
      }
    }

    translate([tooth_x, card_wall / 2 + wall_length / 2 + e, -e]) {
      edge_y = snap_edge_width + tooth_width;
      edge_h = o == TOOTH_ADD ? tooth_h : tooth_h;
      difference() {
        cuboid(
          [snap_width, edge_y, edge_h],
          align = V_UP + V_LEFT + V_FWD
        );
        translate([-snap_width, -edge_y, 0])
          chamfer_mask_z(
            l = edge_h,
            chamfer = snap_width,
            align = V_UP
          );
        if (o == TOOTH_ADD) {
          translate([-snap_width, 0, edge_h])
            chamfer_mask_y(
              l = edge_y,
              chamfer = snap_width,
              align = V_FWD
            );
        }
      }
    }
  }
}

module card_plate_top() {
  push_cutout_width = 30;
  push_cutout_depth = 10;

  // enable to see screw caps
  // color("red", 0.5) screw_cap();

  translate([0, 0, plate_thickness]) {
    // card box
    difference() {
      union() {
        // card box walls
        difference() {
          cuboid(
            [card_box_width + 2 * card_wall, card_box_height, cards_thickness],
            align = V_UP,
            fillet = card_wall,
            edges = EDGES_Z_ALL
          );
          // card space + bottom walls box
          translate([0, card_wall / 2, -e])
            cuboid(
              [snap_x * 2 + 4 * snap_fit_threshold, card_height_t + card_wall + e, cards_thickness + 2 * e],
              align = V_UP
            );
        }

        tooth(o = TOOTH_ADD);

        // card box roof
        top_lock_width = 20;
        top_lock_height = 20;
        top_lock_inset = card_thickness * 2;

        translate([0, 0, cards_thickness + thin_thickness / 2 - e])
          apply_indentation(
            origin = [0, card_box_height / 2, 0],
            width = top_lock_width,
            height = top_lock_height,
            thickness = thin_thickness + e,
            inset = top_lock_inset
          ) {
            cuboid(
              [card_box_width + 2 * card_wall, card_box_height, thin_thickness + e],
              fillet = card_wall,
              edges = EDGES_Z_ALL
            );
          }
      }
      union() {
        // cutout for tooth snap fit
        xflip_copy()
          translate([snap_x + snap_fit_threshold, card_box_height / 2 + e, cards_thickness - 2 * e])
          cuboid(
            [snap_fit_threshold * 2, snap_twist_height, thin_thickness + 4 * e],
            align = V_UP + V_FWD
          );
        // cutout for pushing cards out
        translate([0, -plate_height / 2, 0])
          cutout(push_cutout_width, push_cutout_depth, thickness = card_box_thickness + 2 * e);
        // cutouts for screws
        translate([0, 0, -plate_thickness])
          screw_cap_clearance();
      }
    }
  }
}

module card_plate_bottom() {
  difference() {
    difference() {
      plate();
      screw_cap_clearance();
    }
    plate_thinning();
  }
  // enable to see screw caps
  // color("red", 0.5) screw_cap();

  translate([0, 0, plate_thickness]) {
    // card box
    difference() {
      union() {
        // card box walls
        xflip_copy()
          translate([snap_x, card_wall / 2, 0])
            cuboid(
              [card_wall, wall_length, cards_thickness - 2 * snap_fit_threshold],
              align = V_UP + V_LEFT
            );
      }
      union() {
        tooth(o = TOOTH_CUT);
        // cutouts for screws
        translate([0, 0, -plate_thickness])
          screw_cap_clearance();
      }
    }
  }
}

module card_plate() {
  card_plate_top();
  card_plate_bottom();
}

module card_plate_print() {
  ydistribute(spacing = plate_height + 20) {
    card_plate_bottom();
    xrot(180)
      translate([0, 0, -plate_thickness - cards_thickness - thin_thickness + e / 2])
      card_plate_top();
  }
}

card_plate_print();
