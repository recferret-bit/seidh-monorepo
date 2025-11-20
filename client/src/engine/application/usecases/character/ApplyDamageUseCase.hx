package engine.application.usecases.character;

import engine.domain.repositories.ICharacterRepository;
import engine.application.ports.output.IEventPublisher;

/**
 * Use case: Apply damage to a character
 */
class ApplyDamageUseCase {
    private final characterRepository: ICharacterRepository;
    private final eventPublisher: IEventPublisher;
    
    public function new(characterRepository: ICharacterRepository, eventPublisher: IEventPublisher) {
        this.characterRepository = characterRepository;
        this.eventPublisher = eventPublisher;
    }
    
    /**
     * Execute apply damage use case
     * @param entityId Target entity ID
     * @param amount Damage amount
     * @param attackerId Attacker entity ID
     * @param tick Current game tick
     */
    public function execute(entityId: Int, amount: Int, attackerId: Int, tick: Int): Void {
        // 1. Load entity from repository
        final character = characterRepository.findById(entityId);
        if (character == null || !character.isAlive) {
            return; // Entity not found or dead
        }
        
        // 2. Execute domain logic
        character.takeDamage(amount, attackerId, tick);
        
        // 3. Persist changes
        characterRepository.save(character);
        
        // 4. Publish domain events
        final events = character.getDomainEvents();
        for (event in events) {
            eventPublisher.publish(event);
        }
    }
}

