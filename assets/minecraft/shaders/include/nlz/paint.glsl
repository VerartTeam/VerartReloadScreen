#ifndef PI
#define PI 3.14159265359
#endif
#define SQRT_2 1.4142135624


vec2 transform3D(vec2 coord, vec3 axis, float theta, float perspective) {
    float c = cos(theta);
    float s = sin(theta);

    axis = normalize(axis);

    mat3 rotationMatrix = mat3(
        c + axis.x * axis.x * (1.0 - c), 
        axis.x * axis.y * (1.0 - c) - axis.z * s, 
        axis.x * axis.z * (1.0 - c) + axis.y * s,
        axis.y * axis.x * (1.0 - c) + axis.z * s, 
        c + axis.y * axis.y * (1.0 - c), 
        axis.y * axis.z * (1.0 - c) - axis.x * s,
        axis.z * axis.x * (1.0 - c) - axis.y * s, 
        axis.z * axis.y * (1.0 - c) + axis.x * s, 
        c + axis.z * axis.z * (1.0 - c)
    );

    vec3 rotatedCoord = rotationMatrix * vec3(coord, 0.);
    vec2 perspectiveCoord = (rotatedCoord.xy / (perspective - rotatedCoord.z))*perspective;

    return perspectiveCoord;
}

vec4 colorBlend(vec4 c1, vec4 c2) {
    return mix(c1, c2, c2.a);
}

vec4 introWave(vec2 uv, float t, vec4 color) {
    // f\left(x,\frac{\left(1-\cos\left(\pi d_{t}\right)\right)}{2}\right)
    // f\left(x,t\right)=t\left(\frac{\left(\sin\left(2\pi x+t\right)+\sin\left(2\pi ax+bt\right)\right)}{4}+.5\right)+t

    float dt = (1.-cos(PI*t))/2.;
    float fy = dt*((sin(2.*PI*uv.x+dt)+sin(-2.*PI*uv.x*0.8-0.5*dt))/4. + 0.5)+dt;


    float thickness = 0.1*((sin(4.*PI*t*uv.x+0.1*t+.9)+sin(-4.*PI*t*uv.x*0.8-0.05*t))/4. * 0.6 + 0.5)+.1;

    if (uv.y < fy-.2) return color;
    if (uv.y < fy-thickness) return vec4(1.0);
    return vec4(0.0, 0.0, 0.0, 0.0);

}


bool drawCircle(vec2 center, float radius, vec2 point, float rotation) {
    // Apply rotation
    vec2 rotatedPoint = vec2(
        point.x * cos(rotation) - point.y * sin(rotation),
        point.x * sin(rotation) + point.y * cos(rotation)
    );
    
    // Calculate distance from center
    float distance = length(rotatedPoint - center);
    
    // Check if point is inside the circle
    return distance <= radius;
}

bool drawRectangle(vec2 center, vec2 size, vec2 point, float rotation) {
    // Apply rotation
    vec2 rotatedPoint = vec2(
        point.x * cos(rotation) - point.y * sin(rotation),
        point.x * sin(rotation) + point.y * cos(rotation)
    );
    
    // Calculate half-size of rectangle
    vec2 halfSize = size * 0.5;
    
    // Calculate AABB
    vec2 minBound = center - halfSize;
    vec2 maxBound = center + halfSize;
    
    // Check if point is inside AABB
    return rotatedPoint.x >= minBound.x && rotatedPoint.x <= maxBound.x &&
           rotatedPoint.y >= minBound.y && rotatedPoint.y <= maxBound.y;
}

