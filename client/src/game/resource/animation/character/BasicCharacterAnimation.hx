package game.resource.animation.character;

import engine.model.entities.types.EntityDirection;
import engine.model.entities.types.EntityState;
import engine.model.entities.types.EntityType;
import h2d.Anim;
import h2d.Tile;
import game.eventbus.GameEventBus;
import game.eventbus.events.CharacterAnimEndEvent;
import game.resource.animation.character.CharacterAnimationConfigRegistry.AnimationConfigType;

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
    
    private final defaultAnimationSpeed:Int = 10;

    public function new(entityType:EntityType) {
        this.entityType = entityType;
        animation = new h2d.Anim();

        animation.onAnimEnd = function callback() {
            // Notify event manager that animation has ended
            // Debug only
            if (characterId != null) {
                GameEventBus.instance.emit(CharacterAnimEndEvent.NAME, 
                    {
                        characterId: characterId, 
                        entityState: entityState,
                    }
                );
            }

            // Restrict animation if entity is dead
            // And notify event manager that death animation has ended
            if (entityState == EntityState.DEATH) {
                // if (characterId != null) {
                //     GameEventBus.instance.emit(CharacterDeathAnimEndEvent.NAME, { entityId: characterId });
                // }
            } else {
                // Animation has ended, so we can enable movement animation again
                // And set the animation to idle
                // if (entityState != EntityState.RUN) {
                //     changeState(EntityState.IDLE);
                // }
            }
        }

        // Load configs from registry
        idleAnimationConfig = CharacterAnimationConfigRegistry.getConfig(entityType, AnimationConfigType.IDLE);
        runAnimationConfig = CharacterAnimationConfigRegistry.getConfig(entityType, AnimationConfigType.RUN);
        spawnAnimationConfig = CharacterAnimationConfigRegistry.getConfig(entityType, AnimationConfigType.SPAWN);
        deathAnimationConfig = CharacterAnimationConfigRegistry.getConfig(entityType, AnimationConfigType.DEATH);
        actionMainAnimationConfig = CharacterAnimationConfigRegistry.getConfig(entityType, AnimationConfigType.ATTACK);
        actionSpecialAnimationConfig = CharacterAnimationConfigRegistry.getConfig(entityType, AnimationConfigType.ACTION_SPECIAL);

        loadIdleAnimation();
        loadRunAnimation();
        loadDeathAnimation();
        loadSpawnAnimation();
        loadActionMainAnimation();
        loadActionSpecialAnimation();
    }

    public function setDirection(direction:EntityDirection) {
        if (this.entityDirection != direction) {
            this.entityDirection = direction;

            function flipTilesHorizontally(animationToPlay:Array<Tile>) {
                if (animationToPlay != null) {
                    for (value in animationToPlay) {
                        value.flipX();
                    }
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
                    animation.speed = idleAnimationConfig != null ? idleAnimationConfig.speed : defaultAnimationSpeed;
                case RUN:
                    animationToPlay = runAnimation;
                    animation.speed = runAnimationConfig != null ? runAnimationConfig.speed : defaultAnimationSpeed;
                case DEATH:
                    animation.loop = false;
                    animationToPlay = deathAnimation;
                    animation.speed = deathAnimationConfig != null ? deathAnimationConfig.speed : defaultAnimationSpeed;
                case SPAWN:
                    animation.loop = false;
                    animationToPlay = spawnAnimation;
                    animation.speed = spawnAnimationConfig != null ? spawnAnimationConfig.speed : defaultAnimationSpeed;
                case ACTION_MAIN:
                    animation.loop = false;
                    animationToPlay = actionMainAnimation;
                    animation.speed = actionMainAnimationConfig != null ? actionMainAnimationConfig.speed : defaultAnimationSpeed;
                case ACTION_SPECIAL:
                    animation.loop = false;
                    animationToPlay = actionSpecialAnimation;
                    animation.speed = actionSpecialAnimationConfig != null ? actionSpecialAnimationConfig.speed : defaultAnimationSpeed;
                default:
                    animationToPlay = idleAnimation;
            }

            // Fallback to idle if animation is null
            if (animationToPlay == null) {
                animationToPlay = idleAnimation;
            }

            if (animationToPlay != null) {
                animation.play(animationToPlay);
            }
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