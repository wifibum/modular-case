// Unfortunately, customizable parameters have to be in the main file,
// although they are used in the libraries

/* [Case Dimensions] */

// diameter of the base
base_diameter = 62.8; //[62.8:Small, 80:Medium, 100:Large, 130:XLarge]
// thickness of outer wall
wall_thickness = 3; //[2:1:5]

/* [Base Module] */

//type of uC
board = 0; //[0: Custom, 1:Arduino_Nano, 2:Arduino_Mega, 3:Arduino_Uno, 4:Feather_HUZZAH, 5:NodeMCUv2, 6:NodeMCUv3, 7:Raspberry_Pi_ZeroW]

// width of a PCB (only for Custom)
board_width = 26; //[10:0.1:150]
// length of a PCB  (only for Custom)
board_length = 48; //[10:0.1:150]

/* [Access Port Dimensions (only for Custom)] */

// width of the port hole for e.g. USB access
port_width = 10; //[5:1:50]
// height of the port hole for e.g. USB access
port_height = 6; //[4:1:30]
// position from left edge of board to middle of port
port_ypos = 5; //[0:1:150]
// position from bottom of pcb (negative is below)
port_zpos = 0; //[-25:1:30]

/* [Empty Module] */

// create an empty module
create_empty = false;

// height of the empty module
empty_height = 30; // [10:1:60]

/* [OLED Module] */
create_oled = true;

// width of the display
oled_width = 26; //[10:1:100]
// height of the display
oled_height = 13; //[10:1:100]
// width of the pcb
oled_pcb_width = 27; //[10:1:100]
// height of the pcb
oled_pcb_height = 27; //[10:1:100]
//position of the display (lower edge)
oled_y_position = 6.5;

/* [Sensor enclosure] */
create_enclosure = true;

// height of the enclosure module
enclosure_module_height = 18; //[18:1:100]
// thickness of outer wall
enclosure_wall_thickness = 2; //[2:1:5]
// height of the enclosure
enclosure_height = 15; //[12:1:100]
// length of the enclosure
enclosure_length = 40; //[10:1:100]
// width of the enclosure
enclosure_width = 25; //[10:1:100]
// radius of port access
enclosure_port_radius = 4; //[2:1:20]

/* [Lid Type] */
// Lid
lid_type = 2; // [0: none, 1: dome, 2: flat]

/* [Dome Cap Dimensions] */
// thickness of dome
cap_dome_thickness = 1.5; //[2:0.5:5]
// height of the dome cap
cap_dome_height = 10; //[10:1:100]

/* [Flat Lid Dimensions] */
flat_lid_height = 10; //[10:1:100]
// generate support for male connectors
generate_support = 0; // [0: no, 1: yes]

/* [Led Options] */
// Create mount for LED
led_hole = 1; // [0: no, 1: yes]
// Diameter of LED.  Note, add .1 or .2 to ensure fit, most printers shrink holes a bit.
led_diameter = 5.2; // [2:.1:10]

/* [Hidden] */

$fn = 128;
base_radius = base_diameter / 2;
base_color = "CornflowerBlue";
module_color = "CornflowerBlue";
cap_color = "Snow";

use <base.scad>
use <module_empty.scad>
use <module_oled.scad>
use <module_enclosure.scad>
use <module_lid.scad>
use <cap_dome.scad>

enclosure_module_start = create_empty?base_height()+empty_height:base_height();
oled_module_start = create_enclosure?enclosure_module_start+enclosure_module_height:enclosure_module_start;
dome_cap_start = create_oled?oled_module_start+oled_module_height():oled_module_start;

union() {
	color(base_color)
		base(base_radius, wall_thickness, board, port_width, port_height, port_ypos, port_zpos);

	if (create_empty)
		translate([0,0,base_height()])
			color(module_color)
				empty(base_radius, empty_height, wall_thickness);

    if (create_enclosure)
		translate([0,0,enclosure_module_start])
			color(module_color)
				sensor_enclosure(enclosure_length, enclosure_width, base_radius, enclosure_module_height, enclosure_height, enclosure_wall_thickness, enclosure_port_radius);

	if (create_oled)
		translate([0,0,oled_module_start])
			color(module_color)
				oled(base_radius, wall_thickness, oled_width, oled_height, oled_pcb_width, oled_pcb_height, oled_y_position);

    if (lid_type == 1)
		translate([0,0,dome_cap_start])
			color(cap_color)
				dome(base_radius, cap_dome_height, wall_thickness, cap_dome_thickness);
    
    if (lid_type == 2)
		translate([0,0,dome_cap_start])
			color(cap_color)
                flat_lid(base_radius, flat_lid_height, wall_thickness, generate_support,  led_hole, led_diameter);        
}
