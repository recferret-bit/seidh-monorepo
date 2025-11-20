package engine.infrastructure.managers;

import engine.domain.entities.BaseEntity;
import engine.domain.specs.EntitySpec;

/**
 * Entity manager contract
 */
interface IEngineEntityManager<T:BaseEntity> {
    /**
     * Create new entity
     * @param entityType Entity type
     * @param spec Entity specification
     * @return Created entity
     */
    function create(spec: EntitySpec): T;
    
    /**
     * Destroy entity by ID
     * @param id Entity ID
     */
    function destroy(id: Int): Void;
    
    /**
     * Find entity by ID
     * @param id Entity ID
     * @return Entity or null
     */
    function find(id: Int): T;
    
    /**
     * Iterate over all entities
     * @param fn Function to call for each entity
     */
    function iterate(fn: T->Void): Void;
    
    /**
     * Update entities for this tick
     * @param dt Delta time
     * @param tick Current tick
     * @param state Game state
     */
    function updateTick(dt: Float, tick: Int, state: Dynamic): Void;
    
    /**
     * Save all entities as memento
     * @return Array of entity mementos
     */
    function saveMemento(): Array<Dynamic>;
    
    /**
     * Restore entities from memento
     * @param mementos Array of entity mementos
     */
    function restoreMemento(mementos: Array<Dynamic>): Void;

    /**
     * Clear all entities from this manager
     */
    function clear(): Void;
}

