// Creates the enclosure base with space for a PCB and access to its ports.

/* [Case Dimensions] */

// diameter of the base
base_diameter = 62.8; //[62.8:Small, 80:Medium, 100:Large, 130:XLarge]
// thickness of outer wall
wall_thickness = 3; //[2:1:5]
// enable rim
enable_rim = 0; // [0: No, 1: Yes]
// rim height
rim_height = 1.5; // [.5: .1: 2]


/* [PCB Dimensions] */

//type of uC
board = 0; //[0: Custom, 1:Arduino_Nano, 2:Arduino_Mega, 3:Arduino_Uno, 4:Feather_HUZZAH, 5:NodeMCUv2, 6:NodeMCUv3, 7:Raspberry_Pi_ZeroW]

// width of a PCB (only for Custom)
board_width = 26; //[10:0.1:150]
// length of a PCB  (only for Custom)
board_length = 48; //[10:0.1:150]
// Enable snap in standoff for board
snapin_support = 1; // [0: No, 1: Yes]

/* [Access Port Dimensions (only for Custom)] */

// width of the port hole for e.g. USB access
port_width = 10; //[5:1:50]
// height of the port hole for e.g. USB access
port_height = 6; //[4:1:30]
// position from left edge of board to middle of port
port_ypos = 5; //[0:1:150]
// position from bottom of pcb (negative is below)
port_zpos = 0; //[-25:1:30]


/* [Hidden] */

$fn = 128;

base_radius = base_diameter / 2;

use <common.scad>

function base_height() = 30; //fixed, but needs to be fine-tuned to pcb+pins+connectors+bending radius of cables
standoff_height = 12;
standoff_width = wall_thickness;
ground_clearance = 5;
snap_fit_clearance = .3;

// a single standoff with a small rest to keep a board from the ground
// height: overall height; width: wall-thickness and nook,
// clearance: height from ground
module single_standoff(height, width, clearance) {
	render() { // to get rid off the interference
		translate([0,0,wall_thickness]) {
			union() {
				// outer pillars
				difference() {
					cube([width+wall_thickness, width+wall_thickness, height]);
                    if (snapin_support)
                    {
	                    cube([width, standoff_width, clearance + 2]);
                        snap_fit_cutout(width, height, clearance);
                    }
                    else
                    {
                        cube([width, standoff_width, height]);
                    }
                }
				// inner board rest
				translate([width, width, 0])
					rotate([0,0,180])
						intersection() {
							cylinder(h = clearance, r = width, center = false);
							cube([width, width, height]);
				}
			}
		}
	}
}

module snap_fit_cutout(width, height, clearance)
{
 translate([0,0,clearance + 2])
  polyhedron(
    points = [
  [  0,                         0,                          0 ],  //0
  [ width,                      0,                          0 ],  //1
  [ width,                      width,                      0 ],  //2
  [  0,                         width,                      0 ],  //3
  [  0,                         0,                          snap_fit_clearance ],  //4
  [ width - snap_fit_clearance, 0,                          snap_fit_clearance ],  //5
  [ width - snap_fit_clearance, width - snap_fit_clearance, snap_fit_clearance ],  //6
  [  0,                         width - snap_fit_clearance, snap_fit_clearance ],  //7
  [  0,                         0,                          height - clearance - 2],  //8
  [ width + .2,                 0,                          height - clearance - 2],  //9
  [ width + .2,                 width + .2,                 height - clearance - 2],  //10
  [  0,                         width + .2,                 height - clearance - 2]], //11
    faces = [
  [0,1,2,3],  // bottom
  [4,5,1,0],  // bottom front
  [5,6,2,1],  // bottom right
  [6,7,3,2],  // bottom back
  [7,4,0,3], // bottom left
  [8,9,5,4],  // top front
  [9,10,6,5],  // top right
  [10,11,7,6],  // top back
  [11,8,4,7], // top left
  [11,10,9,8]]);  // top
}

// place 4 standoffs around a rectangular board space
module standoffs(length, width, clearance) {
	translate([(length/2) - standoff_width, (width/2) - standoff_width])
		rotate([0,0,0])
			single_standoff(standoff_height, standoff_width, clearance);

	translate([(length/2) - standoff_width, -(width/2) + standoff_width])
		rotate([0,0,270])
			single_standoff(standoff_height, standoff_width, clearance);

	translate([-(length/2) + standoff_width, -(width/2) + standoff_width])
		rotate([0,0,180])
			single_standoff(standoff_height, standoff_width, clearance);

	translate([-(length/2) + standoff_width, (width/2) - standoff_width])
		rotate([0,0,90])
			single_standoff(standoff_height, standoff_width, clearance);
}

