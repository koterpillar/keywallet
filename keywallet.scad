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

module plate_flip_x() {
  translate([plate_width, 0, 0]) mirror([1, 0, 0]) children();
}

module plate_flip_y() {
  translate([0, plate_height, 0]) mirror([0, 1, 0]) children();
}

module plate_symmetric_x() {
  children();
  plate_flip_x() children();
}

module plate_symmetric_y() {
  children();
  plate_flip_y() children();
}

module plate_symmetric() {
  plate_symmetric_x() plate_symmetric_y() children();
}

hole_x = 5;
hole_radius = 2.15;
hole_spacing_y = 30;
hole_y = (plate_height - hole_spacing_y) / 2;

module hole(radius = hole_radius) {
  zcyl(
    h = plate_thickness + 2 * e,
    r = radius,
    align = V_TOP
  );
}

module holes() {

  plate_symmetric()
    translate([hole_x, hole_y, -e])
    hole();
}

module hole_test() {
  width = plate_width;
  height = 15;
  difference() {
    cuboid(
      [width, height, plate_thickness],
      align = V_ALLPOS
    );
    translate([width / 2, height / 2, -e])
      xdistribute(11.5) {
        hole(2);
        hole(2.15);
        hole(2.3);
        hole(2.45);
        hole(2.6);
        hole(2.75);
        hole(2.9);
        hole(3.15);
      }
  }
}

screw_diameter = 9.4;

module screws() {
  plate_symmetric()
    translate([hole_x, hole_y, plate_thickness])
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
      align = V_ALLPOS,
      fillet = plate_rounding,
      edges = EDGES_Z_ALL
    );
    holes();
  }
}

function slant(depth) = depth / tan(slant_angle);

module cutout(width, depth, rounding = cutout_rounding, thickness = plate_thickness) {
  slant = slant(depth);
  thickness = thickness + 2 * e;
  translate([-slant, -e, thickness / 2 - e]) {
    difference() {
      prismoid(
        size1 = [width + 2 * slant, thickness],
        size2 = [width, thickness],
        h = depth + e,
        orient = ORIENT_Y,
        align = V_BACK + V_RIGHT
      );
      union() {
        translate([slant, depth, 0])
          fillet_angled_edge_mask(
            h = thickness + 2 * e,
            r = rounding,
            ang = 180 - slant_angle
          );
        translate([slant + width, depth, 0])
          mirror(V_LEFT)
          fillet_angled_edge_mask(
            h = thickness + 2 * e,
            r = rounding,
            ang = 180 - slant_angle
          );
      }
    }
    mirror(V_LEFT)
      fillet_angled_edge_mask(
        h = thickness,
        r = rounding,
        ang = 180 - slant_angle
      );
    translate([width + 2 * slant, 0, 0])
      fillet_angled_edge_mask(
        h = thickness,
        r = rounding,
        ang = 180 - slant_angle
      );
  }
}

module plate_cutout(width, depth, thickness = plate_thickness) {
  translate([(plate_width - width) / 2, 0, 0])
    cutout(width, depth, thickness = thickness);
}

module cutouts() {
  rounding = 3;
  width_1 = 25;
  depth_1 = 15;
  width_2 = 25;
  depth_2 = 7.5;

  plate_cutout(width_1, depth_1);
  plate_flip_y() plate_cutout(width_2, depth_2);
}

module asymmetry() {
  start_x = 10;
  depth = 1;
  interval = 4;
  rounding = 0.5;
  count = 3;

  plate_symmetric_x()
    for(i = [0 : count - 1])
      translate([start_x + interval * i, 0, 0])
        cutout(interval / 2, depth, rounding);
}

support_thickness = 4.5;
support_x = 40;
support_width = 2;
support_rounding = 1;

module support(inset) {
  translate([support_x, inset, plate_thickness - e])
    cuboid(
      [support_width, plate_height / 2 - inset, support_thickness + e],
      align = V_ALLPOS,
      fillet = support_rounding,
      edges = EDGES_Z_FR
    );
}

module supports() {
  support(17);
  plate_flip_x() support(17);
  plate_flip_y() support(13);
  plate_flip_y() plate_flip_x() support(9.5);
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

  translate([(plate_width - thinning_width_inner) / 2, (plate_height - thinning_height_inner) / 2, thin_thickness])
  prismoid(
    size1 = [thinning_width_inner, thinning_height_inner],
    size2 = [thinning_width, thinning_height],
    h = plate_thickness - thin_thickness + e,
    align = V_ALLPOS
    );
}

