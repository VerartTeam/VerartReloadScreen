#version 150

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform vec2 ScreenSize;
uniform float GameTime;

in vec2 texCoord0;
in float loadingScreen;

out vec4 fragColor;

#define MOJ_IMPORTED
// #moj_i mport <nlz/logo.glsl>
#moj_import <nlz/utils.glsl>
#moj_import <nlz/paint.glsl>


void main() {
    vec4 color = texture(Sampler0, texCoord0);
    if (loadingScreen > 0.0) {
        if(gl_FragCoord.x + abs(gl_FragCoord.x - ScreenSize.x) != ScreenSize.x && gl_FragCoord.y + abs(gl_FragCoord.y - ScreenSize.y) != ScreenSize.y) discard;
        fragColor = verart(ScreenSize,gl_FragCoord.xy, ColorModulator, GameTime);
    } else if (loadingScreen < 0.0) { discard;
    } else {
        if (color.a == 0.0) discard;
        fragColor = color * ColorModulator;
    }
}

