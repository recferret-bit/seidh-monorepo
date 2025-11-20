package engine.infrastructure.managers;

import engine.domain.entities.BaseEntity;
import engine.domain.types.EntityType;
import engine.infrastructure.managers.IEngineEntityManager;
import engine.infrastructure.managers.IEngineEntityManagerRegistry;

/**
 * Registry for all entity managers
 * Provides type-safe access to entity managers without Dynamic
 */
class EngineEntityManagerRegistry implements IEngineEntityManagerRegistry {
    private var managers: Map<EntityType, IEngineEntityManager<BaseEntity>>;
    
    public function new() {
        managers = new Map();
    }
    
    /**
     * Register a manager
     * @param type Entity type
     * @param manager Manager instance
     */
    public function register<T:BaseEntity>(type: EntityType, manager: IEngineEntityManager<T>): Void {
        managers.set(type, cast manager);
    }
    
    /**
     * Get manager by entity type
     * @param type Entity type
     * @return Manager or null
     */
    public function get<T:BaseEntity>(type: EntityType): IEngineEntityManager<T> {
        return cast managers.get(type);
    }
    
    /**
     * Get all managers
     * @return Array of managers
     */
    public function getAll(): Array<IEngineEntityManager<BaseEntity>> {
        final result = [];
        for (manager in managers) {
            result.push(manager);
        }
        return result;
    }
    
    /**
     * Update all managers for this tick
     * @param dt Delta time
     * @param tick Current tick
     * @param state Game state
     */
    public function updateAll(dt: Float, tick: Int, state: Dynamic): Void {
        for (manager in managers) {
            manager.updateTick(dt, tick, state);
        }
    }
    
    /**
     * Save all managers as memento
     * @return Array of manager mementos
     */
    public function saveMemento(): Array<Dynamic> {
        final result = [];
        for (type in managers.keys()) {
            final manager = managers.get(type);
            result.push({
                type: type,
                entities: manager.saveMemento()
            });
        }
        return result;
    }
    
    /**
     * Restore managers from memento
     * @param mementos Array of manager mementos
     */
    public function restoreMemento(mementos: Array<Dynamic>): Void {
        // Clear existing managers
        clear();
        
        // Restore each manager
        for (memento in mementos) {
            final manager = managers.get(memento.type);
            if (manager != null) {
                manager.restoreMemento(memento.entities);
            }
        }
    }

    public function clear(): Void {
        for (type in managers.keys()) {
            managers.get(type).clear();
        }
    }
}

