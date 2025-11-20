package engine.domain.repositories;

import engine.domain.entities.BaseEntity;

/**
 * Repository interface for entity persistence
 * Implementation will be created in Phase 2 (infrastructure layer)
 */
interface IEntityRepository {
    /**
     * Find entity by ID
     * @param id Entity ID
     * @return Entity or null if not found
     */
    function findById(id: Int): BaseEntity;
    
    /**
     * Find all entities
     * @return Array of all entities
     */
    function findAll(): Array<BaseEntity>;
    
    /**
     * Save entity (create or update)
     * @param entity Entity to save
     */
    function save(entity: BaseEntity): Void;
    
    /**
     * Delete entity by ID
     * @param id Entity ID
     */
    function delete(id: Int): Void;
    
    /**
     * Check if entity exists
     * @param id Entity ID
     * @return True if entity exists
     */
    function exists(id: Int): Bool;
}

