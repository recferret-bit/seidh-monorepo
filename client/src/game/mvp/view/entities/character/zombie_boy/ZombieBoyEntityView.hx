package game.mvp.view.entities.character.zombie_boy;

import game.mvp.view.entities.character.CharacterEntityView;
import game.resource.animation.character.zombie_boy.ZombieBoyAnimation.ZombieBoyAnimation;

class ZombieBoyEntityView extends CharacterEntityView {
    public function new() {
        super(new ZombieBoyAnimation());
    }
}