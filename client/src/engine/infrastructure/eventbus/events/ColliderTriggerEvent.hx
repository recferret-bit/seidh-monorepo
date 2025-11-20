package engine.infrastructure.eventbus.events;

import engine.domain.geometry.Vec2;

class ColliderTriggerEvent {
    public static inline final NAME = "collider:trigger";
}

typedef ColliderTriggerEventData = {
    var tick: Int;
    var entityId: Int;
    var colliderId: Int;
    var triggerPos: Vec2;
}

