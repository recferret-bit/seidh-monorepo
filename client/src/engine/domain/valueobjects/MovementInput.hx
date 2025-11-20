package engine.domain.valueobjects;

/**
 * Movement input value object
 */
class MovementInput {
    public final deltaX: Float;
    public final deltaY: Float;
    
    public function new(deltaX: Float, deltaY: Float) {
        this.deltaX = deltaX;
        this.deltaY = deltaY;
    }
    
    /**
     * Calculate magnitude of movement input
     */
    public function magnitude(): Float {
        return Math.sqrt(deltaX * deltaX + deltaY * deltaY);
    }
    
    /**
     * Calculate squared magnitude (avoids sqrt for performance)
     */
    public function magnitudeSquared(): Float {
        return deltaX * deltaX + deltaY * deltaY;
    }
    
    /**
     * Normalize movement input to unit length, returning new MovementInput
     */
    public function normalize(): MovementInput {
        final mag = magnitude();
        if (mag == 0) return new MovementInput(0, 0);
        return new MovementInput(deltaX / mag, deltaY / mag);
    }
    
    /**
     * Scale movement input by factor, returning new MovementInput
     */
    public function scale(factor: Float): MovementInput {
        return new MovementInput(deltaX * factor, deltaY * factor);
    }
    
    /**
     * Check if two movement inputs are equal
     */
    public function equals(other: MovementInput): Bool {
        return deltaX == other.deltaX && deltaY == other.deltaY;
    }
    
    /**
     * Create a copy of this movement input
     */
    public function copy(): MovementInput {
        return new MovementInput(deltaX, deltaY);
    }
}

