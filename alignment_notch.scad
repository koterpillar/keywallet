include <BOSL/constants.scad>
use <BOSL/shapes.scad>
use <BOSL/transforms.scad>

include <environment.scad>
use <utils.scad>
include <constants.scad>

$fa = 1;
$fs = 0.2;

module alignment_notch(position, tolerance_h) {
  tolerance = 0.2;
  thickness = 0.7;
  height = 3;

  d = position == POSITION_POSITIVE ? -tolerance / 2 : tolerance / 2;
  width = card_wall + d * 2;

  hd = position == POSITION_POSITIVE ? -tolerance_h / 2 : tolerance_h / 2;

  translate([0, 0, -e])
  cuboid(
    [width, height + d * 2, thickness + hd + e],
    align = V_UP,
    fillet = width / 2 - e,
    edges = EDGES_Z_ALL
  );
}

TEST_SZ = 10;
TEST_GAP = 1;
TEST_SPACING = TEST_SZ + TEST_GAP;

NOTCH_SZ_Y = 1;
NOTCH_SZ_X = 0.6;
NOTCH_GAP = 0.6;

module test_plate(idx) {
  difference() {
    cuboid([TEST_SZ, TEST_SZ, plate_thickness], align = V_DOWN);
    translate([0, -TEST_SZ / 2 + NOTCH_SZ_Y / 2, 2 * e])
        xspread(spacing = NOTCH_SZ_X + NOTCH_GAP, n = idx + 1)
            cuboid([NOTCH_SZ_X, NOTCH_SZ_Y + e, plate_thickness + 4 * e], align = V_DOWN);
  }
}

module test_cut(idx, tolerance_h) {
  difference() {
    test_plate(idx = idx);
    zflip() alignment_notch(POSITION_NEGATIVE, tolerance_h = tolerance_h);
  }
}

module test_pos(idx, tolerance_h) {
  test_plate(idx = idx);
  alignment_notch(POSITION_POSITIVE, tolerance_h = tolerance_h);
}

module test(idx, tolerance_h) {
  translate([0, TEST_SPACING / 2, 0]) test_cut(idx = idx, tolerance_h = tolerance_h);
  translate([0, -TEST_SPACING / 2, 0]) test_pos(idx = idx, tolerance_h = tolerance_h);
}

xspread(spacing = TEST_SPACING, n = 8) test(idx = $idx, tolerance_h = -0.2 + $idx * 0.1);
