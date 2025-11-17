package game.scene.impl;

import game.scene.base.BaseScene;
import game.eventbus.GameEventBus;
import game.eventbus.events.LoadGameSceneEvent;

class LoadingScene extends BaseScene {
	public function new() {
		super();
		trace("LoadingScene created");
	}

	public function start():Void {
		trace("LoadingScene started");
		GameEventBus.instance.emit(LoadGameSceneEvent.NAME, {});
	}

	public function destroy():Void {
		trace("LoadingScene destroyed");
	}

	public function customUpdate(dt:Float, fps:Float):Void {
		trace("LoadingScene updated");
	}
}

