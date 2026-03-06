
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy;
    
    fragColor = effect(iResolution.xy, uv * iResolution.xy);
}
