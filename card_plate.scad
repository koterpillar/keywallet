include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>

use <cutout.scad>
use <plate.scad>

$fa = 1;
$fs = 0.2;

assert(card_width_t <= plate_width - 2 * hole_x - screw_cap_side,
  "Not enough space for card box between screws");

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
card_box_width_base = card_width_t + 2 * card_wall_base;
card_box_height = card_height_t + 2 * card_wall;
card_box_thickness = cards_thickness + thin_thickness;

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

cut_in_rounding = 3;

module cut_in(height, thickness, width = cut_width) {
  translate([0, 0, -e])
    cuboid(
      [width, height, thickness + 2 * e],
      align = V_UP + V_FWD
    );
  xflip_copy()
    translate([width / 2, 0, -e])
    fillet_mask(l = thickness + 2 * e, r = cut_in_rounding, align = V_UP);
}

cards_space_max = cards_thickness - cards_thickness_min;

retainer_width = 30;
retainer_depth = 20;

module card_plate_top() {
  push_cutout_width = 35;
  push_cutout_depth = 15;

  // enable to see screw caps
  // color("red", 0.5) screw_cap();

  translate([0, 0, plate_thickness]) {
    // card box
    difference() {
      union() {
        difference() {
          rounded_prismoid(
            size1 = [card_box_width_base, card_box_height],
            size2 = [card_box_width, card_box_height],
            h = cards_thickness + thin_thickness,
            align = V_UP,
            r = card_wall
          );
          // card space box
          translate([0, 0, -e])
            cuboid(
              [card_width_t, card_height_t + e, cards_thickness + 2 * e],
              align = V_UP
            );
        }
      }
      union() {
        // cutout for pushing cards out
        translate([0, -plate_height / 2, 0])
          cutout(
            base_width = push_cutout_width,
            depth = push_cutout_depth,
            thickness = card_box_thickness + 2 * e
          );
        // cuts for the retainer to bend
        xflip_copy()
          translate([retainer_width / 2, plate_height / 2, 0])
          cut_in(
            height = retainer_depth,
            thickness = cards_thickness + thin_thickness
          );
        // remove walls except for the retainer
        xflip_copy()
          translate([retainer_width / 2, plate_height / 2 + e, -e])
          cuboid(
            [(card_width_t - retainer_width) / 2, card_wall + 2 * e, cards_thickness + 2 * e],
            align = V_UP + V_FWD + V_RIGHT
          );
        // cut retainer wall
        translate([0, plate_height / 2 + e, -e])
          cuboid(
            [retainer_width, card_wall + 2 * e, cards_thickness_min + e],
            align = V_UP + V_FWD
          );
        // cutouts for screws
        translate([0, 0, -plate_thickness])
          screw_cap_clearance();
      }
    }
  }

  alignment_notches(POSITION_POSITIVE);
}

pusher_width = 5;
pusher_tip_height = 3;
pusher_tip_width = 4;
pusher_base_height = 10;
pusher_spring_height = 15;
pusher_fillet = 2;

module pusher() {
  difference() {
    union() {
      cuboid(
        [
          pusher_width,
          pusher_spring_height,
          thin_thickness
        ],
        align = V_UP
      );
      translate([0, (pusher_base_height - pusher_spring_height) / 2, thin_thickness - e])
        rounded_prismoid(
          size1 = [pusher_width, pusher_base_height],
          size2 = [pusher_tip_width, pusher_tip_height],
          h = plate_thickness + cards_space_max - thin_thickness,
          r = pusher_fillet,
          align = V_UP
        );
    }
    union() {
      xflip_copy()
        translate([pusher_width / 2, -pusher_spring_height / 2, 0])
        fillet_mask(l = 10, r = pusher_fillet, align = V_UP);
    }
  }
}

module pusher_cut() {
  translate([0, -cut_width / 2, -e])
  cuboid(
    [
      pusher_width + cut_width * 2,
      pusher_spring_height + cut_width - 2 * e,
      plate_thickness + 2 * e
    ],
    align = V_UP,
    fillet = pusher_fillet + cut_width,
    edges = EDGES_Z_FR
  );
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
      pusher_cut();
    }
  }
  pusher();
  // more walls
  xflip_copy() {
    h = cards_space_max + 2 * e;
    xi = retainer_width / 2 + cut_width / 2;
    translate([xi, plate_height / 2 + e, plate_thickness - e])
      difference() {
        cuboid(
          [card_width_t / 2 - xi, card_wall + 2 * e, h],
          align = V_UP + V_FWD + V_RIGHT
        );
        fillet_mask(l = h, r = cut_in_rounding, align = V_UP);
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
