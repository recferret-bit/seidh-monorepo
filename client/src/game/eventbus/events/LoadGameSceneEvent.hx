package game.eventbus.events;

class LoadGameSceneEvent {
    public static inline final NAME = "game:load_game_scene";
}

typedef LoadGameSceneEventData = {
    // No payload needed for scene loading events
}

