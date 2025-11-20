package engine.infrastructure.managers;

import engine.domain.entities.BaseEntity;
import engine.domain.types.EntityType;
import engine.infrastructure.managers.IEngineEntityManager;

/**
 * Interface for entity manager registry
 * Provides type-safe access to entity managers
 */
interface IEngineEntityManagerRegistry {
    /**
     * Register a manager for a specific entity type
     * @param type Entity type
     * @param manager Manager instance
     */
    function register<T:BaseEntity>(type: EntityType, manager: IEngineEntityManager<T>): Void;
    
    /**
     * Get manager by entity type
     * @param type Entity type
     * @return Manager or null
     */
    function get<T:BaseEntity>(type: EntityType): IEngineEntityManager<T>;
    
    /**
     * Get all managers
     * @return Array of managers
     */
    function getAll(): Array<IEngineEntityManager<BaseEntity>>;
    
    /**
     * Update all managers for this tick
     * @param dt Delta time
     * @param tick Current tick
     * @param state Game state
     */
    function updateAll(dt: Float, tick: Int, state: Dynamic): Void;
    
    /**
     * Save all managers as memento
     * @return Array of manager mementos
     */
    function saveMemento(): Array<Dynamic>;
    
    /**
     * Restore managers from memento
     * @param mementos Array of manager mementos
     */
    function restoreMemento(mementos: Array<Dynamic>): Void;
    
    /**
     * Clear all managers
     */
    function clear(): Void;
}

