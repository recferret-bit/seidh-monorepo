package game.config;

enum ResourceProvider {
    LOCAL;
	YANDEX_S3;
}

/**
 * Game client configuration wrapper around EngineConfig
 * Provides game-specific settings and visual configuration
 */
class GameClientConfig {
    public static final DefaultResourceProvider = ResourceProvider.LOCAL;
    public static final DefaultVisualSettings = new VisualSettings();
}

/**
 * Visual settings for rendering
 */
class VisualSettings {
    public var drawPhysicsShapes: Bool;
    public var drawHealthBars: Bool;
    
    // Entity colors
    public var colorPlayer: Int;
    public var colorAcolyte: Int;
    public var colorMonster: Int;
    public var colorConsumable: Int;
    public var colorEffect: Int;
    public var colorPhysicsShape: Int;
    
    public function new() {

        drawPhysicsShapes = true;
        drawHealthBars = true;
        
        // Default colors
        colorPlayer = 0x00FF00;      // Green
        colorAcolyte = 0x0088FF;     // Blue
        colorMonster = 0xFF0000;     // Red
        colorConsumable = 0xFFFF00;  // Yellow
        colorEffect = 0xFF00FF;      // Magenta
        colorPhysicsShape = 0xFFFF00; // Yellow (debug)
    }

}
