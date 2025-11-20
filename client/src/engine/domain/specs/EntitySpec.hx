package engine.domain.specs;

import engine.domain.geometry.Vec2;
import engine.domain.types.EntityType;

/**
 * Base entity specification type definition
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

/**
 * Full entity specification extending base spec
 * Provides strongly-typed specifications for different entity types,
 * replacing Dynamic spec parameters with compile-time type safety.
 */
typedef EntitySpec = BaseEntitySpec & {
    // Character fields
    ?maxHp: Int,
    ?hp: Int,
    ?level: Int,
    ?stats: {power: Int, armor: Int, speed: Int, castSpeed: Int},
    ?attackDefs: Array<Dynamic>,
    ?spellBook: Array<Dynamic>,
    ?aiProfile: String,
    // Consumable fields
    ?effectId: String,
    ?durationTicks: Int,
    ?stackable: Bool,
    ?charges: Int,
    ?useRange: Float,
    ?consumableType: String,
    ?quantity: Int,
    ?effectValue: Dynamic, // Can be Int or Float depending on context
    // Effect fields
    ?effectType: String,
    ?intensity: Int,
    ?targetId: Int,
    ?casterId: Int,
    ?duration: Int,
    // Collider fields
    ?passable: Bool,
    ?isTrigger: Bool
}
