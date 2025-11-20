package game.resource.animation.character.ragnar;

import game.resource.animation.character.BasicCharacterAnimation;
import engine.domain.types.EntityType;

class RagnarAnimation extends BasicCharacterAnimation {
    public function new() {
        super(EntityType.RAGNAR);
    }
}