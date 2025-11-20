package engine.domain.events;

import engine.domain.valueobjects.Position;

/**
 * Domain event emitted when an entity moves
 */
class EntityMoved {
    public final entityId: Int;
    public final fromPosition: Position;
    public final toPosition: Position;
    public final tick: Int;
    
    public function new(entityId: Int, fromPosition: Position, toPosition: Position, tick: Int) {
        this.entityId = entityId;
        this.fromPosition = fromPosition;
        this.toPosition = toPosition;
        this.tick = tick;
    }
}

