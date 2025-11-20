package engine.infrastructure.services;

import engine.infrastructure.state.GameModelState;

/**
 * Service for generating entity IDs
 */
class IdGeneratorService {
    private final state: GameModelState;
    
    public function new(state: GameModelState) {
        this.state = state;
    }
    
    /**
     * Generate next entity ID using deterministic game state
     * @return New entity ID
     */
    public function generate(): Int {
        return state.allocateEntityId();
    }
    
    /**
     * Reset ID generator (useful for testing)
     * @param startId Starting ID
     */
    public function reset(startId: Int = 1): Void {
        state.nextEntityId = startId;
    }
}

