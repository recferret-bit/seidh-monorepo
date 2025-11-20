package engine.application.usecases.character;

import engine.domain.repositories.IEntityRepository;
import engine.application.ports.output.IEventPublisher;
import engine.infrastructure.utilities.IdGeneratorService;
import engine.application.dto.SpawnCharacterRequest;
import engine.domain.entities.character.base.BaseCharacterEntity;
import engine.domain.entities.character.factory.CharacterEntityFactory;
import engine.domain.geometry.Vec2;
import engine.domain.specs.CharacterSpec;
import engine.domain.valueobjects.Position;
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
        
        // 2. Build CharacterSpec
        final position = new Position(request.x, request.y);
        final spec: CharacterSpec = {
            type: cast request.entityType,
            pos: new Vec2(Std.int(position.x), Std.int(position.y)),
            vel: new Vec2(0, 0),
            ownerId: request.ownerId,
            id: entityId,
            isAlive: true,
            maxHp: request.maxHp,
            hp: request.maxHp,
            level: request.level,
            stats: request.stats
        };
        
        // 3. Create domain entity
        final character = characterFactory.create(spec);
        
        // 4. Persist entity
        entityRepository.save(character);
        
        // 5. Publish domain event
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

