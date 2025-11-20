package engine.infrastructure.persistence;

import engine.domain.entities.BaseEntity;
import engine.domain.entities.character.factory.CharacterEntityFactory;
import engine.domain.entities.collider.ColliderEntityFactory;
import engine.domain.entities.consumable.factory.ConsumableEntityFactory;
import engine.domain.repositories.IEntityRepository;
import engine.infrastructure.state.GameModelState;

/**
 * Simplified repository implementation - now directly uses domain entities
 * No conversion needed since entities are in domain layer
 */
class EntityRepository implements IEntityRepository {
    private final state: GameModelState;
    private final characterFactory: CharacterEntityFactory;
    private final consumableFactory: ConsumableEntityFactory;
    private final colliderFactory: ColliderEntityFactory;
    
    public function new(
        state: GameModelState,
        characterFactory: CharacterEntityFactory,
        consumableFactory: ConsumableEntityFactory,
        colliderFactory: ColliderEntityFactory
    ) {
        this.state = state;
        this.characterFactory = characterFactory;
        this.consumableFactory = consumableFactory;
        this.colliderFactory = colliderFactory;
    }
    
    // Entities are now in domain layer, no conversion needed!
    // Repository now just wraps the manager registry for a cleaner API
    
    public function findById(id: Int): BaseEntity {
        for (manager in state.managers.getAll()) {
            final entity = manager.find(id);
            if (entity != null) {
                return entity;
            }
        }
        return null;
    }
    
    public function findAll(): Array<BaseEntity> {
        final result: Array<BaseEntity> = [];
        for (manager in state.managers.getAll()) {
            manager.iterate(function(entity) {
                if (entity.isAlive) {
                    result.push(entity);
                }
            });
        }
        return result;
    }
    
    public function save(entity: BaseEntity): Void {
        // Entities are already managed by the managers
        // This method is mainly for interface compliance
        // No action needed as entities are updated in-place
    }
    
    public function delete(id: Int): Void {
        for (manager in state.managers.getAll()) {
            final entity = manager.find(id);
            if (entity != null) {
                manager.destroy(id);
                return;
            }
        }
    }
    
    public function exists(id: Int): Bool {
        return findById(id) != null;
    }
}
