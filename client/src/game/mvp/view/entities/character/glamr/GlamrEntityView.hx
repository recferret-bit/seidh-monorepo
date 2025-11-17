package game.mvp.view.entities.character.glamr;

import game.mvp.view.entities.character.CharacterEntityView;
import game.resource.animation.character.glamr.GlamrAnimation;

class GlamrEntityView extends CharacterEntityView {
    public function new() {
        super(new GlamrAnimation());
    }
}