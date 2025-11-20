package engine.domain.valueobjects;

/**
 * Immutable value object for position
 * Uses Float for domain precision
 */
class Position {
    public final x: Float;
    public final y: Float;
    
    public function new(x: Float, y: Float) {
        this.x = x;
        this.y = y;
    }
    
    /**
     * Add delta values to position, returning new Position
     */
    public function add(dx: Float, dy: Float): Position {
        return new Position(x + dx, y + dy);
    }
    
    /**
     * Calculate distance to another position
     */
    public function distanceTo(other: Position): Float {
        final dx = other.x - x;
        final dy = other.y - y;
        return Math.sqrt(dx * dx + dy * dy);
    }
    
    /**
     * Calculate squared distance (avoids sqrt for performance)
     */
    public function distanceSquaredTo(other: Position): Float {
        final dx = other.x - x;
        final dy = other.y - y;
        return dx * dx + dy * dy;
    }
    
    /**
     * Check if two positions are equal
     */
    public function equals(other: Position): Bool {
        return x == other.x && y == other.y;
    }
    
    /**
     * Create a copy of this position
     */
    public function copy(): Position {
        return new Position(x, y);
    }
}

