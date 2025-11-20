package engine.application.ports.input;

import engine.application.dto.ProcessInputRequest;

/**
 * Port for handling input
 */
interface IInputHandler {
    /**
     * Handle input request
     * @param request Input request
     */
    function handleInput(request: ProcessInputRequest): Void;
}

