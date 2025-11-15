package game.resource;

import game.config.GameClientConfig;
import hxd.net.BinaryLoader;

enum SeidhResource {
    
    // ------------------------------------
    // FX
    // ------------------------------------

    FX_IMPACT;

    FX_ZOMBIE_BLOOD_1;
    FX_ZOMBIE_BLOOD_2;

    FX_NORMALMAP;

    // ------------------------------------
    // RAGNAR
    // ------------------------------------
    
    RAGNAR_IDLE;
    RAGNAR_RUN;
    RAGNAR_ATTACK;
    RAGNAR_DEATH;

    // ------------------------------------
    // SOUND
    // ------------------------------------

    SOUND_BUTTON_1;
    SOUND_BUTTON_2;
    SOUND_GAMEPLAY_THEME;
    SOUND_MENU_THEME;
    SOUND_VIKING_DEATH;
    SOUND_VIKING_DMG;
    SOUND_VIKING_HIT;
    SOUND_ZOMBIE_DEATH;
    SOUND_ZOMBIE_DMG;
    SOUND_ZOMBIE_HIT;

    // ------------------------------------
    // STUFF
    // ------------------------------------

    OBJECTS_TILEMAP;

    // ------------------------------------
    // TERRAIN
    // ------------------------------------

    TERRAIN_GROUND_1;
    TERRAIN_GROUND_2;
    TERRAIN_GROUND_3;
    TERRAIN_GROUND_4;
    TERRAIN_FENCE;
    TERRAIN_PUDDLE;
    TERRAIN_ROCK;
    TERRAIN_TREE_1;
    TERRAIN_TREE_2;
    TERRAIN_WEED_1;
    TERRAIN_WEED_2;
    TERRAIN_ENV_TILEMAP;

    // ------------------------------------
    // UI
    // ------------------------------------

    UI_DIALOG_BUTTON_NAY;
    UI_DIALOG_BUTTON_YAY;
    UI_DIALOG_WINDOW_SMALL;
    UI_DIALOG_WINDOW_MEDIUM;
    UI_DIALOG_XL_HEADER;
    UI_DIALOG_XL_FOOTER;

    UI_GAME_JOYSTICK_1;
    UI_GAME_JOYSTICK_2;

    UI_GAME_HEADER;
    UI_GAME_FOOTER;
    UI_GAME_FRAME;
    UI_GAME_FRAME_RIGHT;
    UI_GAME_HP;
    UI_GAME_XP;
    UI_GAME_MONEY;

    UI_HOME_ARROW_LEFT;
    UI_HOME_ARROW_RIGHT;
    UI_HOME_LVL_NAY;
    UI_HOME_LVL_YAY;
    UI_HOME_PLAY_NAY;
    UI_HOME_PLAY_YAY;
    UI_HOME_DARKNESS;
    UI_HOME_HEADER;
    UI_HOME_FRAME;
    UI_HOME_FOOTER;

    UI_HOME_HOME_NAY;
    UI_HOME_HOME_YAY;
    UI_HOME_BOOST_NAY;
    UI_HOME_BOOST_YAY;
    UI_HOME_COLLECT_NAY;
    UI_HOME_COLLECT_YAY;
    UI_HOME_FRIEND_NAY;
    UI_HOME_FRIEND_YAY;

    UI_HOME_BUNNY;
    UI_HOME_BUNNY_FIRE;

    UI_HOME_TITLE_COLLECTION;
    UI_HOME_TITLE_FRIENDS;
    UI_HOME_TITLE_SOON;
    UI_HOME_TITLE_STORE;
    UI_HOME_TITLE_HOME;

    UI_BOOST_SCROLL_BODY;
    UI_BOOST_SCROLL_HEADER;
    
    // ------------------------------------
    // ZOMBIE BOY
    // ------------------------------------

    ZOMBIE_BOY_IDLE;
    ZOMBIE_BOY_RUN;
    ZOMBIE_BOY_ATTACK;
    ZOMBIE_BOY_DEATH;
    ZOMBIE_BOY_SPAWN;

