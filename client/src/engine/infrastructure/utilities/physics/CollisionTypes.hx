package engine.infrastructure.utilities.physics;

import engine.domain.entities.BaseEntity;
import engine.domain.geometry.Rect;
import engine.domain.geometry.Vec2;

/**
 * Simple collision object interface for collision detection
 * Uses plain data structures - no dependencies on GameModelState or managers
 */
typedef CollisionObject = {
    /** Unique identifier */
    var id: Int;
    
    /** Position (center) */
    var pos: Vec2;
    
    /** Collider width in units */
    var colliderWidth: Float;
    
    /** Collider height in units */
    var colliderHeight: Float;
    
    /** Entity type (as string) - used to identify colliders */
    var type: String;
    
    /** Whether this is a collider entity */
    @:optional var isCollider: Bool;
    
    /** Whether collider is passable (only relevant if isCollider is true) */
    @:optional var passable: Bool;
    
    /** Whether collider is a trigger (only relevant if isCollider is true) */
    @:optional var isTrigger: Bool;
    
    /** Reference to the BaseEntity (for callbacks and movement correction) */
    @:optional var entity: BaseEntity;
    
    /** General collision callback - called when collision is detected */
    @:optional var onCollision: (entityA: BaseEntity, entityB: BaseEntity) -> Void;
    
    /** Callback when trigger is activated */
    @:optional var onTrigger: (otherId: Int) -> Void;
}

/**
 * Collision detection result
 */
typedef CollisionResult = {
    /** Whether collision was detected */
    var intersects: Bool;
    
    /** Collision rectangle for object A */
    var rectA: Rect;
    
    /** Collision rectangle for object B */
    var rectB: Rect;
    
    /** Separation vector for collision resolution */
    var separation: Vec2;
}

