package engine.domain.valueobjects;

/**
 * Immutable value object for velocity
 */
class Velocity {
    public final x: Float;
    public final y: Float;
    
    public function new(x: Float, y: Float) {
        this.x = x;
        this.y = y;
    }
    
    /**
     * Scale velocity by a factor, returning new Velocity
     */
    public function scale(factor: Float): Velocity {
        return new Velocity(x * factor, y * factor);
    }
    
    /**
     * Calculate magnitude of velocity
     */
    public function magnitude(): Float {
        return Math.sqrt(x * x + y * y);
    }
    
    /**
     * Calculate squared magnitude (avoids sqrt for performance)
     */
    public function magnitudeSquared(): Float {
        return x * x + y * y;
    }
    
    /**
     * Normalize velocity to unit length, returning new Velocity
     */
    public function normalize(): Velocity {
        final mag = magnitude();
        if (mag == 0) return new Velocity(0, 0);
        return new Velocity(x / mag, y / mag);
    }
    
    /**
     * Add another velocity, returning new Velocity
     */
    public function add(other: Velocity): Velocity {
        return new Velocity(x + other.x, y + other.y);
    }
    
    /**
     * Check if two velocities are equal
     */
    public function equals(other: Velocity): Bool {
        return x == other.x && y == other.y;
    }
    
    /**
     * Create a copy of this velocity
     */
    public function copy(): Velocity {
        return new Velocity(x, y);
    }
}

