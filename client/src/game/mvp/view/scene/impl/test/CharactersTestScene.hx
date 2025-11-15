package game.mvp.view.scene.impl.test;

import game.mvp.view.entities.character.zombie_girl.ZombieGirlEntityView;
import game.mvp.view.entities.character.zombie_boy.ZombieBoyEntityView;
import game.mvp.view.entities.character.CharacterEntityView;
import engine.model.entities.EntityState;
import h2d.Bitmap;

import game.mvp.view.entities.character.ragnar.RagnarEntityView;
import game.mvp.view.scene.basic.BasicScene;
import game.event.EventManager;

class CharactersTestScene extends BasicScene implements EventListener {
    private var bitmaps:Array<Bitmap> = [];

    private final charactersMap:Map<String, CharacterEntityView> = new Map();

    public function new() {
        super();

        EventManager.instance.subscribe(EventManager.EVENT_CHARACTER_ANIM_END, this);
        
        // ------------------------------------
        // Ragnar
        // ------------------------------------

        final ragnarIdle = new RagnarEntityView();
        ragnarIdle.setPosition(150, 150);
        ragnarIdle.changeState(EntityState.IDLE);
        ragnarIdle.getAnimation().setCharacterId("ragnarIdle");
        addChild(ragnarIdle);
        charactersMap.set("ragnarIdle", ragnarIdle);

        final ragnarRun = new RagnarEntityView();
        ragnarRun.setPosition(150 + (332 / 2), 150);
        ragnarRun.changeState(EntityState.RUN);
        ragnarRun.getAnimation().setCharacterId("ragnarRun");
        addChild(ragnarRun);
        charactersMap.set("ragnarRun", ragnarRun);

        final ragnarDeath = new RagnarEntityView();
        ragnarDeath.setPosition(150 + (332), 150);
        ragnarDeath.changeState(EntityState.DEATH);
        ragnarDeath.getAnimation().setCharacterId("ragnarDeath");
        addChild(ragnarDeath);
        charactersMap.set("ragnarDeath", ragnarDeath);

        final ragnarActionMain = new RagnarEntityView();
        ragnarActionMain.setPosition(150 + (332 * 1.5), 150);
        ragnarActionMain.changeState(EntityState.ACTION_MAIN);
        ragnarActionMain.getAnimation().setCharacterId("ragnarActionMain");
        addChild(ragnarActionMain);
        charactersMap.set("ragnarActionMain", ragnarActionMain);

        // ------------------------------------
        // Zombie Boy
        // ------------------------------------

        final zombieBoyIdle = new ZombieBoyEntityView();
        zombieBoyIdle.setPosition(150, 332 * 1.5);
        zombieBoyIdle.changeState(EntityState.IDLE);
        zombieBoyIdle.getAnimation().setCharacterId("zombieBoyIdle");
        addChild(zombieBoyIdle);
        charactersMap.set("zombieBoyIdle", zombieBoyIdle);

        final zombieBoyRun = new ZombieBoyEntityView();
        zombieBoyRun.setPosition(150 + (332 / 2), 332 * 1.5);
        zombieBoyRun.changeState(EntityState.RUN);
        zombieBoyRun.getAnimation().setCharacterId("zombieBoyRun");
        addChild(zombieBoyRun);
        charactersMap.set("zombieBoyRun", zombieBoyRun);

        final zombieBoyDeath = new ZombieBoyEntityView();
        zombieBoyDeath.setPosition(150 + (332), 332 * 1.5);
        zombieBoyDeath.changeState(EntityState.DEATH);
        zombieBoyDeath.getAnimation().setCharacterId("zombieBoyDeath");
        addChild(zombieBoyDeath);
        charactersMap.set("zombieBoyDeath", zombieBoyDeath);

        final zombieBoySpawn = new ZombieBoyEntityView();
        zombieBoySpawn.setPosition(150 + (332 * 1.5), 332 * 1.5);
        zombieBoySpawn.changeState(EntityState.SPAWN);
        zombieBoySpawn.getAnimation().setCharacterId("zombieBoySpawn");
        addChild(zombieBoySpawn);
        charactersMap.set("zombieBoySpawn", zombieBoySpawn);

        final zombieBoyActionMain = new ZombieBoyEntityView();
        zombieBoyActionMain.setPosition(150 + (332 * 2), 332 * 1.5);
        zombieBoyActionMain.changeState(EntityState.ACTION_MAIN);
        zombieBoyActionMain.getAnimation().setCharacterId("zombieBoyActionMain");
        addChild(zombieBoyActionMain);
        charactersMap.set("zombieBoyActionMain", zombieBoyActionMain);

        // ------------------------------------
        // Zombie Girl
        // ------------------------------------

        final zombieGirlIdle = new ZombieGirlEntityView();
        zombieGirlIdle.setPosition(150, 332 * 2.5); 
        zombieGirlIdle.changeState(EntityState.IDLE);
        zombieGirlIdle.getAnimation().setCharacterId("zombieGirlIdle");
        addChild(zombieGirlIdle);
        charactersMap.set("zombieGirlIdle", zombieGirlIdle);
    }

    public function start():Void {
        trace("CharactersTestScene started");
    }

    public function destroy():Void {
        trace("CharactersTestScene destroyed");
    }

    public function customUpdate(dt:Float, fps:Float):Void {
        trace("CharactersTestScene customUpdate");
    }

    public function notify(event:String, params:Dynamic) {
        switch (event) {
            case EventManager.EVENT_CHARACTER_ANIM_END: {
                final characterId = params;

                switch (characterId) {
                    case "ragnarDeath": {
                        charactersMap.get("ragnarDeath").changeState(EntityState.IDLE);
                        charactersMap.get("ragnarDeath").changeState(EntityState.DEATH);
                    }
                    case "ragnarActionMain": {
                        charactersMap.get("ragnarActionMain").changeState(EntityState.IDLE);
                        charactersMap.get("ragnarActionMain").changeState(EntityState.ACTION_MAIN);
                    }
                    case "zombieBoyDeath": {
                        charactersMap.get("zombieBoyDeath").changeState(EntityState.IDLE);
                        charactersMap.get("zombieBoyDeath").changeState(EntityState.DEATH);
                    }
                    case "zombieBoySpawn": {
                        charactersMap.get("zombieBoySpawn").changeState(EntityState.IDLE);
                        charactersMap.get("zombieBoySpawn").changeState(EntityState.SPAWN);
                    }
                    case "zombieBoyActionMain": {
                        charactersMap.get("zombieBoyActionMain").changeState(EntityState.IDLE);
                        charactersMap.get("zombieBoyActionMain").changeState(EntityState.ACTION_MAIN);
                    }
                }
            }
        }
    }
}