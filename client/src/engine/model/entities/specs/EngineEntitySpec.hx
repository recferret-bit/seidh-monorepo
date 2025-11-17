package engine.model.entities.specs;

/**
 * Entity specification type definitions for type-safe entity creation
 * 
 * Provides strongly-typed specifications for different entity types,
 * replacing Dynamic spec parameters with compile-time type safety.
 */

/**
 * Full entity specification extending base spec
 */
typedef EngineEntitySpec = BaseEntitySpec & {
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
    ?useRange: Int,
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

