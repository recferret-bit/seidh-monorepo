package engine.infrastructure.eventbus.events;

class TickCompleteEvent {
    public static inline final NAME = "tick:complete";
}

typedef TickCompleteEventData = {
    var tick: Int;
}

