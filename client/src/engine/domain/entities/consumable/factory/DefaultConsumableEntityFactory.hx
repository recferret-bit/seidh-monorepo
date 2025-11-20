package engine.domain.entities.consumable.factory;

import engine.domain.entities.consumable.base.BaseConsumableEntity;
import engine.domain.specs.ConsumableSpec;

/**
 * Default implementation of the consumable entity factory
 * Uses ConsumableSpec for type-safe consumable creation
 */
class DefaultConsumableEntityFactory implements ConsumableEntityFactory {
    public function new() {}

    /**
     * Create consumable entity from specification
     * @param spec Consumable specification
     * @return Created consumable entity
     */
    public function create(spec: ConsumableSpec): BaseConsumableEntity {
        final entity = new BaseConsumableEntity();
        entity.reset(spec);
        return entity;
    }
}
