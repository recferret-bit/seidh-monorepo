package game.resource.animation;

import h2d.Anim;
import h2d.Tile;

import engine.model.entities.EntityDirection;
import engine.model.entities.EntityType;
import engine.model.entities.EntityState;

import game.event.EventManager;
import game.resource.Res.SeidhResource;

class CharacterAnimation {
    private var idle:Array<Tile>;
    private var run:Array<Tile>;
    private var spawn:Array<Tile>;
    private var death:Array<Tile>;
    private var actionMain:Array<Tile>;
    private var actionSpecial:Array<Tile>;

    private var anim:Anim;
    private var state:EntityState;
    private var direction = EntityDirection.RIGHT;
    private var defaultAnimationSpeed = 10;
    private var runAnimationSpeed = 10;

    public var enableMoveAnimation = true;

    public function new(parent:h2d.Object, characterId:String) {
        anim = new h2d.Anim(parent);
        anim.speed = defaultAnimationSpeed;

        anim.onAnimEnd = function callback() {
            // Restrict animation if entity is dead
            // And notify event manager that death animation has ended
            if (state == EntityState.DEATH) {
                EventManager.instance.notify(EventManager.EVENT_CHARACTER_DEATH_ANIM_END, characterId);
            } else {
                // Animation has ended, so we can enable movement animation again
                // And set the animation to idle
                if (state != EntityState.RUN) {
                    enableMoveAnimation = true;
                    setAnimationState(EntityState.IDLE);
                }
            }
        }
    }

    public function pauseAnimation() {
        anim.pause = true;
    }

    // public function getAnimationState() {
    //     return characterAnimationState;
    // }

    public function setAnimationSpeed(speed:Int) {
        defaultAnimationSpeed = speed;
    }

    public function setRunAnimationSpeed(speed:Int) {
        runAnimationSpeed = speed;
    }

    public function setDirection(direction:EntityDirection) {
        if (this.direction != direction) {
            this.direction = direction;

            function flipTilesHorizontally(animationToPlay:Array<Tile>) {
                for (value in animationToPlay) {
                    value.flipX();
                }
            }

            flipTilesHorizontally(idle);
            flipTilesHorizontally(run);
            flipTilesHorizontally(death);
            flipTilesHorizontally(actionMain);
            flipTilesHorizontally(actionSpecial);
        }
    }

    public function setAnimationState(newState:EntityState) {
        // If the new state is different from the current state, 
        // we need to pause the current animation and play the new animation
        if (newState != state) {
            state = newState;
            pauseAnimation();

            var animationToPlay:Array<Tile>;
            anim.speed = defaultAnimationSpeed;

            switch (newState) {
                case IDLE:
                    enableMoveAnimation = true;
                    anim.loop = true;
                    animationToPlay = idle;
                case RUN:
                    enableMoveAnimation = true;
                    anim.loop = true;
                    anim.speed = runAnimationSpeed;
                    animationToPlay = run;
                case DEATH:
                    enableMoveAnimation = false;
                    anim.loop = false;
                    animationToPlay = death;
                case SPAWN:
                    enableMoveAnimation = false;
                    anim.loop = false;
                    animationToPlay = spawn;
                case ACTION_MAIN:
                    enableMoveAnimation = false;
                    anim.loop = false;
                    animationToPlay = actionMain;
                case ACTION_SPECIAL:
                    enableMoveAnimation = false;
                    anim.loop = false;
                    animationToPlay = actionSpecial;
                default:
                    enableMoveAnimation = true;
                    anim.loop = true;
                    anim.speed = defaultAnimationSpeed;
                    animationToPlay = idle;
            }

            anim.play(animationToPlay);
        }
    }

    // Load tiles

    public function loadIdle(tiles:Array<Tile>) {
        idle = tiles;
    }

    public function loadRun(tiles:Array<Tile>) {
        run = tiles;
    }

    public function loadDeath(tiles:Array<Tile>) {
        death = tiles;
    }

    public function loadSpawn(tiles:Array<Tile>) {
        spawn = tiles;
    }

    public function loadActionMain(tiles:Array<Tile>) {
        actionMain = tiles;
    }

    public function loadActionSpecial(tiles:Array<Tile>) {
        actionSpecial = tiles;
    }
}

class CharacterAnimations {

    public static function LoadCharacterAnimation(parent:h2d.Object, characterId:String, entityType:EntityType) {
        final animation = new CharacterAnimation(parent, characterId);

        final th = entityType == EntityType.GLAMR ? 500 : 332;
        final tw = entityType == EntityType.GLAMR ? 500 : 332;

        var idleTile:h2d.Tile = null;
        var runTile:h2d.Tile = null;
        var deathTile:h2d.Tile = null;
        var spawnTile:h2d.Tile = null;
        var actionMainTile:h2d.Tile = null;
        var actionSpecialTile:h2d.Tile = null;

        switch (entityType) {
            case EntityType.RAGNAR:
                idleTile = Res.instance.getTileResource(SeidhResource.RAGNAR_IDLE);
                runTile = Res.instance.getTileResource(SeidhResource.RAGNAR_RUN);
                actionMainTile = Res.instance.getTileResource(SeidhResource.RAGNAR_ATTACK);
                deathTile = Res.instance.getTileResource(SeidhResource.RAGNAR_DEATH);
            case EntityType.ZOMBIE_BOY:
                idleTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_BOY_IDLE);
                runTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_BOY_RUN);
                deathTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_BOY_DEATH);
                spawnTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_BOY_SPAWN);
                actionMainTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_BOY_ATTACK);
            case EntityType.ZOMBIE_GIRL:
                idleTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_GIRL_IDLE);
                runTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_GIRL_RUN);
                deathTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_GIRL_DEATH);
                spawnTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_GIRL_SPAWN);
                actionMainTile = Res.instance.getTileResource(SeidhResource.ZOMBIE_GIRL_ATTACK);
            case EntityType.GLAMR:
                idleTile = Res.instance.getTileResource(SeidhResource.GLAMR_IDLE);
                runTile = Res.instance.getTileResource(SeidhResource.GLAMR_RUN);
                deathTile = Res.instance.getTileResource(SeidhResource.GLAMR_DEATH);
                spawnTile = Res.instance.getTileResource(SeidhResource.GLAMR_SPAWN);
                actionMainTile = Res.instance.getTileResource(SeidhResource.GLAMR_ATTACK);
                actionSpecialTile = Res.instance.getTileResource(SeidhResource.GLAMR_HAIL);
            default:
        }

        // Idle
        final idleTiles = [];
        for(x in 0 ... Std.int(idleTile.width / tw)) {
            final tile = idleTile.sub(x * tw, 0, tw, th).center();
            if (entityType == EntityType.RAGNAR) {
                tile.dx += 30;
            }
            idleTiles.push(tile);
        }
        animation.loadIdle(idleTiles);

        // Run
        final runTiles = [
            for(x in 0 ... Std.int(runTile.width / tw))
                runTile.sub(x * tw, 0, tw, th).center()
        ];
        animation.loadRun(runTiles);

        // Death
        final deathTiles = [
            for(x in 0 ... Std.int(deathTile.width / tw))
                deathTile.sub(x * tw, 0, tw, th).center()
        ];
        animation.loadDeath(deathTiles);

        // Spawn
        final spawnTiles = [
            for(x in 0 ... Std.int(spawnTile.width / tw))
                spawnTile.sub(x * tw, 0, tw, th).center()
        ];
        animation.loadSpawn(spawnTiles);

        // Action main
        final actionMainTiles = [
            for(x in 0 ... Std.int(actionMainTile.width / tw))
                actionMainTile.sub(x * tw, 0, tw, th).center()
        ];
        animation.loadActionMain(actionMainTiles);

        // Action special
        final actionSpecialTiles = [
            for(x in 0 ... Std.int(actionSpecialTile.width / tw))
                actionSpecialTile.sub(x * tw, 0, tw, th).center()
        ];
        animation.loadActionSpecial(actionSpecialTiles);

        return animation;
    }

}