package game.mvp.view.camera;

import hxd.Key;
import h2d.Scene;

class DebugCamera {
    private final scene:Scene;

    public function new(scene: Scene) {
        this.scene = scene;
    }

    public function update() {
        final movementSpeed = 20;
        final movement = {x: 0.0, y: 0.0};

        // Horizontal movement
        if (Key.isDown(Key.A) || Key.isDown(Key.LEFT)) {
            movement.x -= movementSpeed;
        }
        if (Key.isDown(Key.D) || Key.isDown(Key.RIGHT)) {
            movement.x += movementSpeed;
        }
        
        // Vertical movement
        if (Key.isDown(Key.W) || Key.isDown(Key.UP)) {
            movement.y -= movementSpeed;
        }
        if (Key.isDown(Key.S) || Key.isDown(Key.DOWN)) {
            movement.y += movementSpeed;
        }

        scene.camera.x += movement.x;
        scene.camera.y += movement.y;
    }
}