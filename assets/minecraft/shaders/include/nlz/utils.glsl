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

// bool AABB(in vec2 area[2], vec2 dot) {
//     return (
//         abs(area[0].x - dot.x) + abs(area[1].x - dot.x) == abs(area[0].x - area[1].x) &&
//         abs(area[0].y - dot.y) + abs(area[1].y - dot.y) == abs(area[0].y - area[1].y)
//     );
// }

// void DrawRoughCircle(vec2 coord, in vec2 center, float radius, vec4 color, out vec4 outputColor) {
//     if(AABB(vec2[](center - vec2(radius), center + vec2(radius)), coord)){
//         vec2 dist = coord - center;
//         if(pow(dist.x, 2.0) + pow(dist.y, 2.0) < pow(radius, 2.0)) outputColor = color;
//         else outputColor = NULLCOLOR;
//     }
//     else outputColor = NULLCOLOR;
// }