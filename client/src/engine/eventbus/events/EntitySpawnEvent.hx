package engine.eventbus.events;

import engine.geometry.Vec2;
import engine.model.entities.types.EntityType;

class EntitySpawnEvent {
    public static inline final NAME = "entity:spawn";
}

typedef EntitySpawnEventData = {
    var tick: Int;
    var entityId: Int;
    var type: EntityType;
    var pos: Vec2;
    var ownerId: String;
}

