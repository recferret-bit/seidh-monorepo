package engine.infrastructure.factories;

import engine.domain.entities.BaseEntity;
import engine.domain.entities.character.impl.GlamrEntity;
import engine.domain.entities.character.impl.RagnarEntity;
import engine.domain.entities.character.impl.ZombieBoyEntity;
import engine.domain.entities.character.impl.ZombieGirlEntity;
import engine.domain.entities.collider.ColliderEntity;
import engine.domain.specs.EntitySpec;
import engine.domain.types.EntityType;
import engine.infrastructure.logging.Logger;
import engine.infrastructure.pooling.ObjectPool;

/**
 * Factory for creating entities with registration pattern
 */
class EngineEntityFactory {
    private final factories: Map<EntityType, Void->BaseEntity>;
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
    public function register(type: EntityType, factory: Void->BaseEntity): Void {
        factories.set(type, factory);
    }
    
    /**
     * Create entity using factory or pool
     * @param type Entity type
     * @param spec Entity specification
     * @return Created entity
     */
    public function create(type: EntityType, spec: EntitySpec): BaseEntity {
        Logger.debug('Creating entity of type: $type');
        
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
    public function release(entity: BaseEntity): Void {
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
        
        // TODO: Register consumable types - need to create domain entities first
        // register(EntityType.HEALTH_POTION, function() return new HealthPotionEntity());
        // register(EntityType.ARMOR_POTION, function() return new ArmorPotionEntity());
        // register(EntityType.SALMON, function() return new SalmonEntity());
    }
}

