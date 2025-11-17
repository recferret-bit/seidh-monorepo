package engine.model.entities.specs;

import engine.geometry.Vec2;
import engine.model.entities.types.EntityType;

/**
 * Base entity type definition
 * 
 * Used for both entity creation/specification and runtime entity data.
 * All fields are optional to support flexible entity creation, with defaults
 * applied during conversion to runtime state.
 */
typedef BaseEntitySpec = {
    ?id: Int,
    ?type: EntityType,
    pos: Vec2,
    vel: Vec2,
    ?rotation: Float,
    ownerId: String,
    ?isAlive: Bool,
    ?isInputDriven: Bool,
    ?colliderWidth: Float,
    ?colliderHeight: Float,
    ?colliderOffset: Vec2
}

