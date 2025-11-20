package engine.application.usecases.input;

import engine.application.ports.input.IInputHandler;
import engine.application.dto.ProcessInputRequest;
import engine.application.usecases.character.MoveCharacterUseCase;
import engine.application.usecases.character.AttackCharacterUseCase;
import engine.domain.repositories.ICharacterRepository;
import engine.domain.services.TargetingService;

/**
 * Use case: Process player input
 */
class ProcessInputUseCase implements IInputHandler {
    private final moveCharacterUseCase: MoveCharacterUseCase;
    private final attackCharacterUseCase: AttackCharacterUseCase;
    private final characterRepository: ICharacterRepository;
    private final targetingService: TargetingService;
    
    public function new(
        moveCharacterUseCase: MoveCharacterUseCase,
        attackCharacterUseCase: AttackCharacterUseCase,
        characterRepository: ICharacterRepository,
        targetingService: TargetingService
    ) {
        this.moveCharacterUseCase = moveCharacterUseCase;
        this.attackCharacterUseCase = attackCharacterUseCase;
        this.characterRepository = characterRepository;
        this.targetingService = targetingService;
    }
    
    /**
     * Handle input request
     * @param request Input request
     */
    public function handleInput(request: ProcessInputRequest): Void {
        final character = characterRepository.findById(request.entityId);
        if (character == null || !character.isAlive) {
            return;
        }
        
        // Process movement
        if (request.movement.x != 0 || request.movement.y != 0) {
            moveCharacterUseCase.execute({
                entityId: character.id,
                deltaX: request.movement.x,
                deltaY: request.movement.y,
                deltaTime: request.deltaTime,
                tick: request.tick
            });
        }
        
        // Process actions
        for (action in request.actions) {
            switch (action.type) {
                case "primary_action":
                    // Find nearest enemy and attack
                    final target = targetingService.findNearestEnemy(character, 50.0, {
                        allowNeutralTargets: true
                    });
                    if (target != null) {
                        attackCharacterUseCase.execute(character.id, target.id, request.tick);
                    }
                case "secondary_action":
                    // TODO: Implement BlockCharacterUseCase
                case "ability":
                    // TODO: Implement UseAbilityUseCase
                default:
                    // Unknown action type
            }
        }
    }
}

