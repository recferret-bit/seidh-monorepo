package engine.infrastructure.eventbus.events;

import engine.domain.geometry.Vec2;

class EntityCollisionEvent {
    public static inline final NAME = "entity:collision";
}

typedef EntityCollisionEventData = {
    var tick: Int;
    var entityIdA: Int;
    var entityIdB: Int;
    var contactPoint: Vec2;
    var normal: Vec2;
}

