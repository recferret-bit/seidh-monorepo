package engine.infrastructure.adapters.persistence;

import engine.domain.entities.BaseEntity;
import engine.domain.specs.EntitySpec;
import engine.domain.types.EntityType;
import engine.domain.repositories.IEntityRepository;
import engine.infrastructure.factories.EngineEntityFactory;
import engine.infrastructure.pooling.ObjectPool;

/**
 * Repository implementation - single entity lifecycle management system
 * Directly manages entities without manager layer
 */
class EntityRepository implements IEntityRepository {
    private final entityFactory: EngineEntityFactory;
    private final pool: ObjectPool;
    private final entities: Map<EntityType, Map<Int, BaseEntity>>;
    private var nextId: Int;
    
    public function new(entityFactory: EngineEntityFactory, pool: ObjectPool) {
        this.entityFactory = entityFactory;
        this.pool = pool;
        this.entities = new Map();
        this.nextId = 1;
    }
    
    /**
     * Create new entity from specification
     * @param spec Entity specification
     * @return Created entity
     */
    public function create(spec: EntitySpec): BaseEntity {
        final entity: BaseEntity = entityFactory.create(spec.type, spec);
        if (entity.id == 0) {
            entity.id = allocateId();
        }
        
        // Get or create type map
        if (!entities.exists(spec.type)) {
            entities.set(spec.type, new Map());
        }
        
        // Store entity
        entities.get(spec.type).set(entity.id, entity);
        return entity;
    }
    
    /**
     * Find entity by ID across all types
     * @param id Entity ID
     * @return Entity or null
     */
    public function findById(id: Int): BaseEntity {
        for (typeMap in entities) {
            if (typeMap.exists(id)) {
                return typeMap.get(id);
            }
        }
        return null;
    }
    
    /**
     * Find all alive entities
     * @return Array of entities
     */
    public function findAll(): Array<BaseEntity> {
        final result: Array<BaseEntity> = [];
        for (typeMap in entities) {
            for (entity in typeMap) {
                if (entity.isAlive) {
                    result.push(entity);
                }
            }
        }
        return result;
    }
    
    /**
     * Find all entities of a specific type
     * @param type Entity type
     * @return Array of entities
     */
    public function findByType(type: EntityType): Array<BaseEntity> {
        final result: Array<BaseEntity> = [];
        if (entities.exists(type)) {
            for (entity in entities.get(type)) {
                result.push(entity);
            }
        }
        return result;
    }
    
    /**
     * Save/update entity (no-op as entities are updated in-place)
     * @param entity Entity to save
     */
    public function save(entity: BaseEntity): Void {
        // Entities are updated in-place, this is for interface compliance
    }
    
    /**
     * Delete entity by ID
     * @param id Entity ID
     */
    public function delete(id: Int): Void {
        for (type in entities.keys()) {
            final typeMap = entities.get(type);
            if (typeMap.exists(id)) {
                final entity = typeMap.get(id);
                typeMap.remove(id);
                entityFactory.release(entity);
                return;
            }
        }
    }
    
    /**
     * Check if entity exists
     * @param id Entity ID
     * @return True if entity exists
     */
    public function exists(id: Int): Bool {
        return findById(id) != null;
    }
    
    /**
     * Iterate over all entities
     * @param fn Function to call for each entity
     */
    public function iterate(fn: BaseEntity->Void): Void {
        for (typeMap in entities) {
            for (entity in typeMap) {
                fn(entity);
            }
        }
    }
    
    /**
     * Iterate over entities of specific type
     * @param type Entity type
     * @param fn Function to call for each entity
     */
    public function iterateType(type: EntityType, fn: BaseEntity->Void): Void {
        if (entities.exists(type)) {
            for (entity in entities.get(type)) {
                fn(entity);
            }
        }
    }
    
    /**
     * Save all entities as memento
     * @return Array of entity mementos grouped by type
     */
    public function saveMemento(): Array<Dynamic> {
        final result = [];
        for (type in entities.keys()) {
            final typeEntities = [];
            for (entity in entities.get(type)) {
                typeEntities.push(entity.serialize());
            }
            result.push({
                type: type,
                entities: typeEntities
            });
        }
        return result;
    }
    
    /**
     * Restore entities from memento
     * @param memento Array of entity mementos grouped by type
     */
    public function restoreMemento(memento: Array<Dynamic>): Void {
        // Clear existing entities
        clear();
        
        // Restore each type's entities
        for (typeData in memento) {
            final type: EntityType = typeData.type;
            final entityMementos: Array<Dynamic> = typeData.entities;
            
            if (!entities.exists(type)) {
                entities.set(type, new Map());
            }
            
            for (entityMemento in entityMementos) {
                // Create base spec for entity instantiation
                final spec: EntitySpec = {
                    type: entityMemento.type,
                    pos: entityMemento.pos,
                    vel: entityMemento.vel,
                    ownerId: entityMemento.ownerId
                };
                
                // Create entity (this will call entity constructor and reset())
                final entity = entityFactory.create(entityMemento.type, spec);
                
                // Deserialize full state (includes entity-specific fields)
                entity.deserialize(entityMemento);
                
                // Store in repository
                entities.get(type).set(entity.id, entity);
                
                // Update nextId to ensure no ID collision
                if (entity.id >= nextId) {
                    nextId = entity.id + 1;
                }
            }
        }
    }
    
    /**
     * Clear all entities
     */
    public function clear(): Void {
        for (typeMap in entities) {
            for (entity in typeMap) {
                entityFactory.release(entity);
            }
            typeMap.clear();
        }
        entities.clear();
    }
    
    /**
     * Allocate next entity ID
     * @return New entity ID
     */
    private function allocateId(): Int {
        return nextId++;
    }
}
