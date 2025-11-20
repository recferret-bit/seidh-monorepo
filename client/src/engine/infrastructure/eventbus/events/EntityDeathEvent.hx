package engine.infrastructure.eventbus.events;

class EntityDeathEvent {
    public static inline final NAME = "entity:death";
}

typedef EntityDeathEventData = {
    var tick: Int;
    var entityId: Int;
    var killerId: Int;
}

