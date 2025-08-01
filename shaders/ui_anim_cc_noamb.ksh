   ui_anim_cc_noamb      MatrixP                                                                                MatrixV                                                                                MatrixW                                                                             
   TIMEPARAMS                                FLOAT_PARAMS                            SAMPLER    +         COLOUR_XFORM                                                                                AMBIENTLIGHT                                SCREEN_PARAMS                                LIGHTMAPPOS                            CAMERARIGHT                            UI_LIGHTPARAMS                                LIGHTMAP_WORLD_EXTENTS                                ui_anim_cc_noamb.vs�  #define UI_CC
uniform mat4 MatrixP;
uniform mat4 MatrixV;
uniform mat4 MatrixW;
uniform vec4 TIMEPARAMS;
uniform vec3 FLOAT_PARAMS;

attribute vec4 POS2D_UV;                  // x, y, u + samplerIndex * 2, v

varying vec3 PS_TEXCOORD;
varying vec3 PS_POS;

#if defined( FADE_OUT )
    uniform mat4 STATIC_WORLD_MATRIX;
    varying vec2 FADE_UV;
#endif

void main()
{
    vec3 POSITION = vec3(POS2D_UV.xy, 0);
	// Take the samplerIndex out of the U.
    float samplerIndex = floor(POS2D_UV.z/2.0);
    vec3 TEXCOORD0 = vec3(POS2D_UV.z - 2.0*samplerIndex, POS2D_UV.w, samplerIndex);

	vec3 object_pos = POSITION.xyz;
	vec4 world_pos = MatrixW * vec4( object_pos, 1.0 );

	if(FLOAT_PARAMS.z > 0.0)
	{
		float world_x = MatrixW[3][0];
		float world_z = MatrixW[3][2];
		world_pos.y += sin(world_x + world_z + TIMEPARAMS.x * 3.0) * 0.025;
	}

	mat4 mtxPV = MatrixP * MatrixV;
	gl_Position = mtxPV * world_pos;


	PS_TEXCOORD = TEXCOORD0;
	PS_POS = world_pos.xyz;

#if defined( FADE_OUT )
	vec4 static_world_pos = STATIC_WORLD_MATRIX * vec4( POSITION.xyz, 1.0 );
    vec3 forward = normalize( vec3( MatrixV[2][0], 0.0, MatrixV[2][2] ) );
    float d = dot( static_world_pos.xyz, forward );
    vec3 pos = static_world_pos.xyz + ( forward * -d );
    vec3 left = cross( forward, vec3( 0.0, 1.0, 0.0 ) );

    FADE_UV = vec2( dot( pos, left ) / 4.0, static_world_pos.y / 8.0 );
#endif
}    ui_anim_cc_noamb.ps�  #define UI_CC
#if defined( GL_ES )
precision mediump float;
#endif

#if defined( TRIPLE_ATLAS )
	#define SAMPLER_COUNT 6
#elif defined( UI_CC )
	#define SAMPLER_COUNT 5
#else
	#define SAMPLER_COUNT 2
#endif

uniform sampler2D SAMPLER[SAMPLER_COUNT];

varying vec3 PS_TEXCOORD;

uniform mat4 COLOUR_XFORM;

#if defined( UI_CC )
#ifndef LIGHTING_H
#define LIGHTING_H

	uniform vec4 AMBIENTLIGHT;
	uniform vec4 SCREEN_PARAMS;
	uniform vec3 LIGHTMAPPOS;
	uniform vec3 CAMERARIGHT;
	uniform vec4 UI_LIGHTPARAMS;

	#define SCREENMAPPING_X UI_LIGHTPARAMS.x
	#define SCREENMAPPING_Y UI_LIGHTPARAMS.y
	#define START_LIGHT_HIGHT UI_LIGHTPARAMS.z
	#define MAX_LIGHT_HEIGHT_FALLOFF UI_LIGHTPARAMS.w

	#if !defined( UI_CC )
	// Lighting
	varying vec3 PS_POS;
	#endif

	// xy = min, zw = max
	uniform vec4 LIGHTMAP_WORLD_EXTENTS;

	#define LIGHTMAP_TEXTURE SAMPLER[3]
	#ifndef LIGHTMAP_TEXTURE
		#define LIGHTMAP_TEXTURE SAMPLER[0] // Fallback to first sampler
	#endif

	#ifndef LIGHTMAP_TEXTURE
		#error If you use lighting, you must #define the sampler that the lightmap belongs to
	#endif

	#if defined( UI_CC )
	vec3 CalculateLightingContribution(vec2 pos) {
		if (LIGHTMAP_WORLD_EXTENTS.zw == vec2(0.0)) {
			return vec3(1.0); // Default to white light
		}
		vec2 uv = (pos - LIGHTMAP_WORLD_EXTENTS.xy) * LIGHTMAP_WORLD_EXTENTS.zw;
		return texture2D(LIGHTMAP_TEXTURE, uv.xy).rgb;
	}
	#else
	vec3 CalculateLightingContribution() {
		if (LIGHTMAP_WORLD_EXTENTS.zw == vec2(0.0)) {
			return vec3(1.0);
		}
		vec2 uv = (PS_POS.xz - LIGHTMAP_WORLD_EXTENTS.xy) * LIGHTMAP_WORLD_EXTENTS.zw;
		return texture2D(LIGHTMAP_TEXTURE, uv.xy).rgb;
	}

	vec3 CalculateLightingContribution(vec3 normal) {
		return vec3(1.0); // Fallback to full brightness
	}
	#endif

