package engine.application.dto;

/**
 * DTO for spawning a collider entity
 */
typedef SpawnColliderRequest = {
    var x: Float;
    var y: Float;
    var width: Float;
    var height: Float;
    var ownerId: String;
    var passable: Bool;
    var isTrigger: Bool;
}
