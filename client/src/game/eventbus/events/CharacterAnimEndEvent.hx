package game.eventbus.events;

import engine.domain.types.EntityState;

class CharacterAnimEndEvent {
    public static inline final NAME = "game:character_anim_end";
}

typedef CharacterAnimEndEventData = {
    var characterId: String;
    var entityState: EntityState;
}

