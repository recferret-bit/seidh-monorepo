package game.mvp.view.scene.impl.test;

import game.mvp.view.camera.DebugCamera;
import game.resource.terrain.TerrainManager;
import game.mvp.view.scene.basic.BasicScene;

class TerrainTestScene extends BasicScene {

    private final debugCamera:DebugCamera;

    public function new() {
        super();

        debugCamera = new DebugCamera(getScene());

        final terrainManager = new TerrainManager(getScene());
    }

    public function start():Void {
        trace("TerrainTestScene started");
    }

    public function destroy():Void {
        trace("TerrainTestScene destroyed");
    }

    public function customUpdate(dt:Float, fps:Float) {
        debugCamera.update();
    }
}