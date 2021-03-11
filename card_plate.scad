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

assert(card_box_width <= plate_width - 2 * hole_x - screw_cap_side + 2 * card_wall,
  "Not enough space for card box between screws");

module alignment_notch(position) {
  thickness = 0.7;
  height = 3;
  tolerance = 0.1;

  d = position == POSITION_POSITIVE ? -tolerance / 2 : tolerance / 2;
  width = card_wall + d * 2;

  translate([0, 0, -e])
  cuboid(
    [width, height + d * 2, thickness + d + e],
    align = V_UP,
    fillet = width / 2 - e,
    edges = EDGES_Z_ALL
  );
}

module alignment_notches(position) {
  xyflip_copy()
    translate([card_box_width / 2 - card_wall / 2, 25, plate_thickness])
    zflip()
    alignment_notch(position);
}

module card_plate_top() {
  push_cutout_width = 25;
  push_cutout_depth = 15;

  // enable to see screw caps
  // color("red", 0.5) screw_cap();

  translate([0, 0, plate_thickness]) {
    // card box
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
        top_lock_width = 20;
        top_lock_height = 20;
        top_lock_inset = card_thickness;

        translate([0, 0, cards_thickness + thin_thickness / 2 - e]) {
          cuboid(
            [card_box_width, card_box_height, thin_thickness + e],
            fillet = card_wall,
            edges = EDGES_Z_ALL
          );
        }
      }
      union() {
        // cutout for pushing cards out
        translate([0, -plate_height / 2, 0])
          cutout(push_cutout_width, push_cutout_depth, thickness = card_box_thickness + 2 * e);
        // cutouts for screws
        translate([0, 0, -plate_thickness])
          screw_cap_clearance();
      }
    }
  }

  alignment_notches(POSITION_POSITIVE);
}

module card_plate_bottom() {
  difference() {
    union() {
      plate();
    }
    union() {
      screw_cap_clearance();
      plate_thinning();
      alignment_notches(POSITION_NEGATIVE);
    }
  }
  // enable to see screw caps
  // color("red", 0.5) screw_cap();
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
