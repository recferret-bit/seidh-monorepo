package game.scene.impl.test;

import format.tools.ArcFour;
import game.mvp.view.entities.collider.ColliderEntityView;
import game.mvp.view.entities.character.glamr.GlamrEntityView;
import game.mvp.view.entities.character.zombie_girl.ZombieGirlEntityView;
import game.mvp.view.entities.character.zombie_boy.ZombieBoyEntityView;
import game.mvp.view.entities.character.CharacterEntityView;
import engine.model.entities.types.EntityState;
import h2d.Bitmap;

import game.mvp.view.entities.character.ragnar.RagnarEntityView;
import game.scene.base.BaseScene;
import game.event.EventManager;

class CharactersTestScene extends BaseScene implements EventListener {
    private var bitmaps:Array<Bitmap> = [];

    private final charactersMap:Map<String, CharacterEntityView> = new Map();

    public function new() {
        super();

        EventManager.instance.subscribe(EventManager.EVENT_CHARACTER_ANIM_END, this);
        
        final xxx = new ColliderEntityView();
        addChild(xxx);
        xxx.setPosition(320, 320);
        
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

        final zombieGirlRun = new ZombieGirlEntityView();
        zombieGirlRun.setPosition(150 + (332 / 2), 332 * 2.5);
        zombieGirlRun.changeState(EntityState.RUN);
        zombieGirlRun.getAnimation().setCharacterId("zombieGirlRun");
        addChild(zombieGirlRun);
        charactersMap.set("zombieGirlRun", zombieGirlRun);

        final zombieGirlDeath = new ZombieGirlEntityView();
        zombieGirlDeath.setPosition(150 + (332), 332 * 2.5);
        zombieGirlDeath.changeState(EntityState.DEATH);
        zombieGirlDeath.getAnimation().setCharacterId("zombieGirlDeath");
        addChild(zombieGirlDeath);
        charactersMap.set("zombieGirlDeath", zombieGirlDeath);

        final zombieGirlSpawn = new ZombieGirlEntityView();
        zombieGirlSpawn.setPosition(150 + (332 * 1.5), 332 * 2.5);
        zombieGirlSpawn.changeState(EntityState.SPAWN);
        zombieGirlSpawn.getAnimation().setCharacterId("zombieGirlSpawn");
        addChild(zombieGirlSpawn);
        charactersMap.set("zombieGirlSpawn", zombieGirlSpawn);

        final zombieGirlActionMain = new ZombieGirlEntityView();
        zombieGirlActionMain.setPosition(150 + (332 * 2), 332 * 2.5);
        zombieGirlActionMain.changeState(EntityState.ACTION_MAIN);
        zombieGirlActionMain.getAnimation().setCharacterId("zombieGirlActionMain");
        addChild(zombieGirlActionMain);
        charactersMap.set("zombieGirlActionMain", zombieGirlActionMain);

        // Glamr
        final glamrIdle = new GlamrEntityView();
        glamrIdle.setPosition(150, 332 * 3.5);
        glamrIdle.changeState(EntityState.IDLE);
        glamrIdle.getAnimation().setCharacterId("glamrIdle");
        addChild(glamrIdle);
        charactersMap.set("glamrIdle", glamrIdle);
        
        final glamrRun = new GlamrEntityView();
        glamrRun.setPosition(150 + (500 / 2), 332 * 3.5);
        glamrRun.changeState(EntityState.RUN);
        glamrRun.getAnimation().setCharacterId("glamrRun");
        addChild(glamrRun);
        charactersMap.set("glamrRun", glamrRun);
        
        final glamrDeath = new GlamrEntityView();
        glamrDeath.setPosition(150 + (500), 332 * 3.5);
        glamrDeath.changeState(EntityState.DEATH);
        glamrDeath.getAnimation().setCharacterId("glamrDeath");
        addChild(glamrDeath);
        charactersMap.set("glamrDeath", glamrDeath);
        
        final glamrSpawn = new GlamrEntityView();
        glamrSpawn.setPosition(150 + (500 * 1.5), 332 * 3.5);
        glamrSpawn.changeState(EntityState.SPAWN);
        glamrSpawn.getAnimation().setCharacterId("glamrSpawn");
        addChild(glamrSpawn);
        charactersMap.set("glamrSpawn", glamrSpawn);
        
        final glamrActionMain = new GlamrEntityView();
        glamrActionMain.setPosition(150 + (500 * 2), 332 * 3.5);
        glamrActionMain.changeState(EntityState.ACTION_MAIN);
        glamrActionMain.getAnimation().setCharacterId("glamrActionMain");
        addChild(glamrActionMain);
        charactersMap.set("glamrActionMain", glamrActionMain);
        
        final glamrActionSpecial = new GlamrEntityView();
        glamrActionSpecial.setPosition(150 + (500 * 2.5), 332 * 3.5);
        glamrActionSpecial.changeState(EntityState.ACTION_SPECIAL);
        glamrActionSpecial.getAnimation().setCharacterId("glamrActionSpecial");
        addChild(glamrActionSpecial);
        charactersMap.set("glamrActionSpecial", glamrActionSpecial);
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
                    // Ragnar
                    case "ragnarDeath": {
                        charactersMap.get("ragnarDeath").changeState(EntityState.IDLE);
                        charactersMap.get("ragnarDeath").changeState(EntityState.DEATH);
                    }
                    case "ragnarActionMain": {
                        charactersMap.get("ragnarActionMain").changeState(EntityState.IDLE);
                        charactersMap.get("ragnarActionMain").changeState(EntityState.ACTION_MAIN);
                    }

                    // Zombie Boy
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

                    // Zombie Girl
                    case "zombieGirlDeath": {
                        charactersMap.get("zombieGirlDeath").changeState(EntityState.IDLE);
                        charactersMap.get("zombieGirlDeath").changeState(EntityState.DEATH);
                    }
                    case "zombieGirlSpawn": {
                        charactersMap.get("zombieGirlSpawn").changeState(EntityState.IDLE);
                        charactersMap.get("zombieGirlSpawn").changeState(EntityState.SPAWN);
                    }
                    case "zombieGirlActionMain": {
                        charactersMap.get("zombieGirlActionMain").changeState(EntityState.IDLE);
                        charactersMap.get("zombieGirlActionMain").changeState(EntityState.ACTION_MAIN);
                    }

                    // Glamr
                    case "glamrDeath": {
                        charactersMap.get("glamrDeath").changeState(EntityState.IDLE);
                        charactersMap.get("glamrDeath").changeState(EntityState.DEATH);
                    }
                    case "glamrSpawn": {
                        charactersMap.get("glamrSpawn").changeState(EntityState.IDLE);
                        charactersMap.get("glamrSpawn").changeState(EntityState.SPAWN);
                    }
                    case "glamrActionMain": {
                        charactersMap.get("glamrActionMain").changeState(EntityState.IDLE);
                        charactersMap.get("glamrActionMain").changeState(EntityState.ACTION_MAIN);
                    }
                    case "glamrActionSpecial": {
                        charactersMap.get("glamrActionSpecial").changeState(EntityState.IDLE);
                        charactersMap.get("glamrActionSpecial").changeState(EntityState.ACTION_SPECIAL);
                    }
                }
            }
        }
    }
}

