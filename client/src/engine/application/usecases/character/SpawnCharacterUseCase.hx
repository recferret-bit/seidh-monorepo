package engine.application.usecases.character;

import engine.domain.repositories.IEntityRepository;
import engine.application.ports.output.IEventPublisher;
import engine.infrastructure.services.IdGeneratorService;
import engine.application.dto.SpawnCharacterRequest;
import engine.domain.entities.character.base.BaseCharacterEntity;
import engine.domain.entities.character.factory.CharacterEntityFactory;
import engine.domain.valueobjects.Position;
import engine.domain.valueobjects.Health;
import engine.domain.events.EntitySpawned;

/**
 * Use case: Spawn a character entity
 */
class SpawnCharacterUseCase {
    private final entityRepository: IEntityRepository;
    private final eventPublisher: IEventPublisher;
    private final idGenerator: IdGeneratorService;
    private final characterFactory: CharacterEntityFactory;
    
    public function new(
        entityRepository: IEntityRepository,
        eventPublisher: IEventPublisher,
        idGenerator: IdGeneratorService,
        characterFactory: CharacterEntityFactory
    ) {
        this.entityRepository = entityRepository;
        this.eventPublisher = eventPublisher;
        this.idGenerator = idGenerator;
        this.characterFactory = characterFactory;
    }
    
    /**
     * Execute spawn character use case
     * @param request Spawn request
     * @return Created entity ID
     */
    public function execute(request: SpawnCharacterRequest): Int {
        // 1. Generate ID
        final entityId = idGenerator.generate();
        
        // 2. Create domain entity
        final position = new Position(request.x, request.y);
        final health = new Health(request.maxHp, request.maxHp);
        final character = characterFactory.create(
            request.entityType,
            entityId,
            position,
            health,
            request.ownerId,
            request.level,
            request.stats
        );
        
        // 3. Persist entity
        entityRepository.save(character);
        
        // 4. Publish domain event
        // Note: tick should be passed from caller, but for now we'll use 0 and let EventPublisher set it
        eventPublisher.publish(new EntitySpawned(
            entityId,
            request.entityType,
            position,
            request.ownerId,
            0 // tick will be set by event publisher from state
        ));
        
        return entityId;
    }
}

