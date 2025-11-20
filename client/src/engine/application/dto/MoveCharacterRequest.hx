package engine.application.dto;

/**
 * Request for moving a character
 */
typedef MoveCharacterRequest = {
    var entityId: Int;
    var deltaX: Float;
    var deltaY: Float;
    var deltaTime: Float;
    var tick: Int;
}

