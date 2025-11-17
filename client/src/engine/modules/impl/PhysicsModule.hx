package engine.modules.impl;

import engine.geometry.Vec2;
import engine.model.GameModelState;
import engine.model.entities.base.BaseEngineEntity;
import engine.model.entities.collider.ColliderEntity;
import engine.model.entities.types.EntityType;
import engine.modules.abs.IModule;
import engine.physics.CollisionDetector;
import engine.physics.CollisionTypes.CollisionObject;

/**
 * Physics module for movement and collision
 */
class PhysicsModule implements IModule {
    
    private final collisionDetector: CollisionDetector;
    
    public function new() {
        collisionDetector = new CollisionDetector();
    }
    
    public function update(state: GameModelState, tick: Int, dt: Float): Void {
        // Integrate velocities into positions
        integrate(state, dt);
        
        // Run collision detection and resolution
        stepCollision(state, tick);
    }
    
    public function shutdown(): Void {
    }
    
    /**
     * Integrate velocities into positions
     * @param state Game state
     * @param dt Delta time
     */
    public function integrate(state: GameModelState, dt: Float): Void {
        // Update all entities in all managers
        for (manager in state.managers.getAll()) {
            manager.iterate(function(entity) {
                if (entity.isAlive) {
                    // Skip velocity integration for input-driven entities
                    // (movement is already applied in InputModule)
                    if (!entity.isInputDriven) {
                        // Apply velocity to position for physics-driven entities
                        entity.pos = Vec2.add(entity.pos, Vec2.scale(entity.vel, dt));
                    }
                }
            });
        }
    }
    
    /**
     * Run collision detection and resolution
     * @param state Game state
     * @param tick Current tick
     */
    public function stepCollision(state: GameModelState, tick: Int): Void {
        // Collect all alive entities
        final entities = [];
        for (manager in state.managers.getAll()) {
            manager.iterate(function(entity) {
                if (entity.isAlive) {
                    entities.push(entity);
                }
            });
        }
        
        // Convert entities to collision objects
        final collisionObjects = entities.map(function(entity: BaseEngineEntity): CollisionObject {
            final isCollider = entity.type == EntityType.COLLIDER;
            final colliderEntity = isCollider ? cast(entity, ColliderEntity) : null;
            
            return {
                id: entity.id,
                pos: entity.pos,
                colliderWidth: entity.colliderWidth,
                colliderHeight: entity.colliderHeight,
                type: entity.type,
                isCollider: isCollider,
                passable: colliderEntity != null ? colliderEntity.passable : false,
                isTrigger: colliderEntity != null ? colliderEntity.isTrigger : false,
                entity: entity,
                onCollision: function(entityA: BaseEngineEntity, entityB: BaseEngineEntity) {
                    // General collision callback - can be used for custom collision handling
                },
                onTrigger: function(otherId) {
                    trace("Collider trigger activated: " + entity.id + " by entity: " + otherId);
                }
            };
        });
        
        // Use collision detector to detect and resolve collisions
        collisionDetector.detectCollisions(collisionObjects);
    }
    
    /**
     * Register collider for entity
     * @param entity Entity with collider
     */
    public function registerCollider(entity: Dynamic): Void {
        // Simplified - in practice would add to spatial hash
    }

    /**
     * Unregister collider for entity
     * @param entityId Entity ID
     */
    public function unregisterCollider(entityId: Int): Void {
        // Simplified - in practice would remove from spatial hash
    }
}

