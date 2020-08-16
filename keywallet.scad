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

card_wall = 1.5;

plate_width = 105;
plate_height = card_height + 2 * card_wall + 2 * card_tolerance;
plate_thickness = 1.2;
plate_rounding = 5;

slant_angle = 70;
cutout_rounding = 3;

hole_x = 5;
hole_spacing_y = 30;
hole_y = (plate_height - hole_spacing_y) / 2;
hole_radius = 2;

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

module holes() {
  plate_symmetric()
    translate([hole_x, hole_y, -e])
    zcyl(
      h = plate_thickness + 2 * e,
      r = hole_radius,
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

module cutout(width, depth, rounding = cutout_rounding, thickness = plate_thickness) {
  slant = depth / tan(slant_angle);
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
  plate_flip_y() support(9.5);
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

cards_thickness = card_count * (card_thickness + card_tolerance_z);

module card_plate() {
  thickness = plate_thickness;
  side_holder_offset = 10;
  side_holder_size = 40;
  bottom_holder_size = 60;
  tooth_width = 10;
  tooth_cutout_height = 10;
  tooth_cutout_width = 2;
  tooth_cutout_rounding = 1;
  tooth_lift = cards_thickness - card_thickness / 2;

  difference() {
    plate();
    // cutouts for tooth to spring
    plate_flip_y()
      plate_cutout(tooth_width + 2 * tooth_cutout_width, tooth_cutout_height);
  }

  card_width_t = card_width + 2 * card_tolerance;
  card_height_t = card_height + 2 * card_tolerance;

  corner_x = (plate_width - card_width_t) / 2 - card_wall;
}

ydistribute(plate_height + 10) {
  card_plate();
  key_plate();
}
