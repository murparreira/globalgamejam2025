shader_type canvas_item;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float grayscale = dot(color.rgb, vec3(0.299, 0.587, 0.114));  // Convert to grayscale
    COLOR = vec4(vec3(grayscale), color.a);  // Apply grayscale
}