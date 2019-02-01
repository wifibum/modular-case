// create main enclosure
module shell(diameter, height, wall_thickness, base){
	translate([0, 0, height/2])
		difference() {
		    cylinder(h=height, d=diameter, center=true);
		        if(base) // remove core, keep bottom
			    	translate([0,0,wall_thickness]) cylinder(h=height, d=diameter-wall_thickness*2, center=true);
			    else // remove core, no bottom
			        cylinder(h=height+1, d=diameter-wall_thickness*2, center=true);
		}
}

// connectors to receive another module on top
// these are placed 10deg off-center -> counterparts should be placed -10deg off center
module connectors_female(angle, base_radius, height, wall_thickness) {
	width = 10; // in degrees
	rotate([0,0,angle-width]) 
		rotate_extrude(angle=width, $fn=200)
			translate([-base_radius+wall_thickness ,height-2 -0.3]) //0.3 to center scaled male pin
				polygon( points=[[0,0],[0,5],[4,5],[4,2], [1,2],[1,3],[2,4],[3,4],[3,2]], paths=[[0,1,2,3], [4,5,6,7,8]] );
}


// connectors to connect to another module below
module connectors_male(angle, base_radius, wall_thickness) {
	width = 10; // in degrees
	//pin
	rotate([0,0,angle-width]) 
		rotate_extrude(angle=width, $fn=200) 
			translate([-base_radius+wall_thickness , -2 ]) 
				translate([0.2,0]) // counteract the non-centered scale (but leave flat on build plate)
					scale([0.9,0.9]) // scale to leave room for easier connection
						polygon( points=[[0,0],[0,5],[4,5],[4,2], [1,2],[1,3],[2,4],[3,4],[3,2]], paths=[[4,5,6,7,8]] );
	// pin-base
	rotate([0,0,angle])
		rotate_extrude(angle=width, $fn=200) 
			translate([-base_radius+wall_thickness , -2 -0.3]) 
				polygon( points=[[0,2],[0,5],[4,5],[4,2], [1,2],[1,3],[2,4],[3,4],[3,2]], paths=[[0,1,2,3]] );
}
