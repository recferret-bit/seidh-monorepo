package engine.domain.specs;

/**
 * Consumable entity specification
 * Extends base spec with consumable-specific fields
 * Used for creating consumable entities (HealthPotion, ArmorPotion, Salmon)
 */
typedef ConsumableSpec = EntitySpec & {
    // Consumable properties
    effectId: String,              // Effect identifier (e.g. "heal", "armor", "salmon")
    ?durationTicks: Int,           // Effect duration in ticks
    ?stackable: Bool,              // Can be stacked in inventory
    ?charges: Int,                 // Number of uses
    ?useRange: Float,              // Range from which item can be used
    ?quantity: Int,                // Stack quantity
    ?effectValue: Dynamic          // Effect value (Int or Float depending on effect)
}
