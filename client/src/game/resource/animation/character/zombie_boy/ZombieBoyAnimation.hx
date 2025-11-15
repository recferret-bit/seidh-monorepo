package game.resource.animation.character.zombie_boy;

import game.resource.animation.character.BasicCharacterAnimation;
import game.resource.animation.character.BasicCharacterAnimation.AnimationConfig;
import game.resource.Res.SeidhResource;

class ZombieBoyAnimation extends BasicCharacterAnimation {
    public function new() {
        super();
    }

    function provideIdleConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.ZOMBIE_BOY_IDLE),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideRunConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.ZOMBIE_BOY_RUN),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideSpawnConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.ZOMBIE_BOY_SPAWN),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideDeathConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.ZOMBIE_BOY_DEATH),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideActionMainConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.ZOMBIE_BOY_ATTACK),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideActionSpecialConfig():AnimationConfig {
        return null;
    }
}