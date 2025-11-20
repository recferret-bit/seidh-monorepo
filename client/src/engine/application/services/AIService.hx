package engine.application.services;

import engine.infrastructure.state.GameModelState;
import engine.application.usecases.ai.UpdateAIBehaviorUseCase;

/**
 * AI service for entity behavior
 * Pure orchestrator - delegates all logic to UpdateAIBehaviorUseCase
 * 
 * This service handles only infrastructure concerns (tick scheduling).
 * All AI decision logic is in the domain layer (AIDecisionService).
 */
class AIService implements IService {
    private final updateAIBehaviorUseCase: UpdateAIBehaviorUseCase;
    
    public function new(updateAIBehaviorUseCase: UpdateAIBehaviorUseCase) {
        this.updateAIBehaviorUseCase = updateAIBehaviorUseCase;
    }
    
    /**
     * Update AI for this tick
     * Pure orchestration - delegates to use case
     */
    public function update(state: GameModelState, tick: Int, dt: Float): Void {
        final config = state.config;
        final interval = config != null ? config.aiUpdateInterval : SeidhEngine.Default_Config.aiUpdateInterval;

        // Only update AI every N ticks (configuration concern, not business logic)
        if (interval > 0 && tick % interval != 0) {
            return;
        }
        
        // Delegate to use case - all business logic is in UpdateAIBehaviorUseCase
        updateAIBehaviorUseCase.updateAll(dt, tick);
    }
    
    /**
     * Shutdown service
     */
    public function shutdown(): Void {
        // No resources to clean up
    }
}

