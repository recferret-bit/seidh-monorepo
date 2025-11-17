package engine.eventbus.events;

class SnapshotEvent {
    public static inline final NAME = "snapshot";
}

typedef SnapshotEventData = {
    var tick: Int;
    var serializedState: Dynamic;
}

