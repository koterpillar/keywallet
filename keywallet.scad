$fa = 1;
$fs = 0.2;

e = 0.001;

plate_width = 105;
plate_height = 55;
plate_thickness = 1.2;
plate_rounding = 5;

hole_x = 5;
hole_y = 12.5;
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

module plate() {
  linear_extrude(height = plate_thickness) {
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

module cutout(slant, width, depth, rounding) {
  overhang_x = rounding * 2;
  overhang_y = rounding * 2 + e;
  translate([0, 0, -e])
    linear_extrude(height = plate_thickness + 2 * e)
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

module plate_cutout(slant, width, depth, rounding) {
  translate([(plate_width - width) / 2, 0, 0])
    cutout(slant, width, depth, rounding);
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

translate([0, -plate_height - 10, 0])
  plate();
key_plate();
