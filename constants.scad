card_count = 3;

card_tolerance = 0.2;

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

hole_x = 5;
hole_radius = 2.15;
hole_spacing_y = 30;
hole_y = (plate_height - hole_spacing_y) / 2;
hole_spacing_x = plate_width - 2 * hole_x;

screw_diameter = 9.4;

support_thickness = 4.5;
support_x = 40;
support_width = 2;
support_rounding = 1;

card_width_t = card_width + 2 * card_tolerance;
card_height_t = card_height + 2 * card_tolerance;

top_lock_width = 20;
top_lock_height = 20;
top_lock_inset = card_thickness * 2;

card_box_width = card_width_t + 2 * card_wall;
card_box_height = card_height_t + 2 * card_wall;
card_box_thickness = cards_thickness + thin_thickness;
card_box_x = (plate_width - card_box_width) / 2;

flip_spacing = 0.5; // TODO

flip_offset = card_box_thickness + flip_spacing;
