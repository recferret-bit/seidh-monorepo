package game.resource.animation.character.ragnar;

import game.resource.animation.character.BasicCharacterAnimation;
import game.resource.animation.character.BasicCharacterAnimation.AnimationConfig;
import game.resource.Res.SeidhResource;

class RagnarAnimation extends BasicCharacterAnimation {
    public function new() {
        super();
    }

    function provideIdleConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.RAGNAR_IDLE),
            dxOffset: 30,
            dyOffset: null,
            speed: 10
        };
    }

    function provideRunConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.RAGNAR_RUN),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideSpawnConfig():AnimationConfig {
        return null;
    }

    function provideDeathConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.RAGNAR_DEATH),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideActionMainConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.RAGNAR_ATTACK),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideActionSpecialConfig():AnimationConfig {
        return null;
    }
}