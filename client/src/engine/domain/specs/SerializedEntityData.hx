package engine.domain.specs;

import engine.domain.geometry.Vec2;
import engine.domain.types.EntityType;

/**
 * Serialized entity data for snapshot/restore
 * Contains ALL possible fields for any entity type
 * Used ONLY for serialization/memento pattern, NOT for entity creation
 * 
 * For entity creation, use specific spec types:
 * - CharacterSpec for characters
 * - ConsumableSpec for consumables  
 * - ColliderSpec for colliders
 */
typedef SerializedEntityData = {
    // Required base fields
    id: Int,
    type: EntityType,
    pos: Vec2,
    vel: Vec2,
    rotation: Float,
    ownerId: String,
    isAlive: Bool,
    
    // Optional base fields
    ?colliderWidth: Float,
    ?colliderHeight: Float,
    ?colliderOffset: Vec2,
    
    // Character fields
    ?maxHp: Int,
    ?hp: Int,
    ?level: Int,
    ?stats: Dynamic,  // CharacterStats serialized as Dynamic
    ?attackDefs: Array<Dynamic>,
    ?spellBook: Array<Dynamic>,
    ?aiProfile: String,
    ?isInputDriven: Bool,
    
    // Consumable fields
    ?effectId: String,
    ?durationTicks: Int,
    ?stackable: Bool,
    ?charges: Int,
    ?useRange: Float,
    ?consumableType: String,
    ?quantity: Int,
    ?effectValue: Dynamic,
    
    // Effect fields (for future use)
    ?effectType: String,
    ?intensity: Int,
    ?targetId: Int,
    ?casterId: Int,
    ?duration: Int,
    
    // Collider fields
    ?passable: Bool,
    ?isTrigger: Bool
}
