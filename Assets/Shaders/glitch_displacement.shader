shader_type spatial;

uniform sampler2D texture_image;
uniform float scale = 8.0;
uniform float speed = 4.0;
uniform vec2 offset;

uniform vec4 C = vec4(0.211324865405187, // (3.0-sqrt(3.0))/6.0
                    0.366025403784439, // 0.5*(sqrt(3.0)-1.0)
                    -0.577350269189626,// -1.0 + 2.0 * C.x
                    0.024390243902439);// 1.0 / 41.0

vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

float snoise(vec2 v){
	vec2 i  = floor(v + dot(v, C.yy) );
	vec2 x0 = v -   i + dot(i, C.xx);
	vec2 i1;
	i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    
	vec4 x12 = vec4(x0,x0) + C.xxzz;
	x12.xy -= i1;
    
	i = mod(i, 289.0);
    
	vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0 ));
    
	vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), vec3(0.0));
	m = m*m ;
	m = m*m ;
    
	vec3 x = 2.0 * fract(p * C.www) - 1.0;
	vec3 h = abs(x) - 0.5;
	vec3 ox = floor(x + 0.5);
	vec3 a0 = x - ox;
    
	m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h*h);

	vec3 g;
	g.x  = a0.x  * x0.x  + h.x  * x0.y;
	g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return dot(m, g) * 66.0 + 0.5;
}

void vertex() {
    vec2 st = UV.xy + TIME/speed;
    st += offset;
    st *= scale;

    vec3 displacement = vec3(0.0);

    displacement = vec3(clamp(snoise(st),0.0,1.0));

    VERTEX.xyz += displacement.xyx * NORMAL.xyz;
}

void fragment() {
    vec2 st = UV.xy + TIME/speed;
    st += offset;
    st *= scale;

    vec4 color = textureLod( texture_image, UV.xy, 0.0 );

    color.rgb *= vec3(clamp(snoise(st),0.0,1.0));
    
    ALBEDO.rgb = color.rgb;
}