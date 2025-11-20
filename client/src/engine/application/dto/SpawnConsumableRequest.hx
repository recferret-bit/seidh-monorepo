package engine.application.dto;

/**
 * DTO for spawning a consumable entity
 */
typedef SpawnConsumableRequest = {
    var entityType: String;
    var x: Float;
    var y: Float;
    var ownerId: String;
    var effectId: String;
    var durationTicks: Int;
    var stackable: Bool;
    var charges: Int;
    var useRange: Float;
}

