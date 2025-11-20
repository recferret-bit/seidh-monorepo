package engine.domain.events;

/**
 * Domain event emitted when an entity dies
 */
class EntityDied {
    public final entityId: Int;
    public final killerId: Int;
    public final tick: Int;
    
    public function new(entityId: Int, killerId: Int, tick: Int) {
        this.entityId = entityId;
        this.killerId = killerId;
        this.tick = tick;
    }
}

