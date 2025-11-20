package engine.application.usecases.character;

import engine.domain.repositories.ICharacterRepository;
import engine.application.usecases.character.ApplyDamageUseCase;

/**
 * Use case: Kill a character
 */
class KillCharacterUseCase {
    private final characterRepository: ICharacterRepository;
    private final applyDamageUseCase: ApplyDamageUseCase;
    
    public function new(
        characterRepository: ICharacterRepository,
        applyDamageUseCase: ApplyDamageUseCase
    ) {
        this.characterRepository = characterRepository;
        this.applyDamageUseCase = applyDamageUseCase;
    }
    
    /**
     * Execute kill character use case
     * @param entityId Entity ID to kill
     * @param killerId Killer entity ID
     * @param tick Current game tick
     */
    public function execute(entityId: Int, killerId: Int, tick: Int): Void {
        // 1. Load entity from repository
        final character = characterRepository.findById(entityId);
        if (character == null || !character.isAlive) {
            return; // Entity not found or already dead
        }
        
        // 2. Apply lethal damage using ApplyDamageUseCase
        applyDamageUseCase.execute(entityId, character.health.current, killerId, tick);
    }
}

