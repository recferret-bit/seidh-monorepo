package engine.domain.services;

import engine.domain.entities.BaseEntity;
import engine.domain.entities.collider.ColliderEntity;

/**
 * Domain service for collision detection rules
 * Contains collision detection business logic
 */
class CollisionService {
    
    public function new() {
    }
    
    /**
     * Check if two entities collide
     * @param entityA First entity
     * @param entityB Second entity
     * @return True if entities collide
     */
    public function checkCollision(entityA: BaseEntity, entityB: BaseEntity): Bool {
        // AABB collision detection
        final aHalfWidth = entityA.colliderWidth / 2.0;
        final aHalfHeight = entityA.colliderHeight / 2.0;
        final aCenterX = entityA.position.x + entityA.colliderOffset.x;
        final aCenterY = entityA.position.y + entityA.colliderOffset.y;
        
        final bHalfWidth = entityB.colliderWidth / 2.0;
        final bHalfHeight = entityB.colliderHeight / 2.0;
        final bCenterX = entityB.position.x + entityB.colliderOffset.x;
        final bCenterY = entityB.position.y + entityB.colliderOffset.y;
        
        // AABB collision check
        return aCenterX - aHalfWidth < bCenterX + bHalfWidth &&
               aCenterX + aHalfWidth > bCenterX - bHalfWidth &&
               aCenterY - aHalfHeight < bCenterY + bHalfHeight &&
               aCenterY + aHalfHeight > bCenterY - bHalfHeight;
    }
    
    /**
     * Check if entity collides with collider
     * @param entity Entity to check
     * @param collider Collider entity
     * @return True if entity collides with collider
     */
    public function checkColliderCollision(entity: BaseEntity, collider: ColliderEntity): Bool {
        // Skip if collider is passable
        if (collider.passable) {
            return false;
        }
        
        return checkCollision(entity, collider);
    }
    
    /**
     * Calculate separation vector for collision resolution
     * @param entityA First entity
     * @param entityB Second entity
     * @return Separation vector {x: Float, y: Float} or null if no collision
     */
    public function calculateSeparation(entityA: BaseEntity, entityB: BaseEntity): Null<{x: Float, y: Float}> {
        if (!checkCollision(entityA, entityB)) {
            return null;
        }
        
        final aHalfWidth = entityA.colliderWidth / 2.0;
        final aHalfHeight = entityA.colliderHeight / 2.0;
        final aCenterX = entityA.position.x + entityA.colliderOffset.x;
        final aCenterY = entityA.position.y + entityA.colliderOffset.y;
        
        final bHalfWidth = entityB.colliderWidth / 2.0;
        final bHalfHeight = entityB.colliderHeight / 2.0;
        final bCenterX = entityB.position.x + entityB.colliderOffset.x;
        final bCenterY = entityB.position.y + entityB.colliderOffset.y;
        
        // Calculate overlap
        final overlapX = (aHalfWidth + bHalfWidth) - Math.abs(aCenterX - bCenterX);
        final overlapY = (aHalfHeight + bHalfHeight) - Math.abs(aCenterY - bCenterY);
        
        // Determine separation direction (push entityA away from entityB)
        final separationX = aCenterX < bCenterX ? -overlapX : overlapX;
        final separationY = aCenterY < bCenterY ? -overlapY : overlapY;
        
        // Use smaller overlap for separation
        if (Math.abs(separationX) < Math.abs(separationY)) {
            return {x: separationX, y: 0};
        } else {
            return {x: 0, y: separationY};
        }
    }
}

