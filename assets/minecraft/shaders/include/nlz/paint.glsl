#define PI 3.14159265359
#define SQRT_2 1.4142135624

float rand(float n){return fract(sin(n) * 43758.5453123);}
float rand(int n){return rand(float(n));}


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
    return vec4(mix(c1, c2, c2.a).rgb, 1.0);
}

float cosInterpolate(float a, float b, float t) {
    float ft = t * PI;
    float f = (1.0 - cos(ft)) * 0.5;
    return a * (1.0 - f) + b * f;
}


float delay(float t, float d) {
    return (max(d, t)-d)/(1.-d);
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


bool drawCircle(vec2 center, float radius, vec2 uv) {
    float dist = length(uv - center);
    
    return dist <= radius;
}

bool drawRectangle(vec2 center, vec2 size, vec2 uv, float rotation) {
    vec2 halfSize = size * 0.5;
    vec2 translatedPoint = uv - center;
    
    float cosTheta = cos(rotation);
    float sinTheta = sin(rotation);
    vec2 rotatedPoint = vec2(
        translatedPoint.x * cosTheta - translatedPoint.y * sinTheta,
        translatedPoint.x * sinTheta + translatedPoint.y * cosTheta
    );
    
    rotatedPoint += center;
    
    // AABB check
    vec2 minBound = center - halfSize;
    vec2 maxBound = center + halfSize;

    return rotatedPoint.x >= minBound.x && rotatedPoint.x <= maxBound.x &&
           rotatedPoint.y >= minBound.y && rotatedPoint.y <= maxBound.y;
}


bool drawRoundedRectangle(vec2 center, vec2 size, vec2 uv, float rotation, float cornerRadius) {
    vec2 halfSize = size * 0.5;
    vec2 translatedPoint = uv - center;
    
    float cosTheta = cos(rotation);
    float sinTheta = sin(rotation);
    vec2 rotatedPoint = vec2(
        translatedPoint.x * cosTheta - translatedPoint.y * sinTheta,
        translatedPoint.x * sinTheta + translatedPoint.y * cosTheta
    );
    
    rotatedPoint += center;
    
    // AABB check
    vec2 minBound = center - halfSize;
    vec2 maxBound = center + halfSize;

    if (rotatedPoint.x >= minBound.x && rotatedPoint.x <= maxBound.x &&
        rotatedPoint.y >= minBound.y && rotatedPoint.y <= maxBound.y) {
        
        // test if in corners
        if ((rotatedPoint.x < minBound.x + cornerRadius || rotatedPoint.x > maxBound.x - cornerRadius) &&
            (rotatedPoint.y < minBound.y + cornerRadius || rotatedPoint.y > maxBound.y - cornerRadius)
        ) {
            // if (inCorner && inCircle)
            return (length(rotatedPoint - vec2(minBound.x + cornerRadius, minBound.y + cornerRadius)) <= cornerRadius ||
                length(rotatedPoint - vec2(maxBound.x - cornerRadius, minBound.y + cornerRadius)) <= cornerRadius ||
                length(rotatedPoint - vec2(minBound.x + cornerRadius, maxBound.y - cornerRadius)) <= cornerRadius ||
                length(rotatedPoint - vec2(maxBound.x - cornerRadius, maxBound.y - cornerRadius)) <= cornerRadius
            );
        }

        return true;
    }

    return false;
}


vec2 rotate(vec2 uv, float angle) {
    return vec2(
        uv.x * cos(angle) - uv.y * sin(angle),
        uv.x * sin(angle) + uv.y * cos(angle)
    );
}

vec2 translate(vec2 uv, vec2 translation) {
    return uv + translation;
}

vec2 scale(vec2 uv, vec2 scale) {
    return uv * (1./scale);
}




bool drawVerartLogoLeft(vec2 uv) {
    return ( // ruler
        drawRoundedRectangle(vec2(0., 0.), vec2(1.180, 0.263), uv, 0., 0.09)

        && !(   // ruler indicators
            drawRoundedRectangle(vec2(-0.18, 0.1), vec2(0.2, 0.053), uv, PI/2., 0.025) ||
            drawRoundedRectangle(vec2(0.0, 0.1), vec2(0.2, 0.053), uv, PI/2., 0.025) ||
            drawRoundedRectangle(vec2(0.18, 0.1), vec2(0.2, 0.053), uv, PI/2., 0.025) ||
            drawRoundedRectangle(vec2(0.36, 0.1), vec2(0.2, 0.053), uv, PI/2., 0.025)

            || (   // inner rounded ruler indicators
                drawRectangle(vec2(0.1, 0.12), vec2(0.7, 0.08), uv, 0.)  //hide
                && !(
                    drawRoundedRectangle(vec2(0.09, 0.), vec2(0.13, 0.263), uv, 0., 0.025) ||
                    drawRoundedRectangle(vec2(0.27, 0.), vec2(0.13, 0.263), uv, 0., 0.025) ||
                    drawRoundedRectangle(vec2(0.45, 0.), vec2(0.13, 0.263), uv, 0., 0.025) ||
                    drawRoundedRectangle(vec2(-0.09, 0.), vec2(0.13, 0.263), uv, 0., 0.025) ||
                    drawRoundedRectangle(vec2(-0.27, 0.), vec2(0.13, 0.263), uv, 0., 0.025)
                )
            )
        )
    );
}

bool drawVerartLogoLeftBg(vec2 uv) {
    return ( // ruler shadow
        drawRoundedRectangle(vec2(0., 0.), vec2(1.280, 0.363), uv, 0., 0.135)
        || drawRectangle(vec2(-0.15, -0.4), vec2(1.580, 0.75), uv, 0.)
    );
}

bool drawVerartLogoRightBrushCurve(vec2 uv) {
    // f\left(x\right)=-5.8281\times10^{7}x^{9}+-6.94408x^{2}+0.0259449x+0.188096
    float fy = -5.8281e7*pow(uv.x, 9.) - 6.94408*pow(uv.x, 2.) + 0.0259449*uv.x + 0.188096;

    return (
        uv.x > 0. && uv.y > 0.
        && uv.y < fy

    );
}

bool drawVerartLogoRightBrush(vec2 uv) {
    return (
        drawCircle(vec2(0., 0.), 0.106, uv)
        || drawCircle(vec2(0.154, 0.), 0.0381, uv)
        || (
            drawRectangle(vec2(0.08, 0.), vec2(.1, 0.1), uv, radians(-6.43))
            && !drawCircle(vec2(0.131, -0.0874), 0.05375, uv)
        ) || drawVerartLogoRightBrushCurve(uv.yx)
    );
}

bool drawVerartLogoRight(vec2 uv) {
    return (
        (
            drawRoundedRectangle(vec2(-0.165, 0.), vec2(1., 0.210), uv, 0., 0.075)
            && !drawRectangle(vec2(-.1, .125), vec2(1.2, 0.12), uv, radians(-6.43))
        ) || drawVerartLogoRightBrush(translate(uv, vec2(-0.49,0.)))
    );
}

bool drawPropCircle(vec2 uv) {
    return (
        drawCircle(vec2(0., 0.), 0.1, uv)
        && !drawCircle(vec2(0., 0.), 0.065, uv)
    );
}

bool drawPropSquare(vec2 uv) {
    return (
        drawRectangle(vec2(0., 0.), vec2(0.2, 0.2), uv, 0.)
        && !drawRectangle(vec2(0., 0.), vec2(0.13, 0.13), uv, 0.)
    );
}

bool drawPropCross(vec2 uv) {
    return (
        drawRectangle(vec2(0., 0.), vec2(0.2, 0.05), uv, radians(45.))
        || drawRectangle(vec2(0., 0.), vec2(0.05, 0.2), uv, radians(45.))
    );
}

bool drawRandomProp(vec2 uv, int seed) {
    switch (int(rand(seed)*3.)) {
        case 0:
            return drawPropCircle(uv);
        case 1:
            return drawPropSquare(uv);
        case 2:
            return drawPropCross(uv);
    }
}

bool drawPropsSplash(vec2 center, vec2 size, vec2 uv, float rotation, float dt, float seed) {
    // draw an expanding splash of props around the center
    
    seed = 2.*PI*seed;

    for (int i = 0 + int(seed); i < 12 + int(seed); i++) {
        float angle = radians(30. * float(i));
        vec2 iuv = rotate(uv + center + vec2(sin(seed)+sin(seed), sin(seed)*cos(seed))*0.1, angle);
        iuv = translate(
            translate(iuv, vec2(mod(rand(i), 0.2), mod(rand(i+1), 0.1)-.05)),
            vec2(0.2* cosInterpolate(0., 1., delay(dt, 0.8)), 0.)
        );
        iuv = scale(iuv, size* cosInterpolate(0., 1., delay(dt, 0.5)));


        if (drawRandomProp(iuv, i)) return true;
    }
    return false;
}

vec2 propsSplashPos[6] = vec2[6](
    vec2(.7, 0.65),
    vec2(1.5, -.9),
    vec2(-0.7, 0.5),
    vec2(-0.95, -0.85),
    vec2(-0.7, 0.3),
    vec2(-0.7, 0.3)
);

vec4 drawVerartProps(vec2 uv, float cma, float t) {
    // props
    vec4 color = vec4(vec3(1.0), 0.0);

    float dt = cosInterpolate(0., 1., cma);

    // if (drawPropsSplash(vec2(1.3, 0.8), vec2(0.2, 0.2), uv, 0., dt, t)) {
    //     color.a = min(color.a + .5, 1.0);
    // }

    for (int i = 0; i < 4; i++) {
        if (drawPropsSplash(propsSplashPos[i], vec2(0.2, 0.2), uv, 0., dt, t + float(i))) {
            color.a = min(color.a + .5, 1.0);
        }
    }

    return color;
}

vec4 drawVerartLogo(vec2 uv, float cma, float t) {
    // logo
    // vec4 color = vec4(vec3(vec3(uv.x,uv.y, 0.)/2. + 0.5), 1.0);
    vec4 color = vec4(0.0);
    float spacing = 0.2;
    float delta = -(1.-cma)*0.1;

    float leftRotDelta = cosInterpolate(0., delta*250., cma);
    vec2 uvLeft = rotate(translate(uv, vec2(0.-delta*.3, spacing-delta*0.5)), radians(27.7-leftRotDelta));
    if (drawVerartLogoLeft(uvLeft)) {
        return vec4(1.0);
    }

    float rightRotDelta = delta*100.;
    vec2 uvRight = rotate(translate(uv, vec2(0.08+delta*1.2, delta*0.7-spacing)), radians(-22.53+rightRotDelta));
    if (!drawVerartLogoLeftBg(uvLeft) && drawVerartLogoRight(uvRight)) {
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

    // props
    fColor = colorBlend(fColor, drawVerartProps(uv, ColorModulator.a, t));


    // transform3D
    uv = -transform3D(uv, vec3(-1., 1., 0.), PI+(1.-(sin((PI/2.)*ColorModulator.a*.8+.2)))*1.3, 1.5);

    // logo
    // if (uv.x > -1. && uv.y > -1. && uv.x < 1. && uv.y < 1.) 
    fColor = colorBlend(fColor, drawVerartLogo(uv, ColorModulator.a, t));
    

    return fColor;
}


#ifndef MOJ_IMPORTED
// unused; just for shaderToy tests
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 ScreenSize = iResolution.xy;
    vec2 coord = fragCoord.xy;
    // fragColor = verart(ScreenSize, coord, vec4(1.0), iMouse.x/iResolution.x);
    fragColor = verart(ScreenSize, coord, vec4(vec3(1.0), iMouse.x/iResolution.x), 0.);
}
#endif