package game.resource.animation;

import h2d.Anim;
import h2d.Tile;

typedef AnimationConfig = {
    /** Tile set to load the animation from */
    var tileSet:Tile;
    /** Offset in pixels for the x-axis */
    var dxOffset:Null<Int>;
    /** Offset in pixels for the y-axis */
    var dyOffset:Null<Int>;
}

abstract class BasicCharacterAnimation {

    private var characterId:String;

    private var anim:Anim;
    private var entityType:EntityType; 
    private var entityState:EntityState;
    private var entityDirection:EntityDirection;

    private var idleAnimation:Array<Tile>;
    private var runAnimation:Array<Tile>;
    private var spawnAnimation:Array<Tile>;
    private var deathAnimation:Array<Tile>;
    private var actionMainAnimation:Array<Tile>;
    private var actionSpecialAnimation:Array<Tile>;

    public function new(parent:h2d.Object, characterId:String) {
        this.characterId = characterId;
        anim = new h2d.Anim(parent);

        anim.onAnimEnd = function callback() {
            // Restrict animation if entity is dead
            // And notify event manager that death animation has ended
            if (state == EntityState.DEATH) {
                EventManager.instance.notify(EventManager.EVENT_CHARACTER_DEATH_ANIM_END, characterId);
            } else {
                // Animation has ended, so we can enable movement animation again
                // And set the animation to idle
                if (state != EntityState.RUN) {
                    changeState(EntityState.IDLE);
                }
            }
        }

        loadIdleAnimation();
        loadRunAnimation();
        loadSpawnAnimation();
        loadDeathAnimation();
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
        if (this.direction != direction) {
            this.direction = direction;

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
            pauseAnimation();

            var animationToPlay:Array<Tile>;

            anim.loop = true;

            switch (newState) {
                case IDLE:
                    animationToPlay = idleAnimation;
                case RUN:
                    anim.speed = runAnimationSpeed;
                    animationToPlay = runAnimation;
                case DEATH:
                    anim.loop = false;
                    animationToPlay = deathAnimation;
                case SPAWN:
                    anim.loop = false;
                    animationToPlay = spawnAnimation;
                case ACTION_MAIN:
                    anim.loop = false;
                    animationToPlay = actionMainAnimation;
                case ACTION_SPECIAL:
                    anim.loop = false;
                    animationToPlay = actionSpecialAnimation;
                default:
                    animationToPlay = idleAnimation;
            }

            anim.play(animationToPlay);
        }
    }

    private function loadIdleAnimation():Void {
        final idleTileConfig = provideIdleConfig();
        if (idleTileConfig == null) {
            trace('No idle tile config provided for entity type: ${entityType}');
        } else {
            idleAnimation = loadAnimationFromTileSet(idleTileConfig);
        }
    }

    private function loadRunAnimation():Void {
        final runTileConfig = provideRunConfig();
        if (runTileConfig == null) {
            trace('No run tile config provided for entity type: ${entityType}');
        } else {
            runAnimation = loadAnimationFromTileSet(runTileConfig);
        }
    }

    private function loadDeathAnimation():Void {
        final deathTileConfig = provideDeathConfig();
        if (deathTileConfig == null) {
            trace('No death tile config provided for entity type: ${entityType}');
        } else {
            deathAnimation = loadAnimationFromTileSet(deathTileConfig);
        }
    }

    private function loadSpawnAnimation():Void {
        final spawnTileConfig = provideSpawnConfig();
        if (spawnTileConfig == null) {
            trace('No spawn tile config provided for entity type: ${entityType}');
        } else {
            spawnAnimation = loadAnimationFromTileSet(spawnTileConfig);
        }
    }

    private function loadActionMainAnimation():Void {
        final actionMainTileConfig = provideActionMainConfig();
        if (actionMainTileConfig == null) {
            trace('No action main tile config provided for entity type: ${entityType}');
        } else {
            actionMainAnimation = loadAnimationFromTileSet(actionMainTileConfig);
        }
    }

    private function loadActionSpecialAnimation():Void {
        final actionSpecialTileConfig = provideActionSpecialConfig();
        if (actionSpecialTileConfig == null) {
            trace('No action special tile config provided for entity type: ${entityType}');
        } else {
            actionSpecialAnimation = loadAnimationFromTileSet(actionSpecialTileConfig);
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
}