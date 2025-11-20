package game.resource.animation.character.glamr;

import game.resource.animation.character.BasicCharacterAnimation;
import engine.domain.types.EntityType;

class GlamrAnimation extends BasicCharacterAnimation {
    public function new() {
        super(EntityType.GLAMR);
    }
}