bool drawSmoothRectangle(vec2 center, vec2 size, vec2 point, float rotation, float cornerRadius) {
    // Apply rotation
    vec2 rotatedPoint = vec2(
        point.x * cos(rotation) - point.y * sin(rotation),
        point.x * sin(rotation) + point.y * cos(rotation)
    );

    // Calculate half-size of rectangle
    vec2 halfSize = size * 0.5;
    
    // Calculate AABB
    vec2 minBound = center - halfSize;
    vec2 maxBound = center + halfSize;

    // Calculate distance from center
    vec2 distance = abs(rotatedPoint - center);

    // Check if point is inside the rectangle
    if (distance.x <= halfSize.x && distance.y <= halfSize.y) {
        return true;
    }

    // Check if point is inside the corner
    if (distance.x > halfSize.x - cornerRadius && distance.y > halfSize.y - cornerRadius) {
        vec2 cornerDistance = distance - halfSize + vec2(cornerRadius);
        return length(cornerDistance) <= cornerRadius;
    }

    // Check if point is inside the rounded corner
    if (distance.x > halfSize.x - cornerRadius) {
        vec2 cornerDistance = vec2(distance.x - halfSize.x + cornerRadius, distance.y - halfSize.y);
        return length(cornerDistance) <= cornerRadius;
    }

    if (distance.y > halfSize.y - cornerRadius) {
        vec2 cornerDistance = vec2(distance.x - halfSize.x, distance.y - halfSize.y + cornerRadius);
        return length(cornerDistance) <= cornerRadius;
    }

    return false;
}



vec4 drawVerartLogo(vec2 uv) {
    #ifndef MOJ_IMPORTED
    uv = uv.yx;
    #endif

    // logo
    vec4 color = vec4(vec3(vec3(uv.x,uv.y, 0.)/2. + 0.5), 1.0);

    // circle
    // if (drawCircle(vec2(0.0, 0.0), 0.5, uv, 0.0)) {
    //     return vec4(1.0);
    // }

    // rectangle
    // if (drawRectangle(vec2(0.0, 0.0), vec2(1.5, 0.5), uv, PI/4.)) {
    //     return vec4(1.0);
    // }

    // smooth rectangle
 
    if (drawSmoothRectangle(vec2(0.0, 0.0), vec2(0.27, 1.1892), uv, PI/2., 1.)) {
        return vec4(1.0);
    }

    if (drawRectangle(vec2(-.5, 0.0), vec2(0.27, 1.1892), uv, PI/2.)) {
        return vec4(1.0);
    }

    return color;
}


vec4 verart(vec2 ScreenSize, vec2 coord, vec4 ColorModulator, float t) {

    vec2 uv = coord / ScreenSize;
    uv = uv * 2.0 - 1.0;
    vec2 uvn = uv;
    
    if (ScreenSize.x > ScreenSize.y) uv.x *= ScreenSize.x / ScreenSize.y;
    else uv.y /= ScreenSize.x / ScreenSize.y;
    uv *= 1.42;

    // bg
    vec4 fColor = vec4(mix(vec3(0, 0.69, .96),vec3(0, 0.92, 0.94), distance(uvn, vec2(-1,1))/(2.*SQRT_2)), ColorModulator.a);

    // intro wave
    fColor = introWave(uvn/2.+.5, ColorModulator.a, fColor);
    if (fColor == vec4(1.0) || fColor == vec4(0.0)) return fColor;


    #ifdef MOJ_IMPORTED
    // transform3D
    uv = -transform3D(uv, vec3(-1., 1., 0.), PI+(1.-(sin((PI/2.)*ColorModulator.a*.8+.2)))*0.4, 1.5);
    #endif

    // logo
    if (uv.x > -1. && uv.y > -1. && uv.x < 1. && uv.y < 1.) {
        // debug
        // fColor.xyz = vec3(uv.x,uv.y, 0.)/2. + 0.5;

        // logo
        fColor = drawVerartLogo(uv);

    }

    return fColor;
}


#ifndef MOJ_IMPORTED
// unused; just for shaderToy tests
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 ScreenSize = iResolution.xy;
    vec2 coord = fragCoord.xy;
    // fragColor = verart(ScreenSize, coord, vec4(1.0), iMouse.x/iResolution.x);
    fragColor = verart(ScreenSize, coord, vec4(1.0), iTime/10.);
}
#endif