package game.resource.animation.character.zombie_boy;

import game.resource.animation.character.BasicCharacterAnimation;
import engine.domain.types.EntityType;

class ZombieBoyAnimation extends BasicCharacterAnimation {
    public function new() {
        super(EntityType.ZOMBIE_BOY);
    }
}