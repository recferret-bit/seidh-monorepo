package game.scene.impl.test;

import engine.domain.entities.BaseEntity;
import engine.domain.entities.collider.ColliderEntity;
import engine.infrastructure.utilities.physics.CollisionDetector;
import engine.infrastructure.utilities.physics.CollisionTypes.CollisionObject;
import game.mvp.model.entities.ColliderModel;
import game.mvp.view.entities.collider.ColliderEntityView;
import hxd.Key;
import game.scene.base.BaseScene;
import engine.SeidhEngine;

class PhysicsTestScene extends BaseScene {

    private var collider1:ColliderEntityView;
    private var collider2:ColliderEntityView;
    private var collider1Model:ColliderModel;
    private var collider2Model:ColliderModel;
    private var collisionDetector:CollisionDetector;

    public function new() {
        super();

        // Initialize collision detector
        collisionDetector = new CollisionDetector();

        collider1 = new ColliderEntityView();
        collider1Model = new ColliderModel();
        final colliderEntity1 = new ColliderEntity();
        // TODO: Recreate spec helper or create inline
        collider1Model.initialize(colliderEntity1);
        collider1.initialize(collider1Model);
        addChild(collider1);
        collider1.setPosition(100, 100);

        collider2 = new ColliderEntityView();
        collider2Model = new ColliderModel();
        final colliderEntity2 = new ColliderEntity();
        // TODO: Recreate spec helper or create inline
        collider2Model.initialize(colliderEntity2);
        collider2.initialize(collider2Model);
        addChild(collider2);
        collider2.setPosition(200, 200);
    }

    public function start():Void {
        trace("PhysicsTestScene started");
    }

    public function destroy():Void {
        trace("PhysicsTestScene destroyed");
    }

    public function customUpdate(dt:Float, fps:Float) {
        final movementSpeed = 4;
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

        // Apply movement to collider1
        collider1Model.engineEntity.pos.x += Std.int(movement.x);
        collider1Model.engineEntity.pos.y += Std.int(movement.y);
        collider1Model.engineEntity.updateColliderRect();

        collider1.alpha = 1;
        collider2.alpha = 1;

        // Create collision objects from models
        final collisionObjects: Array<CollisionObject> = [
            {
                id: collider1Model.id,
                pos: collider1Model.engineEntity.pos,
                colliderWidth: collider1Model.colliderWidth,
                colliderHeight: collider1Model.colliderHeight,
                type: collider1Model.type,
                isCollider: true,
                passable: collider1Model.passable,
                isTrigger: collider1Model.isTrigger,
                entity: collider1Model.engineEntity,
                onCollision: function(entityA: BaseEntity, entityB: BaseEntity) {
                    trace("Collision detected between entity " + entityA.id + " and entity " + entityB.id);
                    collider1.alpha = 0.5;
                },
                onTrigger: function(otherId: Int) {
                    trace("Collider 1 trigger activated by: " + otherId);
                }
            },
            {
                id: collider2Model.id,
                pos: collider2Model.engineEntity.pos,
                colliderWidth: collider2Model.colliderWidth,
                colliderHeight: collider2Model.colliderHeight,
                type: collider2Model.type,
                isCollider: true,
                passable: collider2Model.passable,
                isTrigger: collider2Model.isTrigger,
                entity: collider2Model.engineEntity,
                onCollision: function(entityA: BaseEntity, entityB: BaseEntity) {
                    trace("Collision detected between entity " + entityA.id + " and entity " + entityB.id);
                    collider2.alpha = 0.5;
                },
                onTrigger: function(otherId: Int) {
                    trace("Collider 2 trigger activated by: " + otherId);
                }
            }
        ];

        // // Run collision detection
        collisionDetector.detectCollisions(collisionObjects);

        // Update models from engine entities
        collider1Model.updateFromEngine();
        collider2Model.updateFromEngine();

        // Update views
        collider1.update();
        collider2.update();
    }
}