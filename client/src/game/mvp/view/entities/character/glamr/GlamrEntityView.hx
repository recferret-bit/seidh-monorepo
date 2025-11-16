package game.mvp.view.entities.character.glamr;

import game.resource.animation.character.glamr.GlamrAnimation;
import game.mvp.view.entities.character.CharacterEntityView;

class GlamrEntityView extends CharacterEntityView {
    public function new() {
        super(new GlamrAnimation());
    }
}