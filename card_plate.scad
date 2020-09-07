include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>
use <components.scad>
use <hinge.scad>
use <card_slider.scad>

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
    translate([0, 0, flip_offset + card_slider_thickness() / 2])
      card_slider();

    // hinges
    xflip_copy() {
      hinge_axis_x = -card_box_width / 2 - hinge_offset_x(wall = false);
      hinge_axis_y = hinge_offset_y_min() - plate_height / 2;
      hinge_axis_z = flip_offset / 2;
      hinge_h = flip_offset - hinge_axis_z;

      translate([hinge_axis_x, hinge_axis_y, hinge_axis_z]) {
        hinge_base(
          h = hinge_axis_z,
          right_wall = false
        );
        hinge(
          h = hinge_h,
          rotation = 180
        );
      }

      // connect hinge to slider
      arm_x = hinge_axis_x - hinge_middle_width() / 2;
      echo(hinge_offset_y_min());
      echo(hinge_offset_y_max(0));
      echo(hinge_offset_y_max(hinge_h));
      arm_y1 = hinge_axis_y - hinge_offset_y_min();
      arm_y2 = hinge_axis_y + hinge_offset_y_max(hinge_h);
      slider_x = -card_slider_width() / 2;
      slider_y = -card_slider_height() / 2;
      translate([arm_x, arm_y1, flip_offset - e])
        cuboid(
          [
            abs(arm_x - slider_x) + card_wall + e,
            abs(arm_y2 - arm_y1),
            card_slider_thickness() + e
          ],
          align = V_ALLPOS
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

card_plate();
