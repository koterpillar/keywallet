KEY_THICKNESS = 0;
KEY_SUPPORT_INSET = 1;
KEY_CUTOUT = 2;
KEY_LENGTH = 3;
KEY_NOTCHES = 4;

key_house = [2.1, 9.5, 7.5, 35, 3];
key_trolley = [2.4, 17, 15, 35, 0];
key_USB = [2.0, 13, 7.5, 35, 0];
key_bike = [4.9, 17, 15, 35, 0];

key_L_D = key_house;
key_L_U = key_trolley;
key_R_D = key_USB;
key_R_U = key_bike;

keys = [
  key_L_D,
  key_L_U,
  key_R_D,
  key_R_U,
];

key_max_thickness = max([for (k = keys) if (k[KEY_THICKNESS] > 0) k[KEY_THICKNESS]]);
