package engine.model.entities.base;

import engine.model.ObjectPool;
import engine.model.entities.EntityType;
import engine.model.entities.base.BaseEngineEntity;
import engine.model.entities.base.EngineEntitySpec;
import engine.model.entities.impl.EngineCharacterEntity;
import engine.model.entities.impl.EngineColliderEntity;

/**
 * Factory for creating entities with registration pattern
 */
class EngineEntityFactory {
    private final factories: Map<EntityType, Void->BaseEngineEntity>;
    private final pool: ObjectPool;
    
    public function new(pool: ObjectPool) {
        this.pool = pool;
        factories = new Map();
        
        // Register core entity types
        registerCoreTypes();
    }
    
    /**
     * Register a new entity type factory
     * @param type Entity type
     * @param factory Function that creates new entity instances
     */
    public function register(type: EntityType, factory: Void->BaseEngineEntity): Void {
        factories.set(type, factory);
    }
    
    /**
     * Create entity using factory or pool
     * @param type Entity type
     * @param spec Entity specification
     * @return Created entity
     */
    public function create(type: EntityType, spec: EngineEntitySpec): BaseEngineEntity {
        trace('Creating entity of type: $type');
        
        if (!factories.exists(type)) {
            throw 'Unknown entity type: $type';
        }
        
        final entity = pool.acquire(type, factories.get(type));
        entity.reset(spec);
        return entity;
    }
    
    /**
     * Release entity back to pool
     * @param entity Entity to release
     */
    public function release(entity: BaseEngineEntity): Void {
        pool.release(entity.type, entity);
    }
    
    private function registerCoreTypes(): Void {
        // Register core entity types
        register(EntityType.RAGNAR, function() return new EngineCharacterEntity());
        register(EntityType.ZOMBIE_BOY, function() return new EngineCharacterEntity());
        register(EntityType.ZOMBIE_GIRL, function() return new EngineCharacterEntity());
        register(EntityType.GLAMR, function() return new EngineCharacterEntity());
        register(EntityType.COLLIDER, function() return new EngineColliderEntity());
    }
}
