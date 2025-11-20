package engine.domain.entities.collider;

import engine.domain.specs.ColliderSpec;

/**
 * Default implementation of the collider entity factory
 * Uses ColliderSpec for type-safe collider creation
 */
class DefaultColliderEntityFactory implements ColliderEntityFactory {
    public function new() {}

    /**
     * Create collider entity from specification
     * @param spec Collider specification
     * @return Created collider entity
     */
    public function create(spec: ColliderSpec): ColliderEntity {
        final entity = new ColliderEntity();
        entity.reset(spec);
        return entity;
    }
}
