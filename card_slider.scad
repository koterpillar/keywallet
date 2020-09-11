include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>
use <components.scad>

$fa = 1;
$fs = 0.2;

thickness = 0.6;

height_percentage = 0.2;

width = card_width_t + 2 * card_wall;
function card_slider_width() = width;

inner_height = card_tolerance + height_percentage * card_height;

height = inner_height + card_wall;
function card_slider_height() = height;

inner_thickness = card_thickness + 2 * card_tolerance;

total_thickness = inner_thickness + 2 * thickness;

function card_slider_thickness() = total_thickness;

module card_slider_cover() {
  cuboid([width, height, thickness]);
}

module card_slider() {
  difference() {
    union() {
      // covers
      for (position = [-1, 1])
        translate([0, 0, position * (inner_thickness / 2 + thickness / 2)])
          apply_indentation(
            origin = [0, height, 0],
            width = 10,
            height = 5,
            thickness = thickness,
            inset = card_thickness / 3 * position
          ) {
            cuboid([width, height, thickness], align = V_BACK);
          }
      // walls
      difference() {
        cuboid([width, height, inner_thickness], align = V_BACK);
        translate([0, card_wall, 0])
        cuboid([card_width_t, inner_height + e, inner_thickness + 2 * e], align = V_BACK);
      }
    }
    // fillets for everything at once
    for (position = [0, 1])
      xflip_copy()
      translate([width / 2, height * position, 0])
      fillet_mask(
        l = 10,
        r = card_wall,
        center = true
      );
  }
}

card_slider();
