package game.eventbus.events;

class LoadHomeSceneEvent {
    public static inline final NAME = "game:load_home_scene";
}

typedef LoadHomeSceneEventData = {
    // No payload needed for scene loading events
}

