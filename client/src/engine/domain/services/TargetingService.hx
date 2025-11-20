package engine.domain.services;

import engine.domain.entities.character.base.BaseCharacterEntity;
import engine.domain.repositories.ICharacterRepository;

/**
 * Shared targeting helpers for combat interactions
 */
class TargetingService {
    private final characterRepository: ICharacterRepository;
    
    public function new(characterRepository: ICharacterRepository) {
        this.characterRepository = characterRepository;
    }
    
    /**
     * Find nearest enemy character to the attacker
     * @param attacker Source character
     * @param maxDistance Maximum allowed distance (defaults to 50 units)
     * @param options Extra targeting options
     */
    public function findNearestEnemy(
        attacker: BaseCharacterEntity,
        maxDistance: Float,
        ?options: TargetingOptions
    ): Null<BaseCharacterEntity> {
        if (attacker == null || !attacker.isAlive) {
            return null;
        }
        
        final allowNeutralTargets = options != null && options.allowNeutralTargets;
        final maxDistanceSq = maxDistance * maxDistance;
        
        var nearest: Null<BaseCharacterEntity> = null;
        var nearestDistance = Math.POSITIVE_INFINITY;
        
        final candidates = characterRepository.findAll();
        for (candidate in candidates) {
            if (candidate == null || !candidate.isAlive || candidate.id == attacker.id) {
                continue;
            }
            
            if (candidate.ownerId == attacker.ownerId) {
                continue;
            }
            
            if (!allowNeutralTargets && candidate.ownerId == "") {
                continue;
            }
            
            final distanceSq = attacker.position.distanceSquaredTo(candidate.position);
            if (distanceSq <= maxDistanceSq && distanceSq < nearestDistance) {
                nearest = candidate;
                nearestDistance = distanceSq;
            }
        }
        
        return nearest;
    }
}

typedef TargetingOptions = {
    ?allowNeutralTargets: Bool
}

