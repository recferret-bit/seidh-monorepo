package engine.physics;

import engine.geometry.Rect;
import engine.geometry.Vec2;
import engine.physics.CollisionTypes.CollisionObject;
import engine.physics.CollisionTypes.CollisionResult;

/**
 * Standalone collision detection system
 * Works with plain arrays and data structures - no dependencies on GameModelState or managers
 */
class CollisionDetector {
    
    public function new() {
    }
    
    /**
     * Detect and resolve collisions for an array of collision objects
     * @param objects Array of collision objects to check
     * @return Array of collision results (only for collisions that occurred)
     */
    public function detectCollisions(objects: Array<CollisionObject>): Array<{objA: CollisionObject, objB: CollisionObject, result: CollisionResult}> {
        final results = [];
        
        // Simple AABB collision detection with broad-phase distance filtering
        for (i in 0...objects.length) {
            for (j in i + 1...objects.length) {
                final a = objects[i];
                final b = objects[j];
                
                // Broad-phase: Use actual collider dimensions for more precise collision detection
                final rectA = a.entity != null ? a.entity.colliderRect : null;
                final rectB = b.entity != null ? b.entity.colliderRect : null;
                
                if (rectA == null || rectB == null) {
                    continue;
                }
                
                // Calculate maximum possible distance between collider centers
                final maxDistanceX = (rectA.width + rectB.width) / 2;
                final maxDistanceY = (rectA.height + rectB.height) / 2;
                final maxDistanceSquared = maxDistanceX * maxDistanceX + maxDistanceY * maxDistanceY;
                
                // Calculate actual distance between collider centers
                final dx = rectA.x - rectB.x;
                final dy = rectA.y - rectB.y;
                final distanceSquared = dx * dx + dy * dy;
                
                // Skip collision check if entities are too far apart
                if (distanceSquared > maxDistanceSquared) {
                    continue;
                }
                
                final collisionResult = checkCollision(a, b);
                if (collisionResult.intersects) {
                    results.push({objA: a, objB: b, result: collisionResult});
                    resolveCollision(a, b, collisionResult);
                }
            }
        }
        
        return results;
    }
    
    /**
     * Check if two objects are colliding
     * @param a First collision object
     * @param b Second collision object
     * @return Collision result with intersection info and rectangles
     */
    public function checkCollision(a: CollisionObject, b: CollisionObject): CollisionResult {
        // Use collider rectangles from entities (already updated and positioned)
        final rectA = a.entity != null ? a.entity.colliderRect : null;
        final rectB = b.entity != null ? b.entity.colliderRect : null;
        
        if (rectA == null || rectB == null) {
            final unitPixels = SeidhEngine.Config.unitPixels;

            // Fallback: create temporary rects if entities don't have colliderRect
            final colliderAWidth = Std.int(a.colliderWidth * unitPixels);
            final colliderAHeight = Std.int(a.colliderHeight * unitPixels);
            final colliderBWidth = Std.int(b.colliderWidth * unitPixels);
            final colliderBHeight = Std.int(b.colliderHeight * unitPixels);
            
            final fallbackRectA = new Rect(a.pos.x, a.pos.y, colliderAWidth, colliderAHeight);
            final fallbackRectB = new Rect(b.pos.x, b.pos.y, colliderBWidth, colliderBHeight);
            
            final intersects = fallbackRectA.intersectsRect(fallbackRectB);
            final separation = intersects ? fallbackRectA.getIntersectionDepth(fallbackRectB) : new Vec2(0, 0);
            
            return {
                intersects: intersects,
                rectA: fallbackRectA,
                rectB: fallbackRectB,
                separation: separation
            };
        }
        
        final intersects = rectA.intersectsRect(rectB);
        final separation = intersects ? rectA.getIntersectionDepth(rectB) : new Vec2(0, 0);
        
        return {
            intersects: intersects,
            rectA: rectA,
            rectB: rectB,
            separation: separation
        };
    }
    
    /**
     * Resolve collision between two objects
     * @param a First collision object
     * @param b Second collision object
     * @param result Collision result with separation vector
     */
    private function resolveCollision(a: CollisionObject, b: CollisionObject, result: CollisionResult): Void {
        // Get entity references
        final entityA = a.entity;
        final entityB = b.entity;
        
        // Call general collision callback if provided
        if (a.onCollision != null && entityA != null && entityB != null) {
            a.onCollision(entityA, entityB);
        }
        if (b.onCollision != null && entityA != null && entityB != null) {
            b.onCollision(entityA, entityB);
        }
        
        // Check if either object is a collider
        final aIsCollider = a.isCollider == true || a.type == "collider";
        final bIsCollider = b.isCollider == true || b.type == "collider";
        
        // If either object is a collider, we need to prevent them from moving into each other
        if (aIsCollider || bIsCollider) {
            final collider = aIsCollider ? a : b;
            final entity = aIsCollider ? b : a;
            final colliderEntity = collider.entity;
            final movingEntity = entity.entity;
            
            // If collider is not passable, we need to prevent the entity from moving into it
            if (collider.passable != true && movingEntity != null) {
                // Apply movement correction directly to the entity
                movingEntity.applyMovementCorrection(result.separation);
            }
            
            // Handle collider trigger
            if (collider.isTrigger == true) {
                if (collider.onTrigger != null && movingEntity != null) {
                    collider.onTrigger(movingEntity.id);
                }
            }
        }
    }
}

