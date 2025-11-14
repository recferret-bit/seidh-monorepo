package game.resource.animcation;

import h2d.Anim;
import h2d.Tile;

import game.event.EventManager;
import game.resource.Res.SeidhResource;

class CharacterAnimation {
    private var idleAnim:Array<Tile>;
    private var runAnim:Array<Tile>;
    private var deathAnim:Array<Tile>;
    private var actionMainAnim:Array<Tile>;

    private var idleAnimSide = Side.RIGHT;
    private var runAnimSide = Side.RIGHT;
    private var actionMainAnimSide = Side.RIGHT;

    private var animation:Anim;
    private var characterAnimationState:CharacterAnimationState;
    private var side = Side.RIGHT;

    public var enableMoveAnimation = true;

    private var defaultAnimationSpeed = 10;
    private var runAnimationSpeed = 10;

    public function new(parent:h2d.Object, characterId:String) {
        animation = new h2d.Anim(parent);
        animation.speed = defaultAnimationSpeed;

        animation.onAnimEnd = function callback() {
            if (characterAnimationState != DEATH) {
                if (characterAnimationState != RUN) {
                    enableMoveAnimation = true;
                    setAnimationState(CharacterAnimationState.IDLE);
                }
            } else {
                EventManager.instance.notify(EventManager.EVENT_CHARACTER_DEATH_ANIM_END, characterId);
            }
        }
    }

    public function hideAnimations() {
        animation.pause = true;
    }

    public function getAnimationState() {
        return characterAnimationState;
    }

    public function setAnimationSpeed(speed:Int) {
        defaultAnimationSpeed = speed;
    }

    public function setRunAnimationSpeed(speed:Int) {
        runAnimationSpeed = speed;
    }

    public function setSide(side:Side) {
        if (this.side != side) {
            this.side = side;

            function flipTilesHorizontally(animationToPlay:Array<Tile>) {
                for (value in animationToPlay) {
                    value.flipX();
                }
            }

            flipTilesHorizontally(idleAnim);
            flipTilesHorizontally(runAnim);
            flipTilesHorizontally(actionMainAnim);
            flipTilesHorizontally(deathAnim);
        }
    }

    public function setAnimationState(newState:CharacterAnimationState) {
        if (newState != characterAnimationState) {
            characterAnimationState = newState;
            hideAnimations();

            var animationToPlay:Array<Tile>;

            switch (newState) {
                case IDLE:
                    enableMoveAnimation = true;
                    animation.loop = true;
                    animationToPlay = idleAnim;
                    animation.speed = defaultAnimationSpeed;
                case RUN:
                    enableMoveAnimation = true;
                    animation.loop = true;
                    animationToPlay = runAnim;
                    animation.speed = runAnimationSpeed;
                case DEATH:
                    enableMoveAnimation = false;
                    animation.loop = false;
                    animationToPlay = deathAnim;
                    animation.speed = defaultAnimationSpeed;
                case ACTION_MAIN:
                    enableMoveAnimation = false;
                    animation.loop = false;
                    animationToPlay = actionMainAnim;
                    animation.speed = defaultAnimationSpeed;
                default:
                    enableMoveAnimation = true;
                    animation.loop = true;
                    animationToPlay = idleAnim;
                    animation.speed = defaultAnimationSpeed;
            }

            animation.play(animationToPlay);
        }
    }

    // Load tiles

    public function loadIdle(tiles:Array<Tile>) {
        idleAnim = tiles;
    }

    public function loadRun(tiles:Array<Tile>) {
        runAnim = tiles;
    }

    public function loadDeath(tiles:Array<Tile>) {
        deathAnim = tiles;
    }

    public function loadActionMain(tiles:Array<Tile>) {
        actionMainAnim = tiles;
    }

}

class CharacterAnimations {

    public static function LoadCharacterAnimation(parent:h2d.Object, characterId:String, entrityType:EntityType) {
        final animation = new CharacterAnimation(parent, characterId);

        final th = 332;
        final tw = 332;

        var idleTile:h2d.Tile = null;
        var runTile:h2d.Tile = null;
        var attackTile:h2d.Tile = null;
        var deathTile:h2d.Tile = null;

        switch (entrityType) {
            case EntityType.RAGNAR_LOH:
                idleTile = Res.instance.getTileResource(SeidhResource.RAGNAR_IDLE);
                runTile = Res.instance.getTileResource(SeidhResource.RAGNAR_RUN);
                attackTile = Res.instance.getTileResource(SeidhResource.RAGNAR_ATTACK);
                deathTile = Res.instance.getTileResource(SeidhResource.RAGNAR_DEATH);
            case EntityType.ZOMBIE_BOY:
                idleTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_BOY_IDLE);
                runTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_BOY_RUN);
                attackTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_BOY_ATTACK);
                deathTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_BOY_DEATH);
            case EntityType.ZOMBIE_GIRL:
                idleTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_GIRL_IDLE);
                runTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_GIRL_RUN);
                attackTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_GIRL_ATTACK);
                deathTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_GIRL_DEATH);
            default:
        }

        final idleTiles = [];
        for(x in 0 ... Std.int(idleTile.width / tw)) {
            final tile = idleTile.sub(x * tw, 0, tw, th).center();
            if (entrityType == EntityType.RAGNAR_LOH) {
                tile.dx += 30;
            }
            idleTiles.push(tile);
        }
        animation.loadIdle(idleTiles);

        final runTiles = [
            for(x in 0 ... Std.int(runTile.width / tw))
                runTile.sub(x * tw, 0, tw, th).center()
        ];
        animation.loadRun(runTiles);

        final attackTiles = [
            for(x in 0 ... Std.int(attackTile.width / tw))
                attackTile.sub(x * tw, 0, tw, th).center()
        ];
        animation.loadActionMain(attackTiles);

        final deathTiles = [
            for(x in 0 ... Std.int(deathTile.width / tw))
                deathTile.sub(x * tw, 0, tw, th).center()
        ];
        animation.loadDeath(deathTiles);

        return animation;
    }

}