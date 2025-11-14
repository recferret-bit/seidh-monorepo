package game.mvp.view.shader;

class RadialGradientShader extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.Base2d;
		@param var centerIntensity : Float; // Intensity at center (0-1)
		@param var falloffPower : Float; // Controls how fast it fades (higher = faster fade)
		
		function fragment() {
			// Get UV coordinates (0-1 range)
			var uv = calculatedUV;
			
			// Calculate distance from center (0.5, 0.5)
			var center = vec2(0.5, 0.5);
			var dist = distance(uv, center);
			
			// Maximum distance for a circle in a square (from center to corner = 0.707)
			// Normalize to 0-1 where 1.0 is at the edge of the circle
			var normalizedDist = dist / 0.5; // 0.5 is the radius in UV space
			
			// Discard pixels outside the circle to remove square edges
			if (normalizedDist > 1.0) {
				discard;
			}
			
			// Calculate intensity: 1.0 at center, 0.0 at edges
			// First create smooth falloff from center to edge
			var baseIntensity = 1.0 - smoothstep(0.0, 1.0, normalizedDist);
			
			// Apply power curve for configurable falloff speed
			// Higher falloffPower = faster fade (more transparent at edges)
			// Lower falloffPower = slower fade (more gradual)
			var intensity = pow(baseIntensity, falloffPower);
			
			// Apply center intensity multiplier
			intensity = intensity * centerIntensity;
			
			// Set pixel color to white with calculated alpha
			pixelColor = vec4(1.0, 1.0, 1.0, intensity);
		}
	}
}

