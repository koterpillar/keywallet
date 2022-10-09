include <BOSL/constants.scad>
use <BOSL/shapes.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>

$fa = 1;
$fs = 0.2;

module alignment_notch(position) {
  thickness = 0.7;
  height = 3;
  tolerance = 0.1;

  d = position == POSITION_POSITIVE ? -tolerance / 2 : tolerance / 2;
  width = card_wall + d * 2;

  translate([0, 0, -e])
  cuboid(
    [width, height + d * 2, thickness + d + e],
    align = V_UP,
    fillet = width / 2 - e,
    edges = EDGES_Z_ALL
  );
}
