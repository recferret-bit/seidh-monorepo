package engine.infrastructure.eventbus.events;

class ActionIntentEvent {
    public static inline final NAME = "action:intent";
}

typedef ActionIntentEventData = {
    var tick: Int;
    var actorId: Int;
    var actionType: String;
    var target: Dynamic;
}

