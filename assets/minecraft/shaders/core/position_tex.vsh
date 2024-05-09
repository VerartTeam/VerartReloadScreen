#version 150

in vec3 Position;
in vec2 UV0;

uniform sampler2D Sampler0;
uniform vec2 ScreenSize;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec2 texCoord0;

out float loadingScreen;

int vertexId = gl_VertexID % 4;
vec2 atlasSize = textureSize(Sampler0, 0);
vec2 onepixel = 1./atlasSize;
#define markerCoord vec2(0.0f, onepixel.y * 11.0f)

#moj_import <nlz/utils.glsl>

float isMojangLogo() {
    float flag = 0.0;

    if(atlasSize.x == 512.0) {
        vec4 testMarker = textureLod(Sampler0, markerCoord, 0);
        if(testMarker.a > 0.07 && testMarker.a < 0.08) {
            flag = 1.0;
            if(UV0.y > 0.5) return -1.0;
            else if((vertexId == 0 || vertexId == 3) && UV0.y == 0.5) return -1.0;
        }
    }

    return flag;
}

void main() {
    vec3 pos = Position;
    loadingScreen = isMojangLogo();
    if(loadingScreen > 0.0) remapLogo(vertexId, pos, ScreenSize);

    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    texCoord0 = UV0;
}
