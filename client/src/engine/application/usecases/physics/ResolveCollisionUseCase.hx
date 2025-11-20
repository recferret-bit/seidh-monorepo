package engine.application.usecases.physics;

import engine.application.ports.output.IEventPublisher;
import engine.domain.repositories.IEntityRepository;
import engine.domain.services.CollisionService;
import engine.domain.entities.collider.ColliderEntity;

/**
 * Use case: Resolve collisions
 */
class ResolveCollisionUseCase {
    private final entityRepository: IEntityRepository;
    private final eventPublisher: IEventPublisher;
    private final collisionService: CollisionService;
    
    public function new(
        entityRepository: IEntityRepository,
        eventPublisher: IEventPublisher,
        collisionService: CollisionService
    ) {
        this.entityRepository = entityRepository;
        this.eventPublisher = eventPublisher;
        this.collisionService = collisionService;
    }
    
    /**
     * Execute resolve collision use case
     * @param tick Current game tick
     */
    public function execute(tick: Int): Void {
        // 1. Find all entities
        final allEntities = entityRepository.findAll();
        
        // 2. Separate entities and colliders
        final entities = [];
        final colliders = [];
        
        for (entity in allEntities) {
            if (entity.isAlive) {
                if (entity.entityType == "collider") {
                    colliders.push(cast(entity, ColliderEntity));
                } else {
                    entities.push(entity);
                }
            }
        }
        
        // 3. Check collisions between entities and colliders
        for (entity in entities) {
            for (collider in colliders) {
                if (collisionService.checkColliderCollision(entity, collider)) {
                    // Calculate separation
                    final separation = collisionService.calculateSeparation(entity, collider);
                    if (separation != null) {
                        // Apply separation to entity position
                        entity.position = entity.position.add(separation.x, separation.y);
                        entityRepository.save(entity);
                    }
                }
            }
        }
        
        // 4. Check collisions between entities
        for (i in 0...entities.length) {
            for (j in i + 1...entities.length) {
                final entityA = entities[i];
                final entityB = entities[j];
                
                if (collisionService.checkCollision(entityA, entityB)) {
                    // Calculate separation
                    final separation = collisionService.calculateSeparation(entityA, entityB);
                    if (separation != null) {
                        // Apply separation to entityA position
                        entityA.position = entityA.position.add(separation.x, separation.y);
                        entityRepository.save(entityA);
                    }
                }
            }
        }
    }
}

