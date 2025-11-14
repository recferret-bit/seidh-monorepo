package game.mvp.view.shader;

/**
 * Shader for fog of war effect using a texture mask.
 * Uses a mask texture with faded white pixels on black background.
 * The more white a pixel is in the mask, the more transparent the fog becomes.
 * White pixels with alpha create smooth transitions.
 */
class FogOfWarTextureShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture : Sampler2D; // The original fog of war texture (black layer)
		@param var maskTexture : Sampler2D; // The mask texture with faded white pixels
		@param var maskCenterX : Float; // X position of mask center in screen coordinates
		@param var maskCenterY : Float; // Y position of mask center in screen coordinates
		@param var maskWidth : Float; // Width of the mask texture in screen coordinates
		@param var maskHeight : Float; // Height of the mask texture in screen coordinates
		@param var objectX : Float; // X position of the object in screen coordinates
		@param var objectY : Float; // Y position of the object in screen coordinates
		@param var objectWidth : Float; // Width of the object in screen coordinates
		@param var objectHeight : Float; // Height of the object in screen coordinates
		
		function fragment() {
			// Sample the original texture
			var originalColor = texture.get(calculatedUV);
			
			// Convert UV coordinates (0-1) to world coordinates
			// UV (0,0) is top-left, so we need to map it to object bounds
			var pixelX = objectX + calculatedUV.x * objectWidth;
			var pixelY = objectY + calculatedUV.y * objectHeight;
			
			// Calculate position relative to mask center
			var relativeX = pixelX - maskCenterX;
			var relativeY = pixelY - maskCenterY;
			
			// Convert to UV coordinates in mask texture (0-1 range)
			// Center the mask at (0.5, 0.5) in UV space
			var maskU = 0.5 + (relativeX / maskWidth);
			var maskV = 0.5 + (relativeY / maskHeight);
			
			// Sample the mask texture
			var maskColor = maskTexture.get(vec2(maskU, maskV));
			
			// Calculate mask intensity from white pixels
			// Use the average of RGB channels and multiply by alpha for smooth fading
			var maskIntensity = (maskColor.r + maskColor.g + maskColor.b) / 3.0;
			maskIntensity = maskIntensity * maskColor.a;
			
			// Apply mask to fog of war
			// The more white (higher maskIntensity), the more transparent (lower alpha)
			// Clamp maskIntensity to 0-1 range
			maskIntensity = clamp(maskIntensity, 0.0, 1.0);
			
			// Set pixel color based on mask
			// maskIntensity of 1.0 = fully transparent (alpha 0.0)
			// maskIntensity of 0.0 = fully opaque black (alpha 1.0)
			pixelColor = originalColor;
			pixelColor.a = 1.0 - maskIntensity;
			
			// Keep the black color for fog, but adjust alpha based on mask
			if (maskIntensity < 1.0) {
				pixelColor.rgb = vec3(0.0, 0.0, 0.0);
			}
		}
	}
}

