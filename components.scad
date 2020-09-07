include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>

function slant(depth) = depth / tan(slant_angle);

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
