package game.resource.animation.character.glamr;

import game.resource.animation.character.BasicCharacterAnimation;
import game.resource.animation.character.BasicCharacterAnimation.AnimationConfig;
import game.resource.Res.SeidhResource;

class GlamrAnimation extends BasicCharacterAnimation {
    public function new() {
        super();
    }

    function provideIdleConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.GLAMR_IDLE),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideRunConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.GLAMR_RUN),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideSpawnConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.GLAMR_SPAWN),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideDeathConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.GLAMR_DEATH),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideActionMainConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.GLAMR_ATTACK),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }

    function provideActionSpecialConfig():AnimationConfig {
        return {
            tileSet: Res.instance.getTileResource(SeidhResource.GLAMR_HAIL),
            dxOffset: null,
            dyOffset: null,
            speed: 10
        };
    }
}