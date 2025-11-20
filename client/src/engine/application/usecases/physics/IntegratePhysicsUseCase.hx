package engine.application.usecases.physics;

import engine.application.ports.output.IEventPublisher;
import engine.domain.repositories.IEntityRepository;
import engine.domain.services.PhysicsCalculationService;

/**
 * Use case: Integrate physics (velocity to position)
 */
class IntegratePhysicsUseCase {
    private final entityRepository: IEntityRepository;
    private final eventPublisher: IEventPublisher;
    private final physicsService: PhysicsCalculationService;
    
    public function new(
        entityRepository: IEntityRepository,
        eventPublisher: IEventPublisher,
        physicsService: PhysicsCalculationService
    ) {
        this.entityRepository = entityRepository;
        this.eventPublisher = eventPublisher;
        this.physicsService = physicsService;
    }
    
    /**
     * Execute integrate physics use case
     * @param dt Delta time
     * @param tick Current game tick
     */
    public function execute(dt: Float, tick: Int): Void {
        // 1. Find all entities
        final allEntities = entityRepository.findAll();
        
        // 2. Integrate physics for non-input-driven entities
        for (entity in allEntities) {
            if (entity.isAlive && !entity.isInputDriven) {
                // Use physics service to integrate velocity
                final newPosition = physicsService.integrateVelocity(
                    entity.position,
                    entity.velocity,
                    dt
                );
                
                // Update entity position
                entity.position = newPosition;
                
                // Save entity
                entityRepository.save(entity);
                
                // Publish domain events
                final events = entity.getDomainEvents();
                for (event in events) {
                    eventPublisher.publish(event);
                }
            }
        }
    }
}

