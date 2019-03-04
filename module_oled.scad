// Creates a module with a oled display
/* [Case Dimensions] */

// diameter of the base
base_diameter = 62.8; //[62.8:Small, 80:Medium, 100:Large, 130:XLarge]
// thickness of outer wall
wall_thickness = 3; //[2:1:5]
// enable rim
enable_rim = 0; // [0: No, 1: Yes]
// rim height
rim_height = 1.5; // [.5: .1: 2]

/* [OLED Dimensions] */

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



/* [Hidden] */
$fn = 128;
base_radius = base_diameter / 2;

frame = 1; // plastic frame around pcb


use <common.scad>
use <module_empty.scad>

module cutOuter(radius, module_height)
{
	intersection(){
		children();
		cylinder(r=radius, h=module_height);
	}
}

module cutInner(radius, module_height)
{
	difference(){
		children();
		cylinder(r=radius, h=module_height);
	}
}

function oled_module_height() = oled_pcb_height + 2*wall_thickness + 2*frame;

module oled(base_radius, wall_thickness, oled_width, oled_height, oled_pcb_width, oled_pcb_height, oled_y_position) {
	// lock minimum module height

	rotate([0,0,180])
	union() {
		difference(){
			union(){
				//base
	    		empty(base_radius, oled_module_height(), wall_thickness, enable_rim, rim_height);
	    		//frame
	    		cutInner(base_radius - 2.5*wall_thickness, oled_module_height()){
		    		cutOuter(base_radius - wall_thickness, oled_module_height()){
			    		translate([5, -(oled_pcb_width/2 + wall_thickness/2),  frame])
			    			cube([base_radius, oled_pcb_width + wall_thickness, oled_pcb_height + 2*wall_thickness]);
			    	};
		    	};
	    	}
	    	// display cutout
	    	translate([5, -oled_width/2, oled_y_position + wall_thickness +frame])
		    	cube([base_radius, oled_width, oled_height]);
		    // pcb cutout
			translate([0, -oled_pcb_width/2, wall_thickness +frame])
		    	cube([base_radius- 1.5*wall_thickness, oled_pcb_width, oled_pcb_height]);
		    // outer recess
		    translate([base_radius- 1*wall_thickness,-oled_width/2 - 2, oled_y_position + wall_thickness +frame -2])
		    	cube([base_radius- 2*wall_thickness, oled_width+4, oled_height+4]);
		    //chamfer bottom
		    translate([base_radius- 1*wall_thickness,-oled_width/2 - 2, oled_y_position + oled_height + 4+ wall_thickness +frame -2])
		    	rotate([0,30,0])
		    		cube([base_radius- 2*wall_thickness, oled_width+4, oled_height+4]);
		    //chamfer top
		    translate([base_radius- 1*wall_thickness,-oled_width/2 - 2, oled_y_position + wall_thickness +frame -2])
		    	rotate([0,60,0])
		    		cube([base_radius- 2*wall_thickness, oled_width+4, oled_height+4]);
		    //chamfer left
		    translate([base_radius- 1*wall_thickness,-oled_width/2 - 2, oled_y_position + wall_thickness +frame -2])
		    	rotate([0,0,-60])
		    		cube([base_radius- 2*wall_thickness, oled_width+4, oled_height+4]);
		    //chamfer right
		    translate([base_radius- 1*wall_thickness,+oled_width/2 + 2, oled_y_position + wall_thickness +frame -2])
		    	rotate([0,0,-30])
		    		cube([base_radius- 2*wall_thickness, oled_width+4, oled_height+4]);
		}
	}
}

oled(base_radius, wall_thickness, oled_width, oled_height, oled_pcb_width, oled_pcb_height, oled_y_position);
