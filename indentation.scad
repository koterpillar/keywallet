include <BOSL/constants.scad>
use <BOSL/shapes.scad>

include <environment.scad>
include <constants.scad>

module indentation(width, height, inset) {
  slant = slant(height);
  translate([0, 0, e * sign(inset)])
  prismoid(
    size1 = [width, 0],
    size2 = [width + 2 * slant, height],
    h = inset + e,
    shift = [0, -height / 2],
    align = V_BACK + V_DOWN
  );
}

module apply_indentation(origin = [0, 0, 0], width, height, thickness, inset) {
  module i() {
    indentation(
      width = width,
      height = height,
      inset = inset
    );
  }

  difference() {
    union() {
      children();
      translate(origin + [0, 0, -thickness / 2 * sign(inset)])
        i();
    }
    translate(origin + [0, 0, thickness / 2 * sign(inset)])
      i();
  }
}

