package game.scene;

import game.scene.impl.test.PhysicsTestScene;
import game.scene.impl.test.TerrainTestScene;
import game.scene.impl.test.ObjectsTilemapTestScene;
import game.scene.impl.test.CharactersTestScene;
import game.scene.impl.GameScene;
import game.scene.impl.LoadingScene;
import game.scene.impl.HomeScene;
import game.scene.base.BaseScene;
import game.eventbus.GameEventBus;
import game.eventbus.events.LoadHomeSceneEvent;
import game.eventbus.events.LoadGameSceneEvent;

class SceneManager {
	private var sceneChangedCallback:BaseScene->Void;
	private var currentScene:BaseScene;
	private var subscriptionTokens: Array<Int>;
	
	public function new(sceneChangedCallback:BaseScene->Void) {
		this.sceneChangedCallback = sceneChangedCallback;
		this.subscriptionTokens = [];

		// Subscribe to scene loading events
		subscriptionTokens.push(GameEventBus.instance.subscribe(LoadHomeSceneEvent.NAME, handleLoadHomeScene));
		subscriptionTokens.push(GameEventBus.instance.subscribe(LoadGameSceneEvent.NAME, handleLoadGameScene));

		currentScene = new LoadingScene();
		// currentScene = new ObjectsTilemapTestScene();
		// currentScene = new CharactersTestScene();
		// currentScene = new TerrainTestScene();
		// currentScene = new PhysicsTestScene();
		currentScene.start();

		changeSceneCallback();
	}

	// --------------------------------------
	// Event Handlers
	// --------------------------------------

	private function handleLoadHomeScene(payload: LoadHomeSceneEventData): Void {
		if (currentScene != null) {
			currentScene.destroy();
		}
		currentScene = new HomeScene();
		currentScene.start();
		changeSceneCallback();
	}

	private function handleLoadGameScene(payload: LoadGameSceneEventData): Void {
		if (currentScene != null) {
			currentScene.destroy();
		}
		currentScene = new GameScene();
		currentScene.start();
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

