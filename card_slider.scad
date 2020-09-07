include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>
use <components.scad>
use <hinge.scad>

$fa = 1;
$fs = 0.2;

back_wall = 0.5;

side = 3;

thickness = 0.6;

net_angle = slant_angle;

net_width = 2;

net_spacing = 15;

width = card_width_t + 2 * card_wall;
function card_slider_width() = width;

height = card_height_t + 2 * card_wall;
function card_slider_height() = height;

inner_thickness = card_thickness + 2 * card_tolerance;

total_thickness = inner_thickness + 2 * thickness;

function card_slider_thickness() = total_thickness;

function csd_shift(height) = height / tan(net_angle);

module card_slider_diagonal(height, flip = false) {
  shift = csd_shift(height) * (flip ? -1 : 1);
  translate([-shift / 2, 0, 0])
  prismoid(
    size1 = [net_width, thickness],
    size2 = [net_width, thickness],
    h = height,
    shift = [-shift, 0],
    orient = ORIENT_Y,
    center = true
  );
}

module csd_cover(height, width, flip = false) {
  count = floor(width / net_spacing / 2) + 1;
  for (i = [-count : count]) {
    translate([net_spacing * i, 0, 0])
      card_slider_diagonal(height, flip = flip);
  }
}

module card_slider_cover(height, flip_diagonals = false) {
  inner_width = width - 2 * side;
  inner_height = height - 2 * side;

  module inner_part() {
    cuboid([inner_width, inner_height, thickness + 2 * e]);
  }

  difference() {
    cuboid([width, height, thickness]);
    inner_part();
  }
  intersection() {
    inner_part();
    csd_cover(
      height = inner_height,
      width = inner_width,
      flip = flip_diagonals
    );
  }
}

module card_slider() {
  difference() {
    union() {
      // full cover (top)
      translate([0, 0, inner_thickness / 2 + thickness / 2])
        card_slider_cover(height);
      // walls
      difference() {
        cuboid([width, height, inner_thickness]);
        cuboid([card_width_t, card_height_t, inner_thickness + 2 * e]);
      }
      // bottom cover (half)
      part_height = back_wall * card_height_t + card_wall;
      translate([0, part_height / 2 - height / 2, -inner_thickness / 2 - thickness / 2])
        card_slider_cover(part_height, flip_diagonals = true);
    }
    // fillets for everything at once
    xyflip_copy()
      translate([width / 2, height / 2, 0])
      fillet_mask(
        l = 10,
        r = card_wall,
        center = true
      );
  }
}

card_slider();
