package engine.application.services;

import engine.infrastructure.state.GameModelState;

/**
 * Service contract for engine services
 * 
 * Services are pure orchestrators that delegate all business logic to use cases.
 * They should contain NO business logic - only orchestration and infrastructure concerns.
 * 
 * Architecture Flow:
 *   GameLoop (presentation) → Services (orchestration) → Use Cases (application) → Domain (business logic)
 * 
 * Responsibilities of Services:
 *   - Orchestrate use cases (call them in the right order)
 *   - Handle infrastructure concerns (input buffering, tick scheduling, service coordination)
 *   - Do NOT contain business rules or domain logic
 */
interface IService {
    /**
     * Update service for this tick
     * @param state Game state
     * @param tick Current tick
     * @param dt Delta time
     */
    function update(state: GameModelState, tick: Int, dt: Float): Void;
    
    /**
     * Shutdown service
     */
    function shutdown(): Void;
}

