package game.mvp.view.shader;

class NormalMapShader extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.Base2d;
		@param var normalMap : Sampler2D;
		@param var lightPos : Vec3;
		@param var lightColor : Vec3;
		@param var lightIntensity : Float;
		@param var ambientLight : Float;
		
		function fragment() {
			// Sample the normal map
			var normal = normalMap.get(calculatedUV).rgb;
			// Convert from [0,1] to [-1,1] range
			normal = normal * 2.0 - 1.0;
			normal.z = abs(normal.z); // Ensure z points outward
			normal = normalize(normal);
			
			// Calculate light direction in screen space
			var pixelPos = vec3(absolutePosition.xy, 0.0);
			var lightDir = lightPos - pixelPos;
			var distance = length(lightDir);
			lightDir = normalize(lightDir);
			
			// Calculate diffuse lighting using normal map
			var diffuse = max(dot(normal, lightDir), 0.0);
			
			// Apply attenuation (inverse square law)
			var attenuation = lightIntensity / (1.0 + distance * distance * 0.001);
			
			// Combine lighting: ambient (white) + diffuse (colored)
			var diffuseLight = diffuse * attenuation * lightColor;
			var totalLight = vec3(ambientLight, ambientLight, ambientLight) + diffuseLight;
			
			// Apply lighting to pixel color
			pixelColor.rgb *= totalLight;
		}
	}
}
