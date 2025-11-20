package engine.presentation;

import engine.infrastructure.adapters.events.IEventBus;
import engine.infrastructure.adapters.events.events.TickCompleteEvent;
import engine.infrastructure.state.GameModelState;
import engine.infrastructure.configuration.ServiceRegistry;
import engine.infrastructure.configuration.ServiceName;

/**
 * Fixed timestep game loop
 * Orchestrates services which in turn orchestrate use cases
 * 
 * Architecture: GameLoop → Services → Use Cases → Domain Layer
 * All business logic is handled by use cases via services.
 */
class GameLoop {
    private var state: GameModelState;
    private var services: ServiceRegistry;
    private var eventBus: IEventBus;
    private var running: Bool;
    private var tickRate: Int;
    
    public function new(state: GameModelState, services: ServiceRegistry, eventBus: IEventBus, tickRate: Int) {
        this.state = state;
        this.services = services;
        this.eventBus = eventBus;
        this.running = false;
        this.tickRate = tickRate;
    }
    
    /**
     * Start the game loop
     */
    public function start(): Void {
        running = true;
    }
    
    /**
     * Stop the game loop
     */
    public function stop(): Void {
        running = false;
    }
    
    /**
     * Execute single fixed timestep
     * All business logic is handled by use cases via services
     */
    public function stepFixed(): Void {
        if (!running) return;
        
        // Increment tick
        state.tick++;
        final currentTick = state.tick;
        
        // Execute services in deterministic order
        // Services are pure orchestrators that delegate to use cases
        final dt = 1.0 / tickRate;
        executeServices(currentTick, dt);
        
        // Emit tick complete event
        eventBus.emit(TickCompleteEvent.NAME, {tick: currentTick});
    }
    
    /**
     * Execute all services in deterministic order
     * Services orchestrate use cases - no business logic here
     * @param tick Current tick
     * @param dt Delta time
     */
    private function executeServices(tick: Int, dt: Float): Void {
        // 1. Input service - orchestrates ProcessInputUseCase
        final inputService = services.get(ServiceName.INPUT);
        if (inputService != null) {
            inputService.update(state, tick, dt);
        }
        
        // 2. AI service - orchestrates UpdateAIBehaviorUseCase
        final aiService = services.get(ServiceName.AI);
        if (aiService != null) {
            aiService.update(state, tick, dt);
        }
        
        // 3. Physics service - orchestrates IntegratePhysicsUseCase and ResolveCollisionUseCase
        final physicsService = services.get(ServiceName.PHYSICS);
        if (physicsService != null) {
            physicsService.update(state, tick, dt);
        }
        
        // 4. Entity lifecycle service - orchestrates CleanupDeadEntitiesUseCase
        final entityLifecycleService = services.get(ServiceName.ENTITY_LIFECYCLE);
        if (entityLifecycleService != null) {
            entityLifecycleService.update(state, tick, dt);
        }
    }
}

