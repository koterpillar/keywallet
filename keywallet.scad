$fa = 1;
$fs = 0.2;

e = 0.001;

CubeFaces = [
  [0,1,2,3],  // bottom
  [4,5,1,0],  // front
  [7,6,5,4],  // top
  [5,6,2,1],  // right
  [6,7,3,2],  // back
  [7,4,0,3]]; // left

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

module plate(thickness = plate_thickness) {
  linear_extrude(height = thickness) {
    difference() {
      offset(r = plate_rounding)
        translate([plate_rounding, plate_rounding])
          square([
              plate_width - 2 * plate_rounding,
              plate_height - 2 * plate_rounding,
          ]);
      {
        plate_symmetric()
          translate([hole_x, hole_y])
            circle(hole_radius);
      }
    }
  }
}

module cutout(slant, width, depth, rounding, thickness = plate_thickness) {
  overhang_x = rounding * 2;
  overhang_y = rounding * 2 + e;
  translate([0, 0, -e])
    linear_extrude(height = thickness + 2 * e)
      offset(r = -rounding)
      offset(delta = rounding)
      offset(r = rounding)
      offset(delta = -rounding)
        polygon([
          [-slant - overhang_x, -overhang_y],
          [-slant - overhang_x, -e],
          [-slant, 0],
          [0, depth],
          [width, depth],
          [width + slant, 0],
          [width + slant + overhang_x, -e],
          [width + slant + overhang_x, -overhang_y],
          ]);
}

module plate_cutout(slant, width, depth, rounding, thickness = plate_thickness) {
  translate([(plate_width - width) / 2, 0, 0])
    cutout(slant, width, depth, rounding, thickness);
}

module cutouts() {
  slant = 5;
  rounding = 4;
  width_1 = 25;
  depth_1 = 15;
  width_2 = 25;
  depth_2 = 7.5;

  plate_cutout(slant, width_1, depth_1, rounding);
  plate_flip_y() plate_cutout(slant, width_2, depth_2, rounding);
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
        cutout(0, interval / 2, depth, rounding);
}

support_thickness = 4.5;
support_x = 40;
support_width = 2;
support_rounding = 1;

module support(inset) {
  overhang_y = 1;
  translate([0, 0, plate_thickness - e])
    linear_extrude(height = support_thickness + e)
    offset(r = support_rounding - e)
    offset(delta = -support_rounding + e)
    polygon([
      [support_x, inset],
      [support_x, plate_height / 2 + overhang_y],
      [support_x + support_width, plate_height / 2 + overhang_y],
      [support_x + support_width, inset],
    ]);
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

holder_overhang = 5;
holder_rounding = 2;
sr = 1;

module card_holder(size) {
  translate([0, 0, -e])
    cube([size, card_wall, cards_thickness + e]);
  translate([0, 0, cards_thickness - e]) {
    intersection() {
      linear_extrude(height = plate_thickness)
        intersection() {
          offset(r = holder_rounding)
            offset(delta = -holder_rounding)
            translate([0, -holder_rounding])
            square([size, holder_overhang + holder_rounding]);
          square([size, holder_overhang]);
        }
      translate([0, 0, plate_thickness])
        rotate([0, 90, 0])
        linear_extrude(height = size)
        offset(r = sr)
        offset(delta = -sr)
        square([sr * 2 + plate_thickness + e, holder_overhang + sr]);
    }
  }
}

module card_plate() {
  thickness = plate_thickness;
  side_holder_offset = 10;
  side_holder_size = 40;
  bottom_holder_size = 60;
  tooth_width = 10;
  tooth_inset_height = 1;
  tooth_cutout_height = 10;
  tooth_cutout_width = 2;
  tooth_cutout_rounding = 1;
  tooth_cutout_slant = 2;

  difference() {
    plate();
    // cutouts for tooth to spring
    plate_flip_y()
      plate_cutout(tooth_cutout_slant, tooth_width + 2 * tooth_cutout_width, tooth_cutout_height, tooth_cutout_rounding);
  }

  card_width_t = card_width + 2 * card_tolerance;
  card_height_t = card_height + 2 * card_tolerance;

  corner_x = (plate_width - card_width_t) / 2 - card_wall;

  // side holders
  plate_symmetric_x()
    translate([corner_x, side_holder_offset + side_holder_size, thickness])
    rotate([0, 0, -90])
    card_holder(side_holder_size);
  // bottom holder
  translate([(plate_width - bottom_holder_size) / 2, 0, thickness])
    card_holder(bottom_holder_size);
  // tooth
  translate([(plate_width - tooth_width) / 2, plate_height - tooth_cutout_height - e, 0])
    cube([tooth_width, tooth_cutout_height - tooth_inset_height, thickness]);
  tooth_thickness = thickness + cards_thickness + thickness + e;
  translate([(plate_width - tooth_width) / 2, plate_height - card_wall, 0])
    polyhedron([
      [0          , -tooth_inset_height           , 0              ],
      [tooth_width, -tooth_inset_height           , 0              ],
      [tooth_width, card_wall - tooth_inset_height, 0              ],
      [0          , card_wall - tooth_inset_height, 0              ],
      [0          , 0                             , tooth_thickness],
      [tooth_width, 0                             , tooth_thickness],
      [tooth_width, card_wall                     , tooth_thickness],
      [0          , card_wall                     , tooth_thickness],
    ], CubeFaces);
}

module arrange_plates() {
  spacing = plate_height + 10;
  for(i = [0 : 1 : $children - 1])
    translate([0, -i * spacing, 0])
      children(i);
}

arrange_plates() {
  card_plate();
  key_plate();
}
