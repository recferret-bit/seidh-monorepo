package engine.application.usecases.character;

import engine.domain.repositories.IEntityRepository;
import engine.application.ports.output.IEventPublisher;

/**
 * Use case: Clean up dead entities
 */
class CleanupDeadEntitiesUseCase {
    private final entityRepository: IEntityRepository;
    private final eventPublisher: IEventPublisher;
    
    public function new(entityRepository: IEntityRepository, eventPublisher: IEventPublisher) {
        this.entityRepository = entityRepository;
        this.eventPublisher = eventPublisher;
    }
    
    /**
     * Execute cleanup dead entities use case
     * @param tick Current game tick
     */
    public function execute(tick: Int): Void {
        // 1. Find all entities
        final allEntities = entityRepository.findAll();
        
        // 2. Find dead entities
        final deadEntities = [];
        for (entity in allEntities) {
            if (!entity.isAlive) {
                deadEntities.push(entity.id);
            }
        }
        
        // 3. Delete dead entities
        for (entityId in deadEntities) {
            entityRepository.delete(entityId);
        }
    }
}

