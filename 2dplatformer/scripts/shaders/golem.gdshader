shader_type canvas_item;

uniform vec4 oldcolor1 : source_color;
uniform vec4 oldcolor2 : source_color;
uniform vec4 oldcolor3 : source_color;
uniform vec4 oldcolor4 : source_color;
uniform vec4 oldcolor5 : source_color;
uniform vec4 oldcolor6 : source_color;
uniform vec4 oldcolor7 : source_color;

uniform vec4 newcolor1 : source_color;
uniform vec4 newcolor2 : source_color;
uniform vec4 newcolor3 : source_color;
uniform vec4 newcolor4 : source_color;
uniform vec4 newcolor5 : source_color;
uniform vec4 newcolor6 : source_color;
uniform vec4 newcolor7 : source_color;

void fragment() {
	vec4 curr_color = texture(TEXTURE,UV);
	if(distance(curr_color,oldcolor1) < 0.1)
	{
		COLOR = newcolor1;
	}
	
	else if(distance(curr_color,oldcolor2) < 0.1)
	{
		COLOR = newcolor2;
	}
	
	else if(distance(curr_color,oldcolor3) < 0.1)
	{
		COLOR = newcolor3;
	}
	
	else if(distance(curr_color,oldcolor4) < 0.1)
	{
		COLOR = newcolor4;
	}
	
	else if(distance(curr_color,oldcolor5) < 0.1)
	{
		COLOR = newcolor5;
	}
	
	else if(distance(curr_color,oldcolor6) < 0.1)
	{
		COLOR = newcolor6;
	}
	
	else if(distance(curr_color,oldcolor7) < 0.1)
	{
		COLOR = newcolor7;
	}
	// Place fragment code here.
}
