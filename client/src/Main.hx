package;

import game.mvp.view.scene.basic.BasicScene;
import game.mvp.view.scene.SceneManager;
import game.resource.Res;

import hxd.App;

class Main extends App {
	private var sceneManager:SceneManager;

	override function init() {
		// Set up mobile-friendly engine settings
		engine.backgroundColor = 0xFFFFFF;

		Res.instance.init(function(c:ResLoadingProgressCallback):Void {
		});

		sceneManager = new SceneManager(function(scene:BasicScene) {
			setScene2D(scene);
		});
	}

	override function update(dt:Float) {
		super.update(dt);
		
		if (sceneManager != null) {
			sceneManager.getCurrentScene().customUpdate(dt, engine.fps);
		}
	}

	static function main() {
		hxd.Res.initEmbed();
		new Main();
	}
}
