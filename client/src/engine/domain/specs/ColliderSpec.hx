package engine.domain.specs;

/**
 * Collider entity specification
 * Extends base spec with collider-specific fields
 * Used for creating collider entities (walls, barriers, triggers)
 */
typedef ColliderSpec = EntitySpec & {
    // Collider properties
    ?passable: Bool,    // Can entities pass through this collider
    ?isTrigger: Bool    // Is this a trigger zone (events fire but no collision)
}
