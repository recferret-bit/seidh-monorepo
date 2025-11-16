package engine.model.entities.types;

import engine.model.entities.types.EntityType;

/**
 * Base entity specification with common fields (for creation)
 */
typedef BaseEntitySpec = {
    ?id: Int,
    ?type: EntityType,
    pos: {x: Int, y: Int},
    ?vel: {x: Int, y: Int},
    ?rotation: Float,
    ownerId: String,
    ?isAlive: Bool,
    ?isInputDriven: Bool,
    ?colliderWidth: Float,
    ?colliderHeight: Float,
    ?colliderPxOffsetX: Float,
    ?colliderPxOffsetY: Float
}

