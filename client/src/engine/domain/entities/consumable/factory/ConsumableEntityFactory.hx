package engine.domain.entities.consumable.factory;

import engine.domain.entities.consumable.base.BaseConsumableEntity;
import engine.domain.specs.ConsumableSpec;

/**
 * Contract for creating consumable entities
 * Uses ConsumableSpec for type-safe consumable creation
 */
interface ConsumableEntityFactory {
    /**
     * Create consumable entity from specification
     * @param spec Consumable specification
     * @return Created consumable entity
     */
    function create(spec: ConsumableSpec): BaseConsumableEntity;
}

