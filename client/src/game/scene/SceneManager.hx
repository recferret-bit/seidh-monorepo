package game.scene;

import game.scene.impl.test.PhysicsTestScene;
import game.scene.impl.test.TerrainTestScene;
import game.scene.impl.test.ObjectsTilemapTestScene;
import game.scene.impl.test.CharactersTestScene;
import game.scene.impl.GameScene;
import game.scene.impl.LoadingScene;
import game.scene.impl.HomeScene;
import game.scene.base.BaseScene;
import game.event.EventManager;

class SceneManager implements EventListener {
	private var sceneChangedCallback:BaseScene->Void;
	private var currentScene:BaseScene;
	
	public function new(sceneChangedCallback:BaseScene->Void) {
		this.sceneChangedCallback = sceneChangedCallback;

		EventManager.instance.subscribe(EventManager.EVENT_LOAD_HOME_SCENE, this);
		EventManager.instance.subscribe(EventManager.EVENT_LOAD_GAME_SCENE, this);

		// currentScene = new LoadingScene();
		// currentScene = new ObjectsTilemapTestScene();
		// currentScene = new CharactersTestScene();
		// currentScene = new TerrainTestScene();
		currentScene = new PhysicsTestScene();
		currentScene.start();

		changeSceneCallback();
	}

	// --------------------------------------
	// Impl
	// --------------------------------------

	public function notify(event:String, message:Dynamic) {
		switch (event) {
			case EventManager.EVENT_LOAD_HOME_SCENE: {
				if (currentScene != null) {
					currentScene.destroy();
				}
				currentScene = new HomeScene();
				currentScene.start();
			}
			case EventManager.EVENT_LOAD_GAME_SCENE: {
				if (currentScene != null) {
					currentScene.destroy();
				}
				currentScene = new GameScene();
				currentScene.start();
			}
		}
		changeSceneCallback();
	}

	// --------------------------------------
	// Common
	// --------------------------------------

	public function getCurrentScene() {
		return currentScene;
	}

	public function onResize() {
		currentScene.onResize();
	}

	private function changeSceneCallback() {
		if (sceneChangedCallback != null) {
			sceneChangedCallback(currentScene);
		}
	}
}

