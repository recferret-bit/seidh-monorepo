package engine.model.entities.factory;

import engine.model.ObjectPool;
import engine.model.entities.base.BaseEngineEntity;
import engine.model.entities.character.GlamrEntity;
import engine.model.entities.character.RagnarEntity;
import engine.model.entities.character.ZombieBoyEntity;
import engine.model.entities.character.ZombieGirlEntity;
import engine.model.entities.collider.ColliderEntity;
import engine.model.entities.consumable.ArmorPotionEntity;
import engine.model.entities.consumable.HealthPotionEntity;
import engine.model.entities.consumable.SalmonEntity;
import engine.model.entities.specs.EngineEntitySpec;
import engine.model.entities.types.EntityType;

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
        // Register character types
        register(EntityType.RAGNAR, function() return new RagnarEntity());
        register(EntityType.ZOMBIE_BOY, function() return new ZombieBoyEntity());
        register(EntityType.ZOMBIE_GIRL, function() return new ZombieGirlEntity());
        register(EntityType.GLAMR, function() return new GlamrEntity());
        
        // Register collider type
        register(EntityType.COLLIDER, function() return new ColliderEntity());
        
        // Register consumable types
        register(EntityType.HEALTH_POTION, function() return new HealthPotionEntity());
        register(EntityType.ARMOR_POTION, function() return new ArmorPotionEntity());
        register(EntityType.SALMON, function() return new SalmonEntity());
    }
}

