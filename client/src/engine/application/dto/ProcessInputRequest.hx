package engine.application.dto;

/**
 * Request for processing input
 */
typedef ProcessInputRequest = {
    var clientId: String;
    var entityId: Int;
    var movement: {x: Float, y: Float};
    var actions: Array<Dynamic>;
    var tick: Int;
    var deltaTime: Float;
}

