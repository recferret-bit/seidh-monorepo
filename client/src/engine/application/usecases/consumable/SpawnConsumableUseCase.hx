package engine.application.usecases.consumable;

import engine.domain.repositories.IEntityRepository;
import engine.application.ports.output.IEventPublisher;
import engine.infrastructure.utilities.IdGeneratorService;
import engine.application.dto.SpawnConsumableRequest;
import engine.domain.entities.consumable.base.BaseConsumableEntity;
import engine.domain.entities.consumable.factory.ConsumableEntityFactory;
import engine.domain.valueobjects.Position;
import engine.domain.events.EntitySpawned;

/**
 * Use case: Spawn a consumable entity
 */
class SpawnConsumableUseCase {
    private final entityRepository: IEntityRepository;
    private final eventPublisher: IEventPublisher;
    private final idGenerator: IdGeneratorService;
    private final consumableFactory: ConsumableEntityFactory;

    public function new(
        entityRepository: IEntityRepository,
        eventPublisher: IEventPublisher,
        idGenerator: IdGeneratorService,
        consumableFactory: ConsumableEntityFactory
    ) {
        this.entityRepository = entityRepository;
        this.eventPublisher = eventPublisher;
        this.idGenerator = idGenerator;
        this.consumableFactory = consumableFactory;
    }

    /**
     * Execute spawn consumable use case
     * @param request Spawn request
     * @return Created entity ID
     */
    public function execute(request: SpawnConsumableRequest): Int {
        // 1. Generate ID
        final entityId = idGenerator.generate();

        // 2. Create domain entity using factory
        final position = new Position(request.x, request.y);
        final consumable = consumableFactory.create(
            request.entityType,
            entityId,
            position,
            request.ownerId,
            request.effectId,
            request.durationTicks,
            request.stackable,
            request.charges,
            request.useRange
        );

        // 3. Persist entity
        entityRepository.save(consumable);

        // 4. Publish domain event
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