    // ------------------------------------
    // ZOMBIE GIRL
    // ------------------------------------

    ZOMBIE_GIRL_IDLE;
    ZOMBIE_GIRL_RUN;
    ZOMBIE_GIRL_ATTACK;
    ZOMBIE_GIRL_DEATH;
    ZOMBIE_GIRL_SPAWN;

    // ------------------------------------
    // GLAMR
    // ------------------------------------

    GLAMR_IDLE;
    GLAMR_RUN;
    GLAMR_ATTACK;
    GLAMR_DEATH;
    GLAMR_SPAWN;
    GLAMR_HAIL;
}

class ResRemoteLoader {

    public function new(seidhResource:SeidhResource) {
        final filePath = Res.instance.remoteResourceMap.get(seidhResource);
        final loader = new BinaryLoader(filePath);

		loader.onProgress = function onProgress(cur:Int, max:Int) {
		};
		loader.onLoaded = function onLoaded(bytes:haxe.io.Bytes) {
            final isSound = 
                seidhResource == SeidhResource.SOUND_BUTTON_1 ||
                seidhResource == SeidhResource.SOUND_BUTTON_2 ||
                seidhResource == SeidhResource.SOUND_MENU_THEME ||
                seidhResource == SeidhResource.SOUND_GAMEPLAY_THEME ||
                seidhResource == SeidhResource.SOUND_VIKING_DEATH ||
                seidhResource == SeidhResource.SOUND_VIKING_DMG ||
                seidhResource == SeidhResource.SOUND_VIKING_HIT ||
                seidhResource == SeidhResource.SOUND_ZOMBIE_DEATH ||
                seidhResource == SeidhResource.SOUND_ZOMBIE_DMG ||
                seidhResource == SeidhResource.SOUND_ZOMBIE_HIT;

            if (isSound) {
                Res.instance.soundResMap.set(seidhResource, hxd.res.Any.fromBytes(filePath, bytes).toSound());
            } else {
                if (seidhResource == SeidhResource.FX_NORMALMAP) {
                    Res.instance.tileResMap.set(seidhResource, hxd.res.Any.fromBytes(filePath, bytes).toTile());
                } {
                    Res.instance.tileResMap.set(seidhResource, hxd.res.Any.fromBytes(filePath, bytes).toTile().center());
                }
            }

            Res.instance.resourcesLoaded += 1;
		}
		loader.load();
    }

}

typedef ResLoadingProgressCallback = {
	var done:Bool;
    var progress:Int;
}

class Res {

    public static final instance:Res = new Res();

    public final tileResMap = new Map<SeidhResource, h2d.Tile>();
    public final soundResMap = new Map<SeidhResource, hxd.res.Sound>();

    public final remoteResourceMap = new Map<SeidhResource, String>();

    public final resourcesTotal = 10;
    public var resourcesLoaded = 0;

    private var initialized = false;

    private var resCallback:ResLoadingProgressCallback->Void = null;

	private function new() {
    }

