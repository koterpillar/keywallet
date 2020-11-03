card_tolerance = 0.2;

cards_thickness = 3.4;

card_wall = 1.5;

screw_d = 4.3;
screw_cap_side = 7.8;
screw_cap_h = 8.5 - 6.7;

screw_inset = 0.2;

plate_width = 105;
plate_height = card_height + 2 * card_wall + 2 * card_tolerance;
plate_thickness = 1.2;

hole_x = 5;

slant_angle = 70;
function slant(depth) = depth / tan(slant_angle);

plate_border = 5;
thin_thickness = 0.6;
thin_chamfer = 2;

card_width_t = card_width + 2 * card_tolerance;
card_height_t = card_height + 2 * card_tolerance;
