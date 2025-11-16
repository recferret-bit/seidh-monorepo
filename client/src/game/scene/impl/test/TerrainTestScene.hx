package game.scene.impl.test;

import game.mvp.view.camera.DebugCamera;
import game.resource.terrain.TerrainManager;
import game.scene.base.BaseScene;

class TerrainTestScene extends BaseScene {

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

