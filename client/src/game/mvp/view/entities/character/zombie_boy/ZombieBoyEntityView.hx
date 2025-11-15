package game.mvp.view.entities.character.zombie_boy;

import game.resource.animation.character.zombie_boy.ZombieBoyAnimation.ZombieBoyAnimation;
import game.mvp.view.entities.character.CharacterEntityView;

class ZombieBoyEntityView extends CharacterEntityView {
    public function new() {
        super(new ZombieBoyAnimation());
    }
}