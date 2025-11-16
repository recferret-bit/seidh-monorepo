package engine.model.entities.types;

import engine.geometry.Vec2;
import engine.model.entities.types.EntityType;

/**
 * Base entity data structure with all common fields
 */
typedef BaseEntityData = {
    id: Int,
    type: EntityType,
    pos: Vec2,
    vel: Vec2,
    rotation: Float,
    ownerId: String,
    isAlive: Bool,
    isInputDriven: Bool,
    colliderWidth: Float,
    colliderHeight: Float,
    colliderPxOffsetX: Float,
    colliderPxOffsetY: Float
}

