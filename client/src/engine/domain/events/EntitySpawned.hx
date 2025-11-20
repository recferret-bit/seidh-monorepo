package engine.domain.events;

import engine.domain.valueobjects.Position;

/**
 * Domain event emitted when an entity is spawned
 */
class EntitySpawned {
    public final entityId: Int;
    public final entityType: String; // EntityType as string to avoid infrastructure dependency
    public final position: Position;
    public final ownerId: String;
    public final tick: Int;
    
    public function new(entityId: Int, entityType: String, position: Position, ownerId: String, tick: Int) {
        this.entityId = entityId;
        this.entityType = entityType;
        this.position = position;
        this.ownerId = ownerId;
        this.tick = tick;
    }
}

