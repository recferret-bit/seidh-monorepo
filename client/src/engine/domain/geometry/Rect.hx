package engine.domain.geometry;

/**
 * 2D Rectangle with center position and dimensions
 * Used for axis-aligned bounding box (AABB) collision detection
 */
class Rect {
    public var x: Float;      // Center X position
    public var y: Float;      // Center Y position
    public var width: Float;  // Width in units
    public var height: Float; // Height in units
    public var offset: Vec2;  // Offset from entity position
    
    public function new(x: Float = 0, y: Float = 0, width: Float = 0, height: Float = 0) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.offset = new Vec2(0, 0);
    }
    
    /**
     * Create a new rectangle
     */
    public static function create(x: Int, y: Int, width: Int, height: Int): Rect {
        return new Rect(x, y, width, height);
    }
    
    /**
     * Create rectangle from min/max bounds
     */
    public static function fromMinMax(minX: Int, minY: Int, maxX: Int, maxY: Int): Rect {
        return new Rect(
            (minX + maxX) / 2,
            (minY + maxY) / 2,
            maxX - minX,
            maxY - minY
        );
    }
    
    /**
     * Update position of this rectangle
     */
    public function setPosition(x: Float, y: Float): Void {
        this.x = x;
        this.y = y;
    }
    
    /**
     * Update size of this rectangle
     */
    public function setSize(width: Float, height: Float): Void {
        this.width = width;
        this.height = height;
    }
    
    /**
     * Get bounding box as min/max coordinates
     */
    public function getBounds(): {minX: Int, minY: Int, maxX: Int, maxY: Int} {
        final halfWidth = width / 2;
        final halfHeight = height / 2;
        return {
            minX: Std.int(x - halfWidth),
            minY: Std.int(y - halfHeight),
            maxX: Std.int(x + halfWidth),
            maxY: Std.int(y + halfHeight)
        };
    }
    
    /**
     * Check if point is inside rectangle
     */
    public function contains(point: Vec2): Bool {
        final bounds = getBounds();
        return point.x >= bounds.minX && point.x <= bounds.maxX && 
               point.y >= bounds.minY && point.y <= bounds.maxY;
    }
    
    /**
     * Check if this rectangle intersects with another rectangle (AABB collision)
     */
    public function intersectsRect(other: Rect): Bool {
        final boundsA = getBounds();
        final boundsB = other.getBounds();
        
        return boundsA.minX < boundsB.maxX && boundsA.maxX > boundsB.minX &&
               boundsA.minY < boundsB.maxY && boundsA.maxY > boundsB.minY;
    }
    
    /**
     * Check if rectangle intersects with line segment
     * Uses Liang-Barsky line clipping algorithm
     */
    public function intersectsLine(lineStart: Vec2, lineEnd: Vec2): Bool {
        final bounds = getBounds();
        
        final dx = lineEnd.x - lineStart.x;
        final dy = lineEnd.y - lineStart.y;
        
        // Handle vertical and horizontal lines
        if (dx == 0) {
            return lineStart.x >= bounds.minX && lineStart.x <= bounds.maxX &&
                   ((lineStart.y >= bounds.minY && lineStart.y <= bounds.maxY) ||
                    (lineEnd.y >= bounds.minY && lineEnd.y <= bounds.maxY) ||
                    (lineStart.y < bounds.minY && lineEnd.y > bounds.maxY));
        }
        
        if (dy == 0) {
            return lineStart.y >= bounds.minY && lineStart.y <= bounds.maxY &&
                   ((lineStart.x >= bounds.minX && lineStart.x <= bounds.maxX) ||
                    (lineEnd.x >= bounds.minX && lineEnd.x <= bounds.maxX) ||
                    (lineStart.x < bounds.minX && lineEnd.x > bounds.maxX));
        }
        
        // Liang-Barsky algorithm
        var t0 = 0.0;
        var t1 = 1.0;
        
        final p = [-dx, dx, -dy, dy];
        final q = [lineStart.x - bounds.minX, bounds.maxX - lineStart.x, 
                 lineStart.y - bounds.minY, bounds.maxY - lineStart.y];
        
        for (i in 0...4) {
            if (p[i] == 0) {
                if (q[i] < 0) return false;
            } else {
                final t = q[i] / p[i];
                if (p[i] < 0) {
                    if (t > t1) return false;
                    if (t > t0) t0 = t;
                } else {
                    if (t < t0) return false;
                    if (t < t1) t1 = t;
                }
            }
        }
        
        return t0 <= t1;
    }
    
    /**
     * Check if rectangle intersects with circle
     * Uses closest point method
     */
    public function intersectsCircle(circleCenter: Vec2, radius: Float): Bool {
        final bounds = getBounds();
        
        // Find closest point on rectangle to circle center
        final closestX = Math.max(bounds.minX, Math.min(circleCenter.x, bounds.maxX));
        final closestY = Math.max(bounds.minY, Math.min(circleCenter.y, bounds.maxY));
        
        // Calculate distance from circle center to closest point
        final dx = circleCenter.x - closestX;
        final dy = circleCenter.y - closestY;
        final distanceSquared = dx * dx + dy * dy;
        
        return distanceSquared <= radius * radius;
    }
    
    /**
     * Get intersection depth between this rectangle and another for collision resolution
     * Returns penetration vector (how much to separate)
     */
    public function getIntersectionDepth(other: Rect): Vec2 {
        final boundsA = getBounds();
        final boundsB = other.getBounds();
        
        // Calculate overlap on each axis
        final overlapX = Math.min(boundsA.maxX, boundsB.maxX) - Math.max(boundsA.minX, boundsB.minX);
        final overlapY = Math.min(boundsA.maxY, boundsB.maxY) - Math.max(boundsA.minY, boundsB.minY);
        
        // Return the smaller overlap as separation vector
        if (overlapX < overlapY) {
            // Separate on X axis
            final direction = boundsA.minX < boundsB.minX ? -1 : 1;
            return new Vec2(Std.int(overlapX * direction), 0);
        } else {
            // Separate on Y axis
            final direction = boundsA.minY < boundsB.minY ? -1 : 1;
            return new Vec2(0, Std.int(overlapY * direction));
        }
    }
    
    /**
     * Get rectangle area
     */
    public function getArea(): Float {
        return width * height;
    }
    
    /**
     * Check if rectangle is valid (positive dimensions)
     */
    public function isValid(): Bool {
        return width > 0 && height > 0;
    }
}

