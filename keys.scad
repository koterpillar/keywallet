KEY_THICKNESS = 0;
KEY_SUPPORT_INSET = 1;
KEY_CUTOUT = 2;
KEY_LENGTH = 3;
KEY_NOTCHES = 4;

// house
key_L_D = [2.1, 9.5, 7.5, 35, 3];

// trolley
key_L_U = [2.4, 17, 15, 35, 0];

// USB
key_R_D = [4.4, 13, 7.5, 35, 0];

// bike
key_R_U = [4.9, 17, 15, 35, 0];

keys = [
  key_L_D,
  key_L_U,
  key_R_D,
  key_R_U,
];

key_max_thickness = max([for (k = keys) k[KEY_THICKNESS]]);
