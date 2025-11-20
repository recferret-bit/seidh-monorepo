package engine.application.usecases.character;

import engine.domain.repositories.ICharacterRepository;
import engine.application.usecases.character.ApplyDamageUseCase;

/**
 * Use case: Attack another character
 */
class AttackCharacterUseCase {
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
     * Execute attack character use case
     * @param attackerId Attacker entity ID
     * @param targetId Target entity ID
     * @param tick Current game tick
     */
    public function execute(attackerId: Int, targetId: Int, tick: Int): Void {
        // 1. Load attacker entity
        final attacker = characterRepository.findById(attackerId);
        if (attacker == null || !attacker.isAlive) {
            return; // Attacker not found or dead
        }
        
        // 2. Load target entity
        final target = characterRepository.findById(targetId);
        if (target == null || !target.isAlive) {
            return; // Target not found or dead
        }
        
        // 3. Calculate damage based on attacker stats
        final baseDamage = Std.int(Math.round(attacker.stats.power));
        final defense = target.stats.defense;
        final mitigation = Std.int(Math.round(defense * 0.5));
        final damageAfterDefense = baseDamage - mitigation;
        final finalDamage = damageAfterDefense > 1 ? damageAfterDefense : 1;
        
        // 4. Apply damage using ApplyDamageUseCase
        applyDamageUseCase.execute(targetId, finalDamage, attackerId, tick);
    }
}

