package engine.application.services;

import engine.infrastructure.state.GameModelState;
import engine.application.usecases.physics.IntegratePhysicsUseCase;
import engine.application.usecases.physics.ResolveCollisionUseCase;

/**
 * Physics service for movement and collision
 * Pure orchestrator - delegates all logic to physics use cases
 * 
 * This service orchestrates the physics pipeline:
 * 1. IntegratePhysicsUseCase - integrates velocities into positions
 * 2. ResolveCollisionUseCase - detects and resolves collisions
 * 
 * All physics logic is in the use cases and domain layer (PhysicsService, CollisionService).
 */
class PhysicsService implements IService {
    private final integratePhysicsUseCase: IntegratePhysicsUseCase;
    private final resolveCollisionUseCase: ResolveCollisionUseCase;
    
    public function new(
        integratePhysicsUseCase: IntegratePhysicsUseCase,
        resolveCollisionUseCase: ResolveCollisionUseCase
    ) {
        this.integratePhysicsUseCase = integratePhysicsUseCase;
        this.resolveCollisionUseCase = resolveCollisionUseCase;
    }
    
    /**
     * Update physics for this tick
     * Pure orchestration - delegates to use cases
     */
    public function update(state: GameModelState, tick: Int, dt: Float): Void {
        // Step 1: Integrate physics via use case
        integratePhysicsUseCase.execute(dt, tick);
        
        // Step 2: Resolve collisions via use case
        resolveCollisionUseCase.execute(tick);
    }
    
    /**
     * Shutdown service
     */
    public function shutdown(): Void {
        // No resources to clean up
    }
}

