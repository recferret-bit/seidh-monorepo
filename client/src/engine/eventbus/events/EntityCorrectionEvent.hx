package engine.eventbus.events;

import engine.geometry.Vec2;

class EntityCorrectionEvent {
    public static inline final NAME = "entity:correction";
}

typedef EntityCorrectionEventData = {
    var tick: Int;
    var entityId: Int;
    var correctedPos: Vec2;
    var correctedVel: Vec2;
}

