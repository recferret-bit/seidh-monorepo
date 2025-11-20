package engine.application.services;

import engine.infrastructure.state.GameModelState;
import engine.application.usecases.character.CleanupDeadEntitiesUseCase;

/**
 * Entity lifecycle service
 * Pure orchestrator - delegates all logic to CleanupDeadEntitiesUseCase
 * 
 * This service handles entity lifecycle orchestration (currently cleanup only).
 * All entity lifecycle logic is in use cases.
 */
class EntityLifecycleService implements IService {
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

