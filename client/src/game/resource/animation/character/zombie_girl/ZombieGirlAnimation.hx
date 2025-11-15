package game.resource.animation.character.zombie_girl;

import game.resource.animation.character.BasicCharacterAnimation;
import game.resource.animation.character.BasicCharacterAnimation.AnimationConfig;
import game.resource.Res.SeidhResource;

class ZombieGirlAnimation extends BasicCharacterAnimation {
    public function new() {
        super();
    }

    function provideIdleConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.ZOMBIE_GIRL_IDLE),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideRunConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.ZOMBIE_GIRL_RUN),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideSpawnConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.ZOMBIE_GIRL_SPAWN),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideDeathConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.ZOMBIE_GIRL_DEATH),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideActionMainConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.ZOMBIE_GIRL_ATTACK),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideActionSpecialConfig():AnimationConfig {
        return null;
    }
}