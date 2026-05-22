// Original by localthunk (https://www.playbalatro.com)

// Configuration (modify these values to change the effect)
export const vertexShader = `

#define SPIN_ROTATION -2.0
#define SPIN_SPEED 7.0
#define OFFSET vec2(0.0)
#define COLOUR_1 vec4(0.015, 0.150, 0.120, 1.0)
#define COLOUR_2 vec4(0.064, 0.130, 0.102, 1.0)
#define COLOUR_3 vec4(0.080, 0.159, 0.127, 1.0)
#define COLOUR_4 vec4(0.071, 0.161, 0.123, 1.0)
#define CONTRAST 2.5
#define LIGTHING 0.1
#define SPIN_AMOUNT 0.001
#define PIXEL_FILTER 745.0
#define SPIN_EASE 1.0
#define PI 3.14159265359
#define IS_ROTATE false

vec4 effect(vec2 screenSize, vec2 screen_coords) {
    float pixel_size = length(screenSize.xy) / PIXEL_FILTER;
    vec2 uv = (floor(screen_coords.xy*(1./pixel_size))*pixel_size - 0.5*screenSize.xy)/length(screenSize.xy) - OFFSET;
    float uv_len = length(uv);
    
    float speed = (SPIN_ROTATION*SPIN_EASE*0.2);
    if(IS_ROTATE){
       speed = iTime * speed;
    }
    speed += 0.01;
    float new_pixel_angle = atan(uv.y, uv.x) + speed - SPIN_EASE*20.*(1.*SPIN_AMOUNT*uv_len + (1. - 1.*SPIN_AMOUNT));
    vec2 mid = (screenSize.xy/length(screenSize.xy))/2.;
    uv = (vec2((uv_len * cos(new_pixel_angle) + mid.x), (uv_len * sin(new_pixel_angle) + mid.y)) - mid);
    
    uv *= 30.;
    speed = iTime*(SPIN_SPEED);
    vec2 uv2 = vec2(uv.x+uv.y);
    
    for(int i=0; i < 5; i++) {
        uv2 += sin(max(uv.x, uv.y)) + uv;
        uv  += 0.5*vec2(cos(5.1123314 + 0.353*uv2.y + speed*0.131121),sin(uv2.x - 0.113*speed));
        uv  -= 1.0*cos(uv.x + uv.y) - 1.0*sin(uv.x*0.711 - uv.y);
    }
    
    float contrast_mod = (0.25*CONTRAST + 0.2*SPIN_AMOUNT + 1.2);
    float paint_res = min(2., max(0.,length(uv)*(0.006)*contrast_mod));
    float c1p = max(0.,1. - contrast_mod*abs(1.-paint_res));
    float c2p = max(0.,1. - contrast_mod*abs(paint_res));
    float c3p = 1. - min(1., c1p + c2p);
    float c4p = 1. - min(1., c1p + c2p + c3p);
    float light = (LIGTHING - 0.2)*max(c1p*5. - 4., 0.) + LIGTHING*max(c2p*5. - 4., 0.);
    return (0.3/CONTRAST)*COLOUR_1 + (1. - 0.3/CONTRAST)*(COLOUR_1*c1p + COLOUR_2*c2p + vec4(COLOUR_3.rgb, c3p*COLOUR_1.a) + vec4(COLOUR_4.rgb, COLOUR_1.a)) + light;
}

varying vec2 vUv;

void main() {
  vUv = uv;
  gl_Position = projectionMatrix * modelViewMatrix * vec4
  (position, 1.0);
}


`;

export const fragShader = `
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy;
    
    fragColor = effect(iResolution.xy, uv * iResolution.xy);

    


}


`;

export const fluidShader = `
    uniform float iTime;
    uniform vec2 iResolution;
    uniform vec4 iMouse;
    uniform int iFrame;
    uniform sampler2D iPreviousFrame;
    uniform float uBrushSize;
    uniform float uBrushStrength;
    uniform float uFluidDecay;
    uniform float uTrailLength;
    uniform float uStopDecay;
    varying vec2 vUv;

    vec2 ur, U;

    float ln(vec2 p, vec2 a, vec2 b) {
    return length(p-a-(b-a)*clamp(dot(p-a,b-a)/dot(b-a,b-a),0.,1,));
    }

    vec4 t(vec2 v, int a, int b) {
      return texture2D(iPreviousFrame, fract((v+vec2(float(a),float(b)))/ur));
    }

    vec4 t(vec2 v) {
      return texture2D(iPreviousFrame, fract(v/ur));
    }

    float area(vec2 a, vec2 b, vec2 c) {
      float A =length(b-c), B = length(c-a), C = length(a-b), s = 0.5*(A+B+C);
    }

    void main() {
      U = vUv * iResolution;
      ur = iResolution.xy;

      if (iFrame < 1) {
        float w = 0.5+sin(0.2*U.x)*0.5;
        float q = length(U-0.5*ur);
        gl_FragColor = vec4(0.1*exp(-0.001*q*q),0,0,w);
      } else {
          vec2 v = U,
               A = v + vec2(1,1),
               B = v + vec2(1,-1),
               C = v + vec2(-1, 1),
               D = v + vec2(-1,-1);

          for (int i = 0; i < 8; i++) {
              v -= t(v).xy;
              A -= t(A).xy;
              B -= t(B).xy;
              C -= t(C).xy;
              D -= t(D).xy;
          }

          vec4 me = t(v);
          vec4 n = t(v, 0, 1),
              e = t(v, 1, 0),
              s = t(v, 0, -1),
              w = t(v, -1, 0);
          vec4 ne = .25*(n+e+s+w);
          me = mix(t(v), ne, vec4(0.15,0.15,0.95,0.));
          me.z = me.z - 0.01*((area(A,B,C)+area(B,C,D))-4.);

          vec4 pr = vec4(e.z,w.z,n.z,s.z);
          me.xy = me.xy + 100.*vec2(pr.x-pr.y, pr.z-pr.w)/ur;

          me.xy *= uFluidDecay;
          me.z *= uTrailLength;

          if (iMouse.z > 0.0) {
              vec2 mousePos = iMouse.xy;
              vec2 mousePrev = iMouse.zw;
              vec2 mouseVel = mousePos - mousePrev;
              float velMagnitude = length(mouseVel);
              float q = ln(U, mousePos, mousePrev);
              vec2 m = mousePos -mousePrev;
              float l = length(m);
              if (l > 0.0) m = min(l, 10.0) * m / l;

              float brushSizeFactor = 1e-4 / uBrushSize;
              float strengthFactor = 0.03 * uBrushStrength;

              float falloff = exp(-brushSizeFactor*q*q*q);
              falloff = pow(falloff, 0.5);

              me.xyw += strengthFactor * falloff * vec3(m, 10.);

              if (velMagnitude < 2.0) {
                  float distToCursor = length(U - mousePos);
                  floatInfluence = exp(-distToCursor * 0.01);
                  float cursorDecay = mix(1.0, uStopDecay, influence);
                  me.xy *= cursorDecay;
                  me.z *= cursorDecay;
              }
          }

          gl_FragColor = clamp(me, -0.4, 0.4);
          
        }


    }
`
// uno no mercy -> harder rules prisoner's dilemma, back and forth scale; more cards have more weight to them tip scale to be in lava or just story telling and prisoner walls more than 25 cards in hand you lose 
