package engine.infrastructure.adapters.events.events;

class ActionResolvedEvent {
    public static inline final NAME = "action:resolved";
}

typedef ActionResolvedEventData = {
    var tick: Int;
    var actorId: Int;
    var actionType: String;
    var result: Dynamic;
}

