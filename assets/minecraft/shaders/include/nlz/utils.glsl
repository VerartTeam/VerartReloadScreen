#define PI 3.14159265358


void remapLogo(int v, out vec3 pos, vec2 windowSize) {
    if (v == 0) {
        pos.x -= windowSize.x;
        pos.y -= windowSize.y * 0.5;
    } else if (v == 1) {
        pos.x -= windowSize.x * 0.5;
        pos.y += windowSize.y * 0.5;
    } else if (v == 2) {
        pos.x += windowSize.x;
        pos.y += windowSize.y * 0.5;
    } else if (v == 3) {
        pos.x += windowSize.x;
        pos.y -= windowSize.y * 0.5;
    }
}
