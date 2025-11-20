package engine.application.services;

import engine.infrastructure.state.GameModelState;
import engine.application.usecases.input.ProcessInputUseCase;
import engine.infrastructure.utilities.ClientEntityMappingService;
import engine.infrastructure.utilities.InputBufferService;
import engine.presentation.InputMessage;

/**
 * Input service for handling player inputs
 * Pure orchestrator - delegates all logic to ProcessInputUseCase
 * 
 * This service handles only infrastructure concerns (input buffering, client-entity mapping).
 * All input processing logic is in ProcessInputUseCase.
 */
class InputService implements IService {
    private final processInputUseCase: ProcessInputUseCase;
    private final inputBufferService: InputBufferService;
    private final clientEntityMappingService: ClientEntityMappingService;
    
    public function new(
        processInputUseCase: ProcessInputUseCase,
        inputBufferService: InputBufferService,
        clientEntityMappingService: ClientEntityMappingService
    ) {
        this.processInputUseCase = processInputUseCase;
        this.inputBufferService = inputBufferService;
        this.clientEntityMappingService = clientEntityMappingService;
    }
    
    /**
     * Update input processing for this tick
     * Pure orchestration - delegates to use case
     */
    public function update(state: GameModelState, tick: Int, dt: Float): Void {
        // Collect inputs for this tick (infrastructure concern)
        final inputs = inputBufferService.collectForTick(tick);
        
        // Process each input via use case - all business logic is in ProcessInputUseCase
        for (input in inputs) {
            final entityId = clientEntityMappingService.getEntityId(input.clientId);
            if (entityId != null) {
                processInputUseCase.handleInput({
                    clientId: input.clientId,
                    entityId: entityId,
                    movement: input.movement,
                    actions: input.actions,
                    tick: tick,
                    deltaTime: dt
                });
            }
        }
    }
    
    /**
     * Shutdown service
     */
    public function shutdown(): Void {
        inputBufferService.clear();
    }
    
    /**
     * Queue input from client
     * Infrastructure method - delegates to buffer service
     * @param input Input message
     */
    public function queueInput(input: InputMessage): Void {
        inputBufferService.queueInput(input);
    }
    
    /**
     * Set client to entity mapping
     * Infrastructure method - delegates to mapping service
     * @param clientId Client ID
     * @param entityId Entity ID
     */
    public function setClientEntity(clientId: String, entityId: Int): Void {
        clientEntityMappingService.setMapping(clientId, entityId);
    }
    
    /**
     * Drop acknowledged inputs
     * Infrastructure method - delegates to buffer service
     * @param clientId Client ID
     * @param sequence Last acknowledged sequence
     */
    public function dropAcknowledged(clientId: String, sequence: Int): Void {
        inputBufferService.dropAcknowledged(clientId, sequence);
    }
}

