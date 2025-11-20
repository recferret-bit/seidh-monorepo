package engine.application.usecases.consumable;

import engine.domain.repositories.IEntityRepository;
import engine.application.ports.output.IEventPublisher;
import engine.application.dto.ConsumeItemRequest;
import engine.domain.entities.consumable.base.BaseConsumableEntity;
import engine.domain.entities.character.base.BaseCharacterEntity;
import engine.application.usecases.character.ApplyDamageUseCase;

/**
 * Use case: Consume an item
 */
class ConsumeItemUseCase {
    private final entityRepository: IEntityRepository;
    private final eventPublisher: IEventPublisher;

    public function new(
        entityRepository: IEntityRepository,
        eventPublisher: IEventPublisher
    ) {
        this.entityRepository = entityRepository;
        this.eventPublisher = eventPublisher;
    }

    /**
     * Execute consume item use case
     * @param request Consume request
     * @return True if item was consumed, false otherwise
     */
    public function execute(request: ConsumeItemRequest): Bool {
        // 1. Load consumable entity from repository
        final consumable = cast(entityRepository.findById(request.entityId), BaseConsumableEntity);
        if (consumable == null || !consumable.canBeUsed()) {
            return false; // Consumable not found or cannot be used
        }

        // 2. Check if consumer is in range (optional, can be enhanced)
        final consumer = cast(entityRepository.findById(request.consumerId), BaseCharacterEntity);
        if (consumer == null || !consumer.isAlive) {
            return false; // Consumer not found or dead
        }

        // Simple range check (distance between positions)
        final dx = consumer.position.x - consumable.position.x;
        final dy = consumer.position.y - consumable.position.y;
        final distance = Math.sqrt(dx * dx + dy * dy);
        if (distance > consumable.useRange) {
            return false; // Out of range
        }

        // 3. Execute domain logic (consume the item)
        final consumed = consumable.consume(request.tick);
        if (!consumed) {
            return false;
        }

        // 4. Apply effect based on effectId
        applyEffect(consumable.effectId, consumer, request.tick);

        // 5. Persist changes
        entityRepository.save(consumable);
        entityRepository.save(consumer);

        // 6. Publish domain events
        final consumableEvents = consumable.getDomainEvents();
        for (event in consumableEvents) {
            eventPublisher.publish(event);
        }

        final consumerEvents = consumer.getDomainEvents();
        for (event in consumerEvents) {
            eventPublisher.publish(event);
        }

        return true;
    }

    /**
     * Apply effect to character based on effect ID
     * @param effectId Effect ID
     * @param character Character to apply effect to
     * @param tick Current game tick
     */
    private function applyEffect(effectId: String, character: BaseCharacterEntity, tick: Int): Void {
        switch (effectId) {
            case "heal", "health_potion":
                // Heal for 50 HP (can be made configurable)
                character.heal(50);
            case "armor", "armor_potion":
                // Increase defense temporarily (simplified - just increase stats)
                // TODO: Implement proper buff system
                character.stats = new engine.domain.entities.character.base.CharacterStats(
                    character.stats.power,
                    character.stats.defense + 10,
                    character.stats.speed,
                    character.stats.castSpeed
                );
            case "salmon":
                // Salmon heals for 25 HP
                character.heal(25);
            default:
                // Unknown effect - do nothing
        }
    }
}

