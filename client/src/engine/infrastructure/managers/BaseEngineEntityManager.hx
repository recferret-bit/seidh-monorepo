package engine.infrastructure.managers;

import engine.domain.entities.BaseEntity;
import engine.domain.specs.EntitySpec;
import engine.infrastructure.factories.EngineEntityFactory;

/**
 * Generic entity manager implementation
 */
class BaseEngineEntityManager<T:BaseEntity> implements IEngineEntityManager<T> {
    private var entities: Map<Int, T>;
    private var factory: EngineEntityFactory;
    private var nextId: Int;
    
    public function new(factory: EngineEntityFactory) {
        this.factory = factory;
        entities = new Map();
        nextId = 1;
    }
    
    public function create(spec: EntitySpec): T {
        final entity: T = cast factory.create(spec.type, spec);
        if (entity.id == 0) {
            entity.id = allocateId();
        }
        entities.set(entity.id, entity);
        return entity;
    }
    
    public function destroy(id: Int): Void {
        if (entities.exists(id)) {
            final entity = entities.get(id);
            entities.remove(id);
            factory.release(entity);
        }
    }
    
    public function find(id: Int): T {
        return entities.exists(id) ? entities.get(id) : null;
    }
    
    public function iterate(fn: T->Void): Void {
        for (entity in entities) {
            fn(entity);
        }
    }
    
    public function updateTick(dt: Float, tick: Int, state: Dynamic): Void {
        // Override in concrete managers for entity-specific updates
    }
    
    /**
     * Save all entities as memento
     * @return Array of entity mementos
     */
    public function saveMemento(): Array<Dynamic> {
        final result = [];
        for (id in entities.keys()) {
            final entity = entities.get(id);
            result.push(entity.serialize());
        }
        return result;
    }
    
    /**
     * Restore entities from memento
     * @param mementos Array of entity mementos
     */
    public function restoreMemento(mementos: Array<Dynamic>): Void {
        // Clear existing entities
        clear();
        
        // Restore each entity
        for (memento in mementos) {
            // Convert memento to spec
            final spec: EntitySpec = {
                id: memento.id,
                type: memento.type,
                pos: memento.pos,
                vel: memento.vel,
                rotation: memento.rotation,
                ownerId: memento.ownerId,
                isAlive: memento.isAlive,
                maxHp: memento.maxHp,
                hp: memento.hp,
                level: memento.level,
                stats: memento.stats,
                attackDefs: memento.attackDefs,
                spellBook: memento.spellBook,
                aiProfile: memento.aiProfile,
                effectType: memento.effectType,
                duration: memento.duration,
                consumableType: memento.consumableType,
                quantity: memento.quantity
            };
            final entity = cast factory.create(memento.type, spec);
            entities.set(entity.id, cast entity);
        }
    }
    
    /**
     * Clear all entities from this manager
     */
    public function clear(): Void {
        for (id in entities.keys()) {
            final entity = entities.get(id);
            factory.release(entity);
        }
        entities.clear();
    }
    
    private function allocateId(): Int {
        return nextId++;
    }
}

