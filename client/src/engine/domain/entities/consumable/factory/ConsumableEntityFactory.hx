package engine.domain.entities.consumable.factory;

import engine.domain.entities.consumable.base.BaseConsumableEntity;
import engine.domain.valueobjects.Position;

/**
 * Contract for creating consumable entities by type.
 */
interface ConsumableEntityFactory {
    function create(
        entityType: String,
        id: Int,
        position: Position,
        ownerId: String,
        effectId: String,
        durationTicks: Int = 0,
        stackable: Bool = false,
        charges: Int = 1,
        useRange: Float = 16.0
    ): BaseConsumableEntity;
}

