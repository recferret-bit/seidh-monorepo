package engine.application.usecases.character;

import engine.domain.repositories.ICharacterRepository;
import engine.application.ports.output.IEventPublisher;
import engine.application.dto.MoveCharacterRequest;

/**
 * Use case: Move a character
 */
class MoveCharacterUseCase {
    private final characterRepository: ICharacterRepository;
    private final eventPublisher: IEventPublisher;
    
    public function new(characterRepository: ICharacterRepository, eventPublisher: IEventPublisher) {
        this.characterRepository = characterRepository;
        this.eventPublisher = eventPublisher;
    }
    
    /**
     * Execute move character use case
     * @param request Move request
     */
    public function execute(request: MoveCharacterRequest): Void {
        // 1. Load entity from repository
        final character = characterRepository.findById(request.entityId);
        if (character == null || !character.isAlive) {
            return; // Entity not found or dead
        }
        
        // 2. Execute domain logic
        character.move(request.deltaX, request.deltaY, request.deltaTime, request.tick);
        
        // 3. Persist changes
        characterRepository.save(character);
        
        // 4. Publish domain events
        final events = character.getDomainEvents();
        for (event in events) {
            eventPublisher.publish(event);
        }
    }
}

