package engine.infrastructure.eventbus.events;

import engine.domain.geometry.Vec2;

class EntityMoveEvent {
    public static inline final NAME = "entity:move";
}

typedef EntityMoveEventData = {
    var tick: Int;
    var entityId: Int;
    var pos: Vec2;
    var vel: Vec2;
    var rotation: Float;
}