    public function init(callback:ResLoadingProgressCallback->Void) {
        if (!initialized) {
            resCallback = callback;

            initialized = true;
            if (GameClientConfig.DefaultResourceProvider == ResourceProvider.YANDEX_S3) {
                final url = 'https://storage.yandexcloud.net/seidh-static-and-assets/resources/';
                // ------------------------------------
                // FX
                // ------------------------------------

                remoteResourceMap.set(FX_IMPACT, url + 'fx/ragnar/FX_IMPACT.png');

                remoteResourceMap.set(FX_ZOMBIE_BLOOD_1, url + 'fx/zombie/FX_ZOMBIE_BLOOD_1.png');
                remoteResourceMap.set(FX_ZOMBIE_BLOOD_2, url + 'fx/zombie/FX_ZOMBIE_ATTACK_3.png');

                remoteResourceMap.set(FX_NORMALMAP, url + 'fx/FX_NORMALMAP.png');

                // ------------------------------------
                // STUFF
                // ------------------------------------
            
                remoteResourceMap.set(OBJECTS_TILEMAP, url + 'icons/OBJECTS_TILEMAP.png');

                // ------------------------------------
                // RAGNAR
                // ------------------------------------
            
                remoteResourceMap.set(RAGNAR_IDLE, url + 'ragnar/RAGNAR_IDLE.png');
                remoteResourceMap.set(RAGNAR_RUN, url + 'ragnar/RAGNAR_RUN.png');
                remoteResourceMap.set(RAGNAR_ATTACK, url + 'ragnar/RAGNAR_ATTACK.png');
                remoteResourceMap.set(RAGNAR_DEATH, url + 'ragnar/RAGNAR_DEATH.png');

                // ------------------------------------
                // SOUND
                // ------------------------------------
            
                remoteResourceMap.set(SOUND_BUTTON_1, url + 'sound/SOUND_BUTTON_1.mp3');
                remoteResourceMap.set(SOUND_BUTTON_2, url + 'sound/SOUND_BUTTON_2.mp3');
                remoteResourceMap.set(SOUND_GAMEPLAY_THEME, url + 'sound/SOUND_GAMEPLAY_THEME.mp3');
                remoteResourceMap.set(SOUND_MENU_THEME, url + 'sound/SOUND_MENU_THEME.mp3');
                remoteResourceMap.set(SOUND_VIKING_DEATH, url + 'sound/SOUND_VIKING_DEATH.mp3');
                remoteResourceMap.set(SOUND_VIKING_DMG, url + 'sound/SOUND_VIKING_DMG.mp3');
                remoteResourceMap.set(SOUND_VIKING_HIT, url + 'sound/SOUND_VIKING_HIT.mp3');
                remoteResourceMap.set(SOUND_ZOMBIE_DEATH, url + 'sound/SOUND_ZOMBIE_DEATH.mp3');
                remoteResourceMap.set(SOUND_ZOMBIE_DMG, url + 'sound/SOUND_ZOMBIE_DMG.mp3');
                remoteResourceMap.set(SOUND_ZOMBIE_HIT, url + 'sound/SOUND_ZOMBIE_HIT.mp3');
            
                // ------------------------------------
                // TERRAIN
                // ------------------------------------
            
                remoteResourceMap.set(TERRAIN_GROUND_1, url + 'terrain/TERRAIN_GROUND_1.png');
                remoteResourceMap.set(TERRAIN_GROUND_2, url + 'terrain/TERRAIN_GROUND_2.png');
                remoteResourceMap.set(TERRAIN_GROUND_3, url + 'terrain/TERRAIN_GROUND_3.png');
                remoteResourceMap.set(TERRAIN_GROUND_4, url + 'terrain/TERRAIN_GROUND_4.png');
                remoteResourceMap.set(TERRAIN_FENCE, url + 'terrain/TERRAIN_FENCE.png');
                remoteResourceMap.set(TERRAIN_PUDDLE, url + 'terrain/TERRAIN_PUDDLE.png');
                remoteResourceMap.set(TERRAIN_ROCK, url + 'terrain/TERRAIN_ROCK.png');
                remoteResourceMap.set(TERRAIN_TREE_1, url + 'terrain/TERRAIN_TREE_1.png');
                remoteResourceMap.set(TERRAIN_TREE_2, url + 'terrain/TERRAIN_TREE_2.png');
                remoteResourceMap.set(TERRAIN_WEED_1, url + 'terrain/TERRAIN_WEED_1.png');
                remoteResourceMap.set(TERRAIN_WEED_2, url + 'terrain/TERRAIN_WEED_2.png');
                remoteResourceMap.set(TERRAIN_ENV_TILEMAP, url + 'terrain/TERRAIN_ENV_TILEMAP.png');
                

                // ------------------------------------
                // UI
                // ------------------------------------

                remoteResourceMap.set(UI_DIALOG_BUTTON_NAY, url + 'ui/dialog/UI_DIALOG_BUTTON_NAY.png');
                remoteResourceMap.set(UI_DIALOG_BUTTON_YAY, url + 'ui/dialog/UI_DIALOG_BUTTON_YAY.png');
                remoteResourceMap.set(UI_DIALOG_WINDOW_SMALL, url + 'ui/dialog/UI_DIALOG_WINDOW_SMALL.png');
                remoteResourceMap.set(UI_DIALOG_WINDOW_MEDIUM, url + 'ui/dialog/UI_DIALOG_WINDOW_MEDIUM.png');
                remoteResourceMap.set(UI_DIALOG_XL_HEADER, url + 'ui/dialog/UI_DIALOG_XL_HEADER.png');
                remoteResourceMap.set(UI_DIALOG_XL_FOOTER, url + 'ui/dialog/UI_DIALOG_XL_FOOTER.png');
            
                remoteResourceMap.set(UI_GAME_JOYSTICK_1, url + 'ui/game/UI_GAME_JOYSTICK_1.png');
                remoteResourceMap.set(UI_GAME_JOYSTICK_2, url + 'ui/game/UI_GAME_JOYSTICK_2.png');
                remoteResourceMap.set(UI_GAME_HEADER, url + 'ui/game/UI_GAME_HEADER.png');
                remoteResourceMap.set(UI_GAME_FOOTER, url + 'ui/game/UI_GAME_FOOTER.png');
                remoteResourceMap.set(UI_GAME_FRAME, url + 'ui/game/UI_GAME_FRAME.png');
                remoteResourceMap.set(UI_GAME_FRAME_RIGHT, url + 'ui/game/UI_GAME_FRAME_RIGHT.png');
                remoteResourceMap.set(UI_GAME_HP, url + 'ui/game/UI_GAME_HP.png');
                remoteResourceMap.set(UI_GAME_XP, url + 'ui/game/UI_GAME_XP.png');
                remoteResourceMap.set(UI_GAME_MONEY, url + 'ui/game/UI_GAME_MONEY.png');
            
                remoteResourceMap.set(UI_HOME_ARROW_LEFT, url + 'ui/home/UI_HOME_ARROW_LEFT.png');
                remoteResourceMap.set(UI_HOME_ARROW_RIGHT, url + 'ui/home/UI_HOME_ARROW_RIGHT.png');
                remoteResourceMap.set(UI_HOME_LVL_NAY, url + 'ui/home/UI_HOME_LVL_NAY.png');
                remoteResourceMap.set(UI_HOME_LVL_YAY, url + 'ui/home/UI_HOME_LVL_YAY.png');
                remoteResourceMap.set(UI_HOME_PLAY_NAY, url + 'ui/home/UI_HOME_PLAY_NAY.png');
                remoteResourceMap.set(UI_HOME_PLAY_YAY, url + 'ui/home/UI_HOME_PLAY_YAY.png');
                remoteResourceMap.set(UI_HOME_DARKNESS, url + 'ui/home/UI_HOME_DARKNESS.png');
                remoteResourceMap.set(UI_HOME_HEADER, url + 'ui/home/UI_HOME_HEADER.png');
                remoteResourceMap.set(UI_HOME_FRAME, url + 'ui/home/UI_HOME_FRAME.png');
                remoteResourceMap.set(UI_HOME_FOOTER, url + 'ui/home/UI_HOME_FOOTER.png');
                remoteResourceMap.set(UI_HOME_HOME_NAY, url + 'ui/home/UI_HOME_HOME_NAY.png');
                remoteResourceMap.set(UI_HOME_HOME_YAY, url + 'ui/home/UI_HOME_HOME_YAY.png');
                remoteResourceMap.set(UI_HOME_BOOST_NAY, url + 'ui/home/UI_HOME_BOOST_NAY.png');
                remoteResourceMap.set(UI_HOME_BOOST_YAY, url + 'ui/home/UI_HOME_BOOST_YAY.png');
                remoteResourceMap.set(UI_HOME_COLLECT_NAY, url + 'ui/home/UI_HOME_COLLECT_NAY.png');
                remoteResourceMap.set(UI_HOME_COLLECT_YAY, url + 'ui/home/UI_HOME_COLLECT_YAY.png');
                remoteResourceMap.set(UI_HOME_FRIEND_NAY, url + 'ui/home/UI_HOME_FRIEND_NAY.png');
                remoteResourceMap.set(UI_HOME_FRIEND_YAY, url + 'ui/home/UI_HOME_FRIEND_YAY.png');
                remoteResourceMap.set(UI_HOME_BUNNY, url + 'ui/home/UI_HOME_BUNNY.png');
                remoteResourceMap.set(UI_HOME_BUNNY_FIRE, url + 'ui/home/UI_HOME_BUNNY_FIRE.png');

                remoteResourceMap.set(UI_HOME_TITLE_COLLECTION, url + 'ui/home/UI_HOME_TITLE_COLLECTION.png');
                remoteResourceMap.set(UI_HOME_TITLE_FRIENDS, url + 'ui/home/UI_HOME_TITLE_FRIENDS.png');
                remoteResourceMap.set(UI_HOME_TITLE_SOON, url + 'ui/home/UI_HOME_TITLE_SOON.png');
                remoteResourceMap.set(UI_HOME_TITLE_STORE, url + 'ui/home/UI_HOME_TITLE_STORE.png');
                remoteResourceMap.set(UI_HOME_TITLE_HOME, url + 'ui/home/UI_HOME_TITLE_HOME.png');

                remoteResourceMap.set(UI_BOOST_SCROLL_BODY, url + 'ui/home/UI_BOOST_SCROLL_BODY.png');
                remoteResourceMap.set(UI_BOOST_SCROLL_HEADER, url + 'ui/home/UI_BOOST_SCROLL_HEADER.png');

                // ------------------------------------
                // ZOMBIE BOY
                // ------------------------------------
            
                remoteResourceMap.set(ZOMBIE_BOY_IDLE, url + 'zombie-boy/ZOMBIE_BOY_IDLE.png');
                remoteResourceMap.set(ZOMBIE_BOY_RUN, url + 'zombie-boy/ZOMBIE_BOY_RUN.png');
                remoteResourceMap.set(ZOMBIE_BOY_ATTACK, url + 'zombie-boy/ZOMBIE_BOY_ATTACK.png');
                remoteResourceMap.set(ZOMBIE_BOY_DEATH, url + 'zombie-boy/ZOMBIE_BOY_DEATH.png');
                remoteResourceMap.set(ZOMBIE_BOY_SPAWN, url + 'zombie-boy/ZOMBIE_BOY_SPAWN.png');

                // ------------------------------------
                // ZOMBIE GIRL
                // ------------------------------------
            
                remoteResourceMap.set(ZOMBIE_GIRL_IDLE, url + 'zombie-girl/ZOMBIE_GIRL_IDLE.png');
                remoteResourceMap.set(ZOMBIE_GIRL_RUN, url + 'zombie-girl/ZOMBIE_GIRL_RUN.png');
                remoteResourceMap.set(ZOMBIE_GIRL_ATTACK, url + 'zombie-boy/ZOMBIE_GIRL_ATTACK.png');
                remoteResourceMap.set(ZOMBIE_GIRL_DEATH, url + 'zombie-girl/ZOMBIE_GIRL_DEATH.png');
                remoteResourceMap.set(ZOMBIE_GIRL_SPAWN, url + 'zombie-girl/ZOMBIE_GIRL_SPAWN.png');

                loadRemoteResources();
            } else if (GameClientConfig.DefaultResourceProvider == ResourceProvider.LOCAL) {
                // ------------------------------------
                // FX
                // ------------------------------------

                tileResMap.set(FX_IMPACT, hxd.Res.fx.ragnar.FX_IMPACT.toTile().center());

                tileResMap.set(FX_ZOMBIE_BLOOD_1, hxd.Res.fx.zombie.FX_ZOMBIE_BLOOD_1.toTile().center());
                tileResMap.set(FX_ZOMBIE_BLOOD_2, hxd.Res.fx.zombie.FX_ZOMBIE_BLOOD_2.toTile().center());

                tileResMap.set(FX_NORMALMAP, hxd.Res.fx.FX_NORMALMAP.toTile());
            
                // ------------------------------------
                // RAGNAR
                // ------------------------------------
            
                tileResMap.set(RAGNAR_IDLE, hxd.Res.ragnar.common.RAGNAR_IDLE.toTile().center());
                tileResMap.set(RAGNAR_RUN, hxd.Res.ragnar.common.RAGNAR_RUN.toTile().center());
                tileResMap.set(RAGNAR_ATTACK, hxd.Res.ragnar.common.RAGNAR_ATTACK.toTile().center());
                tileResMap.set(RAGNAR_DEATH, hxd.Res.ragnar.common.RAGNAR_DEATH.toTile().center());

                // ------------------------------------
                // SOUND
                // ------------------------------------
            
                // ------------------------------------
                // STUFF
                // ------------------------------------
                tileResMap.set(OBJECTS_TILEMAP, hxd.Res.OBJECTS_TILEMAP.toTile().center());

                // ------------------------------------
                // TERRAIN
                // ------------------------------------
            
                tileResMap.set(TERRAIN_GROUND_1, hxd.Res.terrain.TERRAIN_GROUND_1.toTile().center());
                tileResMap.set(TERRAIN_GROUND_2, hxd.Res.terrain.TERRAIN_GROUND_2.toTile().center());
                tileResMap.set(TERRAIN_GROUND_3, hxd.Res.terrain.TERRAIN_GROUND_3.toTile().center());
                tileResMap.set(TERRAIN_GROUND_4, hxd.Res.terrain.TERRAIN_GROUND_4.toTile().center());
                tileResMap.set(TERRAIN_FENCE, hxd.Res.terrain.TERRAIN_FENCE.toTile().center());
                tileResMap.set(TERRAIN_PUDDLE, hxd.Res.terrain.TERRAIN_PUDDLE.toTile().center());
                tileResMap.set(TERRAIN_ROCK, hxd.Res.terrain.TERRAIN_ROCK.toTile().center());
                tileResMap.set(TERRAIN_TREE_1, hxd.Res.terrain.TERRAIN_TREE_1.toTile().center());
                tileResMap.set(TERRAIN_TREE_2, hxd.Res.terrain.TERRAIN_TREE_2.toTile().center());
                tileResMap.set(TERRAIN_WEED_1, hxd.Res.terrain.TERRAIN_WEED_1.toTile().center());
                tileResMap.set(TERRAIN_WEED_2, hxd.Res.terrain.TERRAIN_WEED_2.toTile().center());
                tileResMap.set(TERRAIN_ENV_TILEMAP, hxd.Res.terrain.TERRAIN_ENV_TILEMAP.toTile().center());

                // ------------------------------------
                // UI
                // ------------------------------------
            
                // ------------------------------------
                // ZOMBIE BOY
                // ------------------------------------
            
                tileResMap.set(ZOMBIE_BOY_IDLE, hxd.Res.zombie_boy.ZOMBIE_BOY_IDLE.toTile().center());
                tileResMap.set(ZOMBIE_BOY_RUN, hxd.Res.zombie_boy.ZOMBIE_BOY_RUN.toTile().center());
                tileResMap.set(ZOMBIE_BOY_ATTACK, hxd.Res.zombie_boy.ZOMBIE_BOY_ATTACK.toTile().center());
                tileResMap.set(ZOMBIE_BOY_DEATH, hxd.Res.zombie_boy.ZOMBIE_BOY_DEATH.toTile().center());
                tileResMap.set(ZOMBIE_BOY_SPAWN, hxd.Res.zombie_boy.ZOMBIE_BOY_SPAWN.toTile().center());
            
                // ------------------------------------
                // ZOMBIE GIRL
                // ------------------------------------

                tileResMap.set(ZOMBIE_GIRL_IDLE, hxd.Res.zombie_girl.ZOMBIE_GIRL_IDLE.toTile().center());
                tileResMap.set(ZOMBIE_GIRL_RUN, hxd.Res.zombie_girl.ZOMBIE_GIRL_RUN.toTile().center());
                tileResMap.set(ZOMBIE_GIRL_ATTACK, hxd.Res.zombie_girl.ZOMBIE_GIRL_ATTACK.toTile().center());
                tileResMap.set(ZOMBIE_GIRL_DEATH, hxd.Res.zombie_girl.ZOMBIE_GIRL_DEATH.toTile().center());
                tileResMap.set(ZOMBIE_GIRL_SPAWN, hxd.Res.zombie_girl.ZOMBIE_GIRL_SPAWN.toTile().center());

                // ------------------------------------
                // GLAMR
                // ------------------------------------
            
                tileResMap.set(GLAMR_IDLE, hxd.Res.glamr.GLAMR_IDLE.toTile().center());
                tileResMap.set(GLAMR_RUN, hxd.Res.glamr.GLAMR_RUN.toTile().center());
                tileResMap.set(GLAMR_ATTACK, hxd.Res.glamr.GLAMR_ATTACK.toTile().center());
                tileResMap.set(GLAMR_DEATH, hxd.Res.glamr.GLAMR_DEATH.toTile().center());
                tileResMap.set(GLAMR_SPAWN, hxd.Res.glamr.GLAMR_SPAWN.toTile().center());
                tileResMap.set(GLAMR_HAIL, hxd.Res.glamr.GLAMR_HAIL.toTile().center());

                if (resCallback != null) {
                    resCallback({
                        done: true,
                        progress: 100
                    });
                }
            }
        }
	}

