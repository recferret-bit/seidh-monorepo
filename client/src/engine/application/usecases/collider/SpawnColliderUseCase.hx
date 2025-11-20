package engine.application.usecases.collider;

import engine.domain.repositories.IEntityRepository;
import engine.application.ports.output.IEventPublisher;
import engine.infrastructure.utilities.IdGeneratorService;
import engine.application.dto.SpawnColliderRequest;
import engine.domain.entities.collider.ColliderEntity;
import engine.domain.entities.collider.ColliderEntityFactory;
import engine.domain.geometry.Vec2;
import engine.domain.specs.ColliderSpec;
import engine.domain.types.EntityType;
import engine.domain.valueobjects.Position;
import engine.domain.events.EntitySpawned;

/**
 * Use case: Spawn a collider entity
 */
class SpawnColliderUseCase {
    private final entityRepository: IEntityRepository;
    private final eventPublisher: IEventPublisher;
    private final idGenerator: IdGeneratorService;
    private final colliderFactory: ColliderEntityFactory;

    public function new(
        entityRepository: IEntityRepository,
        eventPublisher: IEventPublisher,
        idGenerator: IdGeneratorService,
        colliderFactory: ColliderEntityFactory
    ) {
        this.entityRepository = entityRepository;
        this.eventPublisher = eventPublisher;
        this.idGenerator = idGenerator;
        this.colliderFactory = colliderFactory;
    }

    /**
     * Execute spawn collider use case
     * @param request Spawn request
     * @return Created entity ID
     */
    public function execute(request: SpawnColliderRequest): Int {
        // 1. Generate ID
        final entityId = idGenerator.generate();

        // 2. Build ColliderSpec
        final position = new Position(request.x, request.y);
        final spec: ColliderSpec = {
            type: EntityType.COLLIDER,
            pos: new Vec2(Std.int(position.x), Std.int(position.y)),
            vel: new Vec2(0, 0),
            ownerId: request.ownerId,
            id: entityId,
            isAlive: true,
            colliderWidth: request.width,
            colliderHeight: request.height,
            passable: request.passable,
            isTrigger: request.isTrigger
        };

        // 3. Create domain entity
        final collider = colliderFactory.create(spec);

        // 4. Persist entity
        entityRepository.save(collider);

        // 5. Publish domain event
        eventPublisher.publish(new EntitySpawned(
            entityId,
            "collider",
            position,
            request.ownerId,
            0 // tick will be set by event publisher from state
        ));

        return entityId;
    }
}

