package game.mvp.view.entities.character.ragnar;

import game.resource.animation.character.ragnar.RagnarAnimation;
import game.mvp.view.entities.character.CharacterEntityView;

class RagnarEntityView extends CharacterEntityView {
    public function new() {
        super(new RagnarAnimation());
    }
}