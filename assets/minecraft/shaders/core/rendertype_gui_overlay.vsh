#version 150

in vec3 Position;
in vec4 Color;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec4 vertexColor;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    vertexColor = ivec3(Color.rgb * 255.0) == ivec3(239, 50, 61) ? vec4(vec3(0), Color.a) : Color;
}