#endif //LIGHTING.h

float quadIn_circularOut(float t) {
	return mix(
		+16.0 * pow(t, 5.0),
		0.5 * (sqrt((3.0 - 2.0 * t) * (2.0 * t - 1.0)) + 1.0),
		step(0.5, t));
}

#define COLOUR_CUBE SAMPLER[4]
#ifndef COLOURCUBE_H
#define COLOURCUBE_H

	#ifndef COLOUR_CUBE
		#error If you use colourcube, you must #define the sampler that the colourcube belongs to
	#endif

    const float CUBE_DIMENSION = 32.0;
    const float ONE_OVER_CUBE_WIDTH = 1.0 / (CUBE_DIMENSION * CUBE_DIMENSION);
    const float ONE_OVER_CUBE_HEIGHT = 1.0 / CUBE_DIMENSION;

    vec3 ApplyColourCube(vec3 colour) {
        if (CUBE_DIMENSION <= 0.0) {
            return colour; // Fallback to input color
        }

        vec3 intermediate = colour.rgb * (CUBE_DIMENSION - 1.0);
        vec2 floor_uv = vec2(
            (min(intermediate.r + 0.5, 31.0) + floor(intermediate.b) * CUBE_DIMENSION) * ONE_OVER_CUBE_WIDTH,
            1.0 - (min(intermediate.g + 0.5, 31.0) * ONE_OVER_CUBE_HEIGHT)
        );
        vec2 ceil_uv = vec2(
            (min(intermediate.r + 0.5, 31.0) + ceil(intermediate.b) * CUBE_DIMENSION) * ONE_OVER_CUBE_WIDTH,
            1.0 - (min(intermediate.g + 0.5, 31.0) * ONE_OVER_CUBE_HEIGHT)
        );

        vec3 floor_col = texture2D(COLOUR_CUBE, floor_uv.xy).rgb;
        vec3 ceil_col = texture2D(COLOUR_CUBE, ceil_uv.xy).rgb;

        return mix(floor_col, ceil_col, intermediate.b - floor(intermediate.b));
    }

#endif //COLOURCUBE.h

#endif

void main()
{
    vec4 colour;
    
	#if defined( TRIPLE_ATLAS )
		if( PS_TEXCOORD.z < 0.5 )
		{
			colour.rgba = texture2D( SAMPLER[0], PS_TEXCOORD.xy );
		}
		else if( PS_TEXCOORD.z < 1.5 )
		{
			colour.rgba = texture2D( SAMPLER[1], PS_TEXCOORD.xy );
		}
		else
		{
			colour.rgba = texture2D( SAMPLER[5], PS_TEXCOORD.xy );
		}
	#else
		if( PS_TEXCOORD.z < 1.5 )
		{
			if( PS_TEXCOORD.z < 0.5 )
			{
				colour.rgba = texture2D( SAMPLER[0], PS_TEXCOORD.xy );
			}
			else
			{
				colour.rgba = texture2D( SAMPLER[1], PS_TEXCOORD.xy );
			}
		}
	#endif

		colour = colour.rgba * COLOUR_XFORM;
		colour.rgb = min(colour.rgb, colour.a);

	#if defined( UI_CC )
		float x = (gl_FragCoord.x / SCREEN_PARAMS.x) * (SCREENMAPPING_X * 2.0) - SCREENMAPPING_X;
		float y = (gl_FragCoord.y / SCREEN_PARAMS.y) * SCREENMAPPING_Y;
		vec3 light = CalculateLightingContribution(LIGHTMAPPOS.xz + (CAMERARIGHT.xz * x));
		float falloff = quadIn_circularOut(1.0 - clamp((START_LIGHT_HIGHT + y) / MAX_LIGHT_HEIGHT_FALLOFF, 0.0, 1.0));
		colour.rgb *= max((max(light - AMBIENTLIGHT.rgb, 0.0) * falloff) + AMBIENTLIGHT.rgb, 0.4);

		gl_FragColor = vec4(ApplyColourCube(colour.rgb) * colour.a, colour.a);
	#else
		gl_FragColor = colour.rgba;
	#endif

}                                   	   
         