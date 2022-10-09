card_tolerance = 0.2;

cards_thickness = 4.4;
cards_thickness_min = 2.2;

card_wall = 1.5;
card_wall_base = 3;

screw_d = 3.8;
screw_cap_side = 7.8;
screw_cap_h = 8.5 - 6.7;

screw_2_cap_d = 7.6;
screw_2_cap_h = 0.7;

screw_inset = 0.2;
screw_2_inset = 0;

plate_width = 105;
plate_height = card_height + 2 * card_wall + 2 * card_tolerance;
plate_thickness = 1.2;

hole_x = 5;

slant_angle = 70;
function slant(depth) = depth / tan(slant_angle);

cut_width = 0.6;

card_width_t = card_width + 2 * card_tolerance;
card_height_t = card_height + 2 * card_tolerance;

POSITION_POSITIVE = 1;
POSITION_NEGATIVE = -1;
