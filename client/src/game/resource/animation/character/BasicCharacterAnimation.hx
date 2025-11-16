package game.resource.animation.character;

import game.event.EventManager;
import engine.model.entities.types.EntityDirection;
import engine.model.entities.types.EntityState;
import engine.model.entities.types.EntityType;
import h2d.Anim;
import h2d.Tile;

typedef AnimationConfig = {
    /** Tile set to load the animation from */
    var tileSet:Tile;
    /** Offset in pixels for the x-axis */
    var dxOffset:Null<Int>;
    /** Offset in pixels for the y-axis */
    var dyOffset:Null<Int>;
    /** Speed of the animation */
    var speed:Null<Int>;
}

abstract class BasicCharacterAnimation {

    private var characterId:String;

    private var animation:Anim;
    private var entityType:EntityType; 
    private var entityState:EntityState;
    private var entityDirection:EntityDirection;

    private var idleAnimationConfig:AnimationConfig;
    private var runAnimationConfig:AnimationConfig;
    private var spawnAnimationConfig:AnimationConfig;
    private var deathAnimationConfig:AnimationConfig;
    private var actionMainAnimationConfig:AnimationConfig;
    private var actionSpecialAnimationConfig:AnimationConfig;

    private var idleAnimation:Array<Tile>;
    private var runAnimation:Array<Tile>;
    private var spawnAnimation:Array<Tile>;
    private var deathAnimation:Array<Tile>;
    private var actionMainAnimation:Array<Tile>;
    private var actionSpecialAnimation:Array<Tile>;

    public function new() {
        animation = new h2d.Anim();

        animation.onAnimEnd = function callback() {
            // Notify event manager that animation has ended
            // Debug only
            if (characterId != null) {
                EventManager.instance.notify(EventManager.EVENT_CHARACTER_ANIM_END, characterId);
            }

            // Restrict animation if entity is dead
            // And notify event manager that death animation has ended
            if (entityState == EntityState.DEATH) {
                if (characterId != null) {
                    EventManager.instance.notify(EventManager.EVENT_CHARACTER_DEATH_ANIM_END, characterId);
                }
            } else {
                // Animation has ended, so we can enable movement animation again
                // And set the animation to idle
                // if (entityState != EntityState.RUN) {
                //     changeState(EntityState.IDLE);
                // }
            }
        }

        idleAnimationConfig = provideIdleConfig();
        runAnimationConfig = provideRunConfig();
        spawnAnimationConfig = provideSpawnConfig();
        deathAnimationConfig = provideDeathConfig();
        actionMainAnimationConfig = provideActionMainConfig();
        actionSpecialAnimationConfig = provideActionSpecialConfig();

        loadIdleAnimation();
        loadRunAnimation();
        loadDeathAnimation();
        loadSpawnAnimation();
        loadActionMainAnimation();
        loadActionSpecialAnimation();
    }

    abstract function provideIdleConfig():AnimationConfig;
    abstract function provideRunConfig():AnimationConfig;
    abstract function provideSpawnConfig():AnimationConfig;
    abstract function provideDeathConfig():AnimationConfig;
    abstract function provideActionMainConfig():AnimationConfig;
    abstract function provideActionSpecialConfig():AnimationConfig;

    public function setDirection(direction:EntityDirection) {
        if (this.entityDirection != direction) {
            this.entityDirection = direction;

            function flipTilesHorizontally(animationToPlay:Array<Tile>) {
                for (value in animationToPlay) {
                    value.flipX();
                }
            }

            flipTilesHorizontally(idleAnimation);
            flipTilesHorizontally(runAnimation);
            flipTilesHorizontally(deathAnimation);
            flipTilesHorizontally(spawnAnimation);
            flipTilesHorizontally(actionMainAnimation);
            flipTilesHorizontally(actionSpecialAnimation);
        }
    }

    public function changeState(newState:EntityState) {
        if (entityState != newState) {
            entityState = newState;
            animation.pause = true;

            var animationToPlay:Array<Tile>;

            animation.loop = true;

            switch (newState) {
                case IDLE:
                    animationToPlay = idleAnimation;
                    animation.speed = idleAnimationConfig.speed;
                case RUN:
                    animationToPlay = runAnimation;
                    animation.speed = runAnimationConfig.speed;
                case DEATH:
                    animation.loop = false;
                    animationToPlay = deathAnimation;
                    animation.speed = deathAnimationConfig.speed;
                case SPAWN:
                    animation.loop = false;
                    animationToPlay = spawnAnimation;
                    animation.speed = spawnAnimationConfig.speed;
                case ACTION_MAIN:
                    animation.loop = false;
                    animationToPlay = actionMainAnimation;
                    animation.speed = actionMainAnimationConfig.speed;
                case ACTION_SPECIAL:
                    animation.loop = false;
                    animationToPlay = actionSpecialAnimation;
                    animation.speed = actionSpecialAnimationConfig.speed;
                default:
                    animationToPlay = idleAnimation;
            }

            animation.play(animationToPlay);
        }
    }

    private function loadIdleAnimation():Void {
        if (idleAnimationConfig == null) {
            trace('No idle tile config provided for entity type: ${entityType}');
        } else {
            idleAnimation = loadAnimationFromTileSet(idleAnimationConfig);
        }
    }

    private function loadRunAnimation():Void {
        if (runAnimationConfig == null) {
            trace('No run tile config provided for entity type: ${entityType}');
        } else {
            runAnimation = loadAnimationFromTileSet(runAnimationConfig);
        }
    }

    private function loadDeathAnimation():Void {
        if (deathAnimationConfig == null) {
            trace('No death tile config provided for entity type: ${entityType}');
        } else {
            deathAnimation = loadAnimationFromTileSet(deathAnimationConfig);
        }
    }

    private function loadSpawnAnimation():Void {
        if (spawnAnimationConfig == null) {
            trace('No spawn tile config provided for entity type: ${entityType}');
        } else {
            spawnAnimation = loadAnimationFromTileSet(spawnAnimationConfig);
        }
    }

    private function loadActionMainAnimation():Void {
        if (actionMainAnimationConfig == null) {
            trace('No action main tile config provided for entity type: ${entityType}');
        } else {
            actionMainAnimation = loadAnimationFromTileSet(actionMainAnimationConfig);
        }
    }

    private function loadActionSpecialAnimation():Void {
        if (actionSpecialAnimationConfig == null) {
            trace('No action special tile config provided for entity type: ${entityType}');
        } else {
            actionSpecialAnimation = loadAnimationFromTileSet(actionSpecialAnimationConfig);
        }
    }

    private function loadAnimationFromTileSet(animationConfig:AnimationConfig):Array<Tile> {
        final tiles:Array<Tile> = [];
        // Get the tile width and height, assuming the tile set is a square
        final tw = animationConfig.tileSet.height;
        final th = animationConfig.tileSet.height;
        for(x in 0 ... Std.int(animationConfig.tileSet.width / tw)) {
            final tile = animationConfig.tileSet.sub(x * tw, 0, tw, th).center();
            if (animationConfig.dxOffset != null) {
                tile.dx += animationConfig.dxOffset;
            }
            if (animationConfig.dyOffset != null) {
                tile.dy += animationConfig.dyOffset;
            }
            tiles.push(tile);
        }
        return tiles;
    }

    // Getters

    public function getAnimation():Anim {
        return animation;
    }

    // Setters

    public function setCharacterId(characterId:String) {
        this.characterId = characterId;
    }
}