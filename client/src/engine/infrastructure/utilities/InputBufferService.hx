package engine.infrastructure.utilities;

import engine.presentation.InputBuffer;
import engine.presentation.InputMessage;

/**
 * Infrastructure service for input buffering
 * Technical concern: buffering and queuing inputs
 */
class InputBufferService {
    private final inputBuffers: Map<String, InputBuffer>;
    
    public function new() {
        this.inputBuffers = new Map();
    }
    
    /**
     * Queue input from client
     * @param input Input message
     */
    public function queueInput(input: InputMessage): Void {
        if (!inputBuffers.exists(input.clientId)) {
            inputBuffers.set(input.clientId, new InputBuffer());
        }
        
        inputBuffers.get(input.clientId).push(input);
    }
    
    /**
     * Collect inputs for specific tick
     * @param tick Target tick
     * @return Array of inputs for this tick
     */
    public function collectForTick(tick: Int): Array<InputMessage> {
        var result = [];
        
        for (clientId in inputBuffers.keys()) {
            final buffer = inputBuffers.get(clientId);
            final inputs = buffer.collectForTick(tick);
            result = result.concat(inputs);
        }
        
        return result;
    }
    
    /**
     * Drop acknowledged inputs
     * @param clientId Client ID
     * @param sequence Last acknowledged sequence
     */
    public function dropAcknowledged(clientId: String, sequence: Int): Void {
        if (inputBuffers.exists(clientId)) {
            inputBuffers.get(clientId).dropUpToSequence(sequence);
        }
    }
    
    /**
     * Clear all buffers
     */
    public function clear(): Void {
        inputBuffers.clear();
    }
}

