package engine.infrastructure.adapters.events.events;

class EntityDamageEvent {
    public static inline final NAME = "entity:damage";
}

typedef EntityDamageEventData = {
    var tick: Int;
    var entityId: Int;
    var damage: Int;
    var attackerId: Int;
    var newHp: Int;
}

