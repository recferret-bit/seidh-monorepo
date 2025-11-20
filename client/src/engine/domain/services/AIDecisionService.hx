package engine.domain.services;

import engine.domain.entities.character.base.BaseCharacterEntity;
import engine.domain.services.DeterministicRng;
import engine.domain.services.TargetingService;

/**
 * Domain service for AI decision logic
 * Contains AI behavior rules
 */
class AIDecisionService {
    private final targetingService: TargetingService;
    
    public function new(targetingService: TargetingService) {
        this.targetingService = targetingService;
    }
    
    /**
     * Make AI decision for entity
     * @param entity Character entity
     * @param rng Random number generator
     * @return AI decision
     */
    public function makeDecision(
        entity: BaseCharacterEntity,
        rng: DeterministicRng
    ): AIDecision {
        // First, check if there's an enemy nearby to attack
        final nearestEnemy = targetingService.findNearestEnemy(entity, 50.0);
        if (nearestEnemy != null) {
            return {
                action: "attack",
                targetId: nearestEnemy.id,
                movementX: 0.0,
                movementY: 0.0
            };
        }
        
        // Simple wander behavior - can be extended with more sophisticated AI
        if (rng.nextFloat() < 0.1) { // 10% chance to change direction
            final angle = rng.nextFloatRange(0, Math.PI * 2);
            final movementX = Math.cos(angle);
            final movementY = Math.sin(angle);
            
            return {
                action: "move",
                targetId: null,
                movementX: movementX,
                movementY: movementY
            };
        }
        
        // Default: idle
        return {
            action: "idle",
            targetId: null,
            movementX: 0.0,
            movementY: 0.0
        };
    }
}

typedef AIDecision = {
    var action: String;
    var targetId: Null<Int>;
    var movementX: Float;
    var movementY: Float;
}

