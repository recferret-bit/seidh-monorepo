package engine.application.services;

import engine.infrastructure.state.GameModelState;
import engine.application.usecases.character.CleanupDeadEntitiesUseCase;

/**
 * Spawn service for entity lifecycle
 * Pure orchestrator - delegates all logic to CleanupDeadEntitiesUseCase
 * 
 * This service handles entity cleanup orchestration.
 * All entity lifecycle logic is in CleanupDeadEntitiesUseCase.
 */
class SpawnService implements IService {
    private final cleanupDeadEntitiesUseCase: CleanupDeadEntitiesUseCase;
    
    public function new(cleanupDeadEntitiesUseCase: CleanupDeadEntitiesUseCase) {
        this.cleanupDeadEntitiesUseCase = cleanupDeadEntitiesUseCase;
    }
    
    /**
     * Update entity lifecycle for this tick
     * Pure orchestration - delegates to use case
     */
    public function update(state: GameModelState, tick: Int, dt: Float): Void {
        cleanupDeadEntitiesUseCase.execute(tick);
    }
    
    /**
     * Shutdown service
     */
    public function shutdown(): Void {
        // No resources to clean up
    }
}

