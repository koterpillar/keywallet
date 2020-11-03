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

    // card slider
    translate([0, -card_box_height / 2, flip_offset + card_slider_thickness() / 2])
      card_slider();

    // hinges
    xflip_copy() {
      hinge_axis_z = flip_offset / 2;
      hinge_origin = [
        -card_box_width / 2 - hinge_offset_x(wall = false),
        hinge_offset_y_min() - plate_height / 2,
        hinge_axis_z
      ];
      hinge_h = flip_offset - hinge_axis_z;

      translate(hinge_origin) {
        hinge_base(
          h = hinge_axis_z,
          right_wall = false
        );
        hinge(
          h = hinge_h,
          rotation = 180
        );
      }

      hinge_attach(
        hinge_origin = hinge_origin,
        hinge_h = hinge_h,
        target_x = -card_slider_width() / 2 + card_wall,
        target_z = flip_offset + card_slider_thickness()
      );
    }

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
      }
    }
  }
}

card_plate();
