package engine.domain.events;

import engine.domain.valueobjects.Health;

/**
 * Domain event emitted when damage is dealt to an entity
 */
class DamageDealt {
    public final entityId: Int;
    public final attackerId: Int;
    public final damage: Int;
    public final newHealth: Health;
    public final tick: Int;
    
    public function new(entityId: Int, attackerId: Int, damage: Int, newHealth: Health, tick: Int) {
        this.entityId = entityId;
        this.attackerId = attackerId;
        this.damage = damage;
        this.newHealth = newHealth;
        this.tick = tick;
    }
}

