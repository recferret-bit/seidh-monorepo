package engine.domain.specs;

import engine.domain.geometry.Vec2;
import engine.domain.types.EntityType;

/**
 * Base entity specification
 * Contains fields common to ALL entity types
 * 
 * For entity-specific fields, use:
 * - CharacterSpec for character entities
 * - ConsumableSpec for consumable entities
 * - ColliderSpec for collider entities
 * 
 * For serialization, use SerializedEntityData (memento pattern)
 */
typedef EntitySpec = {
    // Identity
    ?id: Int,
    type: EntityType,
    
    // Position and movement
    pos: Vec2,
    vel: Vec2,
    ?rotation: Float,
    
    // Ownership and state
    ownerId: String,
    ?isAlive: Bool,
    
    // Collision bounds
    ?colliderWidth: Float,
    ?colliderHeight: Float,
    ?colliderOffset: Vec2
}
