#version 330 compatibility

#include "/lib/common.glsl"

uniform float viewWidth;
uniform int worldTime;
uniform float viewHeight;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform vec3 skyColor;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D colortex0;
uniform sampler2D colortex15;
ivec2 atlasSize = textureSize(colortex15, 0);

float dayTime = worldTime * (3.141592 / 12000);
vec3 sunDir = vec3(cos(dayTime), sin(dayTime), 0);

#include "/lib/vx/raytrace.glsl"

void main() {
    vec2 texCoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    vec4 screenPos = vec4(texCoord * 2 - 1, 0.99, 1);
    vec4 viewPos = gbufferProjectionInverse * screenPos;
    vec4 playerPos = gbufferModelViewInverse * viewPos;
    playerPos /= playerPos.w;
    vec3 pos = fract(cameraPosition) - 0.5;
    vec3 normal = 30 * normalize(playerPos.xyz);//-30 * normalize(mat3(gbufferModelViewInverse) * (vec3(-gl_FragCoord.xy, 0.9) / vec3(viewHeight, viewHeight, 1) + vec3(0.5, 0.5, 0)));
    vec4 col = roundTrace(pos, normal, colortex15);
    col.rgb = mix(skyColor * skyColor, col.rgb, col.a);
    pos -= 0.03 * normal;
    /*RENDERTARGETS:0*/
    gl_FragData[0] = vec4(sqrt(col.xyz), col.a);
}