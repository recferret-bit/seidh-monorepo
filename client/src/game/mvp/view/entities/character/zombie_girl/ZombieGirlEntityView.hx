package game.mvp.view.entities.character.zombie_girl;

import game.mvp.view.entities.character.CharacterEntityView;
import game.resource.animation.character.zombie_girl.ZombieGirlAnimation;

class ZombieGirlEntityView extends CharacterEntityView {
    public function new() {
        super(new ZombieGirlAnimation());
    }
}