package game.mvp.view.scene.impl;

import game.mvp.view.scene.basic.BasicScene;

class HomeScene extends BasicScene {
	public function new() {
		super();
		trace("HomeScene created");
	}

	public function start():Void {
		trace("HomeScene started");
	}

	public function destroy():Void {
		trace("HomeScene destroyed");
	}

	public function customUpdate(dt:Float, fps:Float):Void {
		trace("HomeScene updated");
	}
}