module spring(height, width, thickness, lift) {
  l = lift - thickness;
  h = height / 2;
  r = (h * h + l * l) / 2 / l;
  intersection() {
    translate([0, height / 2, l - r])
      tube(
        h = width,
        ir = r,
        wall = thickness,
        orient = ORIENT_X
      );
    cube([
      width,
      height,
      lift
    ]);
  }
}

top_lock_width = 10;
top_lock_height = 10;
top_lock_inset = card_thickness;

module top_lock() {
  slant = slant(top_lock_height);
  translate([card_wall + (card_width_t - top_lock_width) / 2, plate_height, 0])
    prismoid(
      size1 = [top_lock_width, 0],
      size2 = [top_lock_width + 2 * slant, top_lock_height],
      h = top_lock_inset,
      shift = [0, -top_lock_height / 2],
      align = V_BACK + V_RIGHT
    );
}

module card_plate() {
  push_cutout_width = 30;
  push_cutout_depth = 10;

  bottom_spring_width = 10;
  bottom_spring_height = 20;
  bottom_spring_neutral_height = 10;
  bottom_spring_lift = (plate_thickness - thin_thickness) + cards_thickness - card_thickness / 2;

  bottom_spring_cutout_width = bottom_spring_width + 10;
  bottom_spring_cutout_height = bottom_spring_height + 2 * bottom_spring_neutral_height;

  card_box_width = card_width_t + 2 * card_wall;
  card_box_height = card_height_t + 2 * card_wall;

  difference() {
    plate();
    union () {
      plate_thinning();
      // cutout for bottom spring
      translate([(plate_width - bottom_spring_cutout_width) / 2, (plate_height - bottom_spring_cutout_height) / 2, -e])
        cuboid(
          [bottom_spring_cutout_width, bottom_spring_cutout_height, plate_thickness + 2 * e],
          align = V_ALLPOS
        );
    }
  }
  // enable screws to see clearance
  // screws();

  // bottom spring - horizontal part
  translate([(plate_width - bottom_spring_width) / 2, 0, 0])
    plate_symmetric_y()
    cuboid(
      [bottom_spring_width, (plate_height - bottom_spring_height) / 2 + e, thin_thickness - e],
      align = V_ALLPOS
    );
  // bottom spring - curved part
  translate([(plate_width - bottom_spring_width) / 2, (plate_height - bottom_spring_height) / 2, 0])
    spring(
      height = bottom_spring_height,
      width = bottom_spring_width,
      thickness = thin_thickness,
      lift = bottom_spring_lift
    );

  translate([(plate_width - card_box_width) / 2, (plate_height - card_box_height) / 2, plate_thickness - e])
    difference() {
      // full box with card space inside
      cuboid(
        [card_box_width, card_box_height, cards_thickness + thin_thickness + e],
        align = V_ALLPOS,
        fillet = card_wall,
        edges = EDGES_Z_ALL
      );
      union() {
        // card space box
        difference() {
          translate([card_wall, card_wall, -e])
            cuboid(
              [card_width_t, card_height_t + card_wall + e, cards_thickness + e],
              align = V_ALLPOS
            );
          // top lock - inner
          translate([0, 0, cards_thickness + thin_thickness - top_lock_inset])
            top_lock();
        }
        // cutout for pushing cards out
        translate([(card_box_width - push_cutout_width) / 2, 0, 0])
          cutout(push_cutout_width, push_cutout_depth, thickness = cards_thickness + thin_thickness + 2 * e);
        // cutouts for screws
        screw_cutout_width = 6;
        screw_cutout_depth = 3;
        translate([-(plate_width - card_box_width) / 2, -(plate_height - card_box_height) / 2])
          plate_symmetric()
          translate([(plate_width - card_box_width) / 2, (plate_height - hole_spacing_y + screw_cutout_width) / 2, 0])
          zrot(-90)
          cutout(screw_cutout_width, screw_cutout_depth, thickness = cards_thickness + thin_thickness + e, rounding = 2);
        // top lock - outer
        translate([0, 0, cards_thickness + thin_thickness])
          top_lock();
      }
    }
}

ydistribute(plate_height + 10) {
  card_plate();
  key_plate();
}
