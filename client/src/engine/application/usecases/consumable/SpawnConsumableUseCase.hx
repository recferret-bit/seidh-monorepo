package engine.application.usecases.consumable;

import engine.domain.repositories.IEntityRepository;
import engine.application.ports.output.IEventPublisher;
import engine.infrastructure.utilities.IdGeneratorService;
import engine.application.dto.SpawnConsumableRequest;
import engine.domain.entities.consumable.base.BaseConsumableEntity;
import engine.domain.entities.consumable.factory.ConsumableEntityFactory;
import engine.domain.geometry.Vec2;
import engine.domain.specs.ConsumableSpec;
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

        // 2. Build ConsumableSpec
        final position = new Position(request.x, request.y);
        final spec: ConsumableSpec = {
            type: cast request.entityType,
            pos: new Vec2(Std.int(position.x), Std.int(position.y)),
            vel: new Vec2(0, 0),
            ownerId: request.ownerId,
            id: entityId,
            isAlive: true,
            effectId: request.effectId,
            durationTicks: request.durationTicks,
            stackable: request.stackable,
            charges: request.charges,
            useRange: request.useRange
        };

        // 3. Create domain entity
        final consumable = consumableFactory.create(spec);

        // 4. Persist entity
        entityRepository.save(consumable);

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

