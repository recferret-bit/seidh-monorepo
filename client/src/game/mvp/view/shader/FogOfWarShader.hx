package game.mvp.view.shader;

/**
 * Shader for fog of war effect.
 * Creates a circular transparent area in a black layer.
 * Pixels inside the circle are transparent, pixels outside remain black.
 */
class FogOfWarShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture : Sampler2D;
		@param var centerX : Float; // X position of circle center in world coordinates
		@param var centerY : Float; // Y position of circle center in world coordinates
		@param var radius : Float; // Radius of the transparent circle
		@param var objectX : Float; // X position of the object in world coordinates
		@param var objectY : Float; // Y position of the object in world coordinates
		@param var objectWidth : Float; // Width of the object
		@param var objectHeight : Float; // Height of the object
		
		function fragment() {
			// Sample the original texture
			var originalColor = texture.get(calculatedUV);
			
			// Convert UV coordinates (0-1) to world coordinates
			// UV (0,0) is top-left, so we need to map it to object bounds
			var pixelX = objectX + calculatedUV.x * objectWidth;
			var pixelY = objectY + calculatedUV.y * objectHeight;
			
			// Calculate distance from pixel to circle center
			var dx = pixelX - centerX;
			var dy = pixelY - centerY;
			var dist = sqrt(dx * dx + dy * dy);
			
			// If pixel is inside the circle, make it transparent
			// Otherwise, keep it black
			if (dist < radius) {
				// Inside circle: make transparent
				pixelColor = originalColor;
				pixelColor.a = 0.0;
			} else {
				// Outside circle: keep black
				pixelColor = originalColor;
				pixelColor.rgb = vec3(0.0, 0.0, 0.0);
				pixelColor.a = 1.0;
			}
		}
	}
}

