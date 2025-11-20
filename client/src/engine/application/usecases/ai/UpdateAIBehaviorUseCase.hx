package engine.application.usecases.ai;

import engine.domain.repositories.ICharacterRepository;
import engine.application.usecases.character.MoveCharacterUseCase;
import engine.application.usecases.character.AttackCharacterUseCase;
import engine.application.dto.MoveCharacterRequest;
import engine.domain.services.AIDecisionService;
import engine.domain.services.DeterministicRng;
import engine.domain.entities.character.base.BaseCharacterEntity;

/**
 * Use case: Update AI behavior and execute actions
 */
class UpdateAIBehaviorUseCase {
    private final characterRepository: ICharacterRepository;
    private final moveCharacterUseCase: MoveCharacterUseCase;
    private final attackCharacterUseCase: AttackCharacterUseCase;
    private final aiDecisionService: AIDecisionService;
    private final rng: DeterministicRng;
    
    public function new(
        characterRepository: ICharacterRepository,
        moveCharacterUseCase: MoveCharacterUseCase,
        attackCharacterUseCase: AttackCharacterUseCase,
        aiDecisionService: AIDecisionService,
        rng: DeterministicRng
    ) {
        this.characterRepository = characterRepository;
        this.moveCharacterUseCase = moveCharacterUseCase;
        this.attackCharacterUseCase = attackCharacterUseCase;
        this.aiDecisionService = aiDecisionService;
        this.rng = rng;
    }
    
    /**
     * Execute update AI behavior use case
     * @param entityId Entity ID
     * @param dt Delta time
     * @param tick Current game tick
     */
    public function execute(entityId: Int, dt: Float, tick: Int): Void {
        // 1. Load entity from repository
        final character = characterRepository.findById(entityId);
        if (character == null || !character.isAlive || character.ownerId != "") {
            return; // Not an AI entity (AI entities have empty ownerId)
        }
        
        // 2. Make AI decision (pass entity repository for finding targets)
        final decision = aiDecisionService.makeDecision(character, rng);
        
        // 3. Execute decision
        switch (decision.action) {
            case "move":
                final speed = character.stats.speed * 32.0; // Assuming 32 pixels per unit
                moveCharacterUseCase.execute({
                    entityId: entityId,
                    deltaX: decision.movementX * speed,
                    deltaY: decision.movementY * speed,
                    deltaTime: dt,
                    tick: tick
                });
            case "attack":
                if (decision.targetId != null) {
                    attackCharacterUseCase.execute(entityId, decision.targetId, tick);
                }
            case "idle":
                // Do nothing
        }
    }
    
    /**
     * Update all AI entities
     * @param dt Delta time
     * @param tick Current game tick
     */
    public function updateAll(dt: Float, tick: Int): Void {
        final allCharacters = characterRepository.findAll();
        for (character in allCharacters) {
            if (character.isAlive && character.ownerId == "") {
                execute(character.id, dt, tick);
            }
        }
    }
}