// cut a recess with port access into base
// parameters are length/width of port access hole
module port_access(base_radius, length, height, port_ypos, port_zpos, board_length, board_width) {
	difference() {
		union() {
			children(); // <- the rest of the model
			// add new inner wall
			intersection() { // cut everything not inside the original enclosure shape
				// same as base
				translate([0, 0, base_height()/2])
					cylinder(h = base_height(), d = base_radius*2, center = true);
				// recess
				translate([board_length/2, -(2*base_radius+5)/2, 0]) {
					cube([base_radius+5, 2*base_radius+5, ground_clearance + wall_thickness + 1 + height + 1]);
				// slope
				translate([0, 0, ground_clearance + wall_thickness + 1 + height + 1])
					rotate([0,60,0])
						cube([base_radius, 2*base_radius+5, base_radius]);
				}
			}
		}
		// cut outer overhang
		translate([board_length/2 + wall_thickness, -(2*base_radius+5)/2, -1]) {
			cube([base_radius - board_length/2 + 5, 2*base_radius+5, ground_clearance + wall_thickness + 1 + height + 2]);
		}
		// cut slope
		translate([board_length/2 + wall_thickness, -(2*base_radius+5)/2, ground_clearance + wall_thickness + 1 + height + 1])
			rotate([0,60,0])
				cube([base_radius - board_length/2 + 5, 2*base_radius+5, base_radius]);
		// cut port hole
		translate([board_length/2 - 1, -board_width/2 - length/2 + port_ypos, wall_thickness + ground_clearance +port_zpos])
			cube([50, length, height]);
	}
}

// main housing of the uC
module _base(base_radius, wall_thickness, board_length, board_width, port_width, port_height, port_ypos, port_zpos) {
	port_access(base_radius, port_width, port_height, port_ypos, port_zpos, board_length, board_width) {
		union() {
			difference() {
                union()
                {
                    shell(base_radius*2, base_height(), wall_thickness, true);
                    connectors_female(90, base_radius, base_height(), wall_thickness);
                    connectors_female(270, base_radius, base_height(), wall_thickness);
                }
				venting_holes(0, base_radius, base_height(), 10, 5, true);
			};

			// board dummy
			%translate([-board_length/2, -board_width/2, ground_clearance + wall_thickness])
				cube([board_length, board_width, 2]);

			standoffs(board_length, board_width, ground_clearance);
            if (enable_rim == 1)
                rim(base_radius, base_height(), wall_thickness, [90, 270], rim_height);
		}
	}
}

module base(base_radius, wall_thickness, board, port_width, port_height, port_ypos, port_zpos) {
	// board dimensions database (unique variables needed due to language restrictions)
	board_size1 = board==0?[board_width, board_length]:[1,1]; //custom
	board_size2 = board==1?[ 45   , 18   ]:board_size1; // Arduino_Nano
	board_size3 = board==2?[ 68.6 , 53.3 ]:board_size2; // Arduino_Uno
	board_size4 = board==3?[101.52, 53.4 ]:board_size3; // Arduino_Mega
	board_size5 = board==4?[ 51   , 23   ]:board_size4; // Feather_HUZZAH
	board_size6 = board==5?[ 48   , 26   ]:board_size5; // NodeMCUv2
	board_size7 = board==6?[ 51   , 31   ]:board_size6; // NodeMCUv3
	board_size8 = board==7?[ 65   , 30   ]:board_size7; // Raspberry_Pi_ZeroW

	board_size = board_size8; // use last variable from table above here

	//port dimensions [width, height, ypos, zpos]
	port1 = board==0?[port_width, port_height, port_ypos, port_zpos]:[10,16,5,0]; //custom
	port2 = board==1?[ 1,1,1,1 ]:port1; // Arduino_Nano
	port3 = board==2?[ 1,1,1,1 ]:port2; // Arduino_Uno
	port4 = board==3?[ 1,1,1,1 ]:port3; // Arduino_Mega
	port5 = board==4?[ 1,1,1,1 ]:port4; // Feather_HUZZAH
	port6 = board==5?[ 10, 7, 13  , -4.5 ]:port5; // NodeMCUv2
	port7 = board==6?[ 10, 7, 15.5, -4.5 ]:port6; // NodeMCUv3
	port8 = board==7?[ 1,1,1,1   ]:port7; // Raspberry_Pi_ZeroW

	port = port8; // use last variable from table above here

	_base(base_radius, wall_thickness, board_size[0], board_size[1], port[0], port[1], port[2], port[3]);
}

base(base_radius, wall_thickness, board, port_width, port_height, port_ypos, port_zpos);

