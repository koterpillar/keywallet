include <BOSL/constants.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>

$fa = 1;
$fs = 0.2;

module alignment_notch(position, tolerance = 0.1) {
  thickness = 0.7;
  height = 3;

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

TEST_SZ = 6;
TEST_GAP = 1;
TEST_SPACING = TEST_SZ + TEST_GAP;

module test_plate() {
  cuboid([TEST_SZ, TEST_SZ, plate_thickness], align = V_DOWN);
}

module test_cut(tolerance) {
  difference() {
    test_plate();
    zflip() alignment_notch(POSITION_NEGATIVE, tolerance);
  }
}

module test_pos(tolerance) {
  test_plate();
  alignment_notch(POSITION_POSITIVE, tolerance);
}

module test(tolerance) {
  translate([0, TEST_SPACING / 2, 0]) test_cut(tolerance);
  translate([0, -TEST_SPACING / 2, 0]) test_pos(tolerance);
}

xspread(spacing = TEST_SPACING, n = 8) test(0.05 + $idx * 0.05);
