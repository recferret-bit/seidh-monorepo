package engine.domain.entities.collider;

import engine.domain.valueobjects.Position;

/**
 * Contract for creating collider entities.
 */
interface ColliderEntityFactory {
    function create(
        id: Int,
        position: Position,
        ownerId: String,
        width: Float,
        height: Float,
        passable: Bool = false,
        isTrigger: Bool = false
    ): ColliderEntity;
}