    public function loadRemoteResources() {
        if (GameClientConfig.DefaultResourceProvider == ResourceProvider.YANDEX_S3) {
            var remoteResCount = 0;
            for (key in remoteResourceMap.keys()) {
                remoteResCount++;
            }

            for (key in remoteResourceMap.keys()) {
                new ResRemoteLoader(key);
            }

            function wait() {
                if (remoteResCount == resourcesLoaded) {
                    if (resCallback != null) {
                        resCallback({
                            done: true,
                            progress: 100,
                        });
                    }
                } else {
                    if (resCallback != null) {
                        resCallback({
                            done: false,
                            progress: Std.int(resourcesLoaded / remoteResCount * 100),
                        });
                        haxe.Timer.delay(wait, 50);
                    }
                }
            }
            wait();
        }
    }

    public function getSoundResource(seidhResource:SeidhResource) {
        final isSound = 
            seidhResource == SeidhResource.SOUND_BUTTON_1 ||
            seidhResource == SeidhResource.SOUND_BUTTON_2 ||
            seidhResource == SeidhResource.SOUND_MENU_THEME ||
            seidhResource == SeidhResource.SOUND_GAMEPLAY_THEME ||
            seidhResource == SeidhResource.SOUND_VIKING_DEATH ||
            seidhResource == SeidhResource.SOUND_VIKING_DMG ||
            seidhResource == SeidhResource.SOUND_VIKING_HIT ||
            seidhResource == SeidhResource.SOUND_ZOMBIE_DEATH ||
            seidhResource == SeidhResource.SOUND_ZOMBIE_DMG ||
            seidhResource == SeidhResource.SOUND_ZOMBIE_HIT;

        if (isSound) {
            return soundResMap.get(seidhResource);
        } else {
            return null;
        }
    }

    public function getTileResource(seidhResource:SeidhResource) {
        final isSound = 
            seidhResource == SeidhResource.SOUND_BUTTON_1 ||
            seidhResource == SeidhResource.SOUND_BUTTON_2 ||
            seidhResource == SeidhResource.SOUND_MENU_THEME ||
            seidhResource == SeidhResource.SOUND_GAMEPLAY_THEME ||
            seidhResource == SeidhResource.SOUND_VIKING_DEATH ||
            seidhResource == SeidhResource.SOUND_VIKING_DMG ||
            seidhResource == SeidhResource.SOUND_VIKING_HIT ||
            seidhResource == SeidhResource.SOUND_ZOMBIE_DEATH ||
            seidhResource == SeidhResource.SOUND_ZOMBIE_DMG ||
            seidhResource == SeidhResource.SOUND_ZOMBIE_HIT;

        if (isSound) {
            return null;
        } else {
            return tileResMap.get(seidhResource).clone();
        }
    }
}