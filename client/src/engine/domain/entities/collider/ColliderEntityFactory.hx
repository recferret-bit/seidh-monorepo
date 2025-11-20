package engine.domain.entities.collider;

import engine.domain.specs.ColliderSpec;

/**
 * Contract for creating collider entities
 * Uses ColliderSpec for type-safe collider creation
 */
interface ColliderEntityFactory {
    /**
     * Create collider entity from specification
     * @param spec Collider specification
     * @return Created collider entity
     */
    function create(spec: ColliderSpec): ColliderEntity;
}





