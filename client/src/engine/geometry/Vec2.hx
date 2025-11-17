package engine.geometry;

/**
 * 2D Vector with deterministic operations
 */
class Vec2 {
    public var x: Int;
    public var y: Int;
    
    public function new(x: Int = 0, y: Int = 0) {
        this.x = x;
        this.y = y;
    }
    
    /**
     * Create a new vector
     */
    public static function create(x: Int, y: Int): Vec2 {
        return new Vec2(x, y);
    }
    
    /**
     * Add two vectors (returns new vector)
     */
    public static function add(a: Vec2, b: Vec2): Vec2 {
        return new Vec2(a.x + b.x, a.y + b.y);
    }
    
    /**
     * Subtract two vectors (returns new vector)
     */
    public static function sub(a: Vec2, b: Vec2): Vec2 {
        return new Vec2(a.x - b.x, a.y - b.y);
    }
    
    /**
     * Scale vector by scalar (returns new vector)
     */
    public static function scale(v: Vec2, s: Float): Vec2 {
        return new Vec2(Std.int(v.x * s), Std.int(v.y * s));
    }
    
    /**
     * Get vector length
     */
    public static function length(v: Vec2): Int {
        return Std.int(Math.sqrt(v.x * v.x + v.y * v.y));
    }
    
    /**
     * Normalize vector to unit length (returns new vector)
     */
    public static function normalize(v: Vec2): Vec2 {
        final len = length(v);
        if (len == 0) return new Vec2(0, 0);
        return new Vec2(Std.int(v.x / len), Std.int(v.y / len));
    }
    
    /**
     * Dot product of two vectors
     */
    public static function dot(a: Vec2, b: Vec2): Float {
        return a.x * b.x + a.y * b.y;
    }
    
    /**
     * Clone vector
     */
    public static function clone(v: Vec2): Vec2 {
        return new Vec2(v.x, v.y);
    }
    
    /**
     * Calculate squared distance between two points (avoids expensive sqrt)
     * @param a First point
     * @param b Second point
     * @return Squared distance in game units
     */
    public static function distanceSquared(a: Vec2, b: Vec2): Int {
        final dx = a.x - b.x;
        final dy = a.y - b.y;
        return dx * dx + dy * dy;
    }
}
