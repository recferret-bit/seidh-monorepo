package game.mvp.view.entities.character.ragnar;

import game.mvp.view.entities.character.CharacterEntityView;
import game.resource.animation.character.ragnar.RagnarAnimation;

class RagnarEntityView extends CharacterEntityView {
    public function new() {
        super(new RagnarAnimation());
    }
}