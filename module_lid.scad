// Creates an empty module

/* [Case Dimensions] */

// diameter of the base
base_diameter = 62.8; //[62.8:Small, 80:Medium, 100:Large, 130:XLarge]
// thickness of outer wall
wall_thickness = 3; //[2:1:5]
// height of the module
flat_lid_height = 10; //[10:5:100]
// generate support for male connectors
generate_support = 1; // [0: no, 1: yes]

/* [Led Options] */
// Create mount for LED
led_hole = 1; // [0: no, 1: yes]
// Diameter of LED.  Note, add .1 or .2 to ensure fit, most printers shrink holes a bit.
led_diameter = 5.2; // [2:.1:10]

/* [Hidden] */

$fn = 256;
base_radius = base_diameter / 2;
support_height_offset = 5.8;
support_width = .2;
support_arc_lenght = 4.02967;
support_arc_start_offset = 0.1727;
support_rotation_offset = 4.3175;


use <common.scad>
module flat_lid(base_radius, lid_height, wall_thickness, generate_support = generate_support, led_hole = led_hole, led_diameter = led_diameter) {
	// outer shell
	shell(base_radius*2, lid_height, wall_thickness, false);
   
    translate([0,0,lid_height - .001])
    difference()
    {
        cylinder(r = base_radius, h = wall_thickness);
        
        // led hole
        if (led_hole == 1)
            translate([0, 0,-1])
                cylinder_outer(wall_thickness +2, led_diameter/2, $fn);

    }

    if (generate_support == 1)
    {
        support(base_radius, lid_height);
        rotate(180)
            support(base_radius, lid_height);
    }
    
	// male connectors (to module below)
	connectors_male(90, base_radius, wall_thickness);
	connectors_male(270, base_radius, wall_thickness);

}

module support(base_radius, lid_height )
{
    support_helper(
        base_radius,
        lid_height,
        (-support_arc_lenght -support_arc_start_offset) / (((base_radius - 9.4) * 3.14) / 360),
        ((support_arc_lenght -support_arc_start_offset) / (((base_radius - 9.4) * 3.14) / 360)) / 11,
        -support_arc_start_offset / (((base_radius - 9.4) * 3.14) / 360),
        (-support_rotation_offset) / (((base_radius - 9.4) * 3.14) / 360));
}

module support_helper(base_radius, lid_height, start_arc, arc_inc, end_arc, cutout_rotation )
{
    for(support_location = [start_arc : arc_inc : end_arc])
    {
        rotate([0,0,support_location])
        translate([0,
            base_radius - 9.4,
            support_height_offset - .01])
                cube([support_width, 3, lid_height - support_height_offset]);
    }
    
    translate([0,
        0,
        support_height_offset - .01])
            difference()
            {
            cylinder(
                r = base_radius - 9.4 + 0.01,
                h = lid_height - support_height_offset);
            translate([0,0,-1])
            cylinder(
                r = base_radius - 9.4 + 0.01 - support_width,
                h = lid_height - support_height_offset + 2);
            rotate([0,0,cutout_rotation])
            translate([0, -base_radius, - (lid_height - support_height_offset) + .001])
            cube([base_radius * 2,
                base_radius * 2,
                (lid_height - support_height_offset) * 2]);
            translate([-base_radius * 2,
               -base_radius,
               -lid_height + support_height_offset + .001])
            cube([base_radius * 2,
                base_radius * 2,
                (lid_height - support_height_offset) * 2]);
            }
}

 module cylinder_outer(height,radius,fn){
   fudge = 1/cos(180/fn);
   cylinder(h=height,r=radius*fudge,$fn=fn);}

flat_lid(base_radius, flat_lid_height, wall_thickness);