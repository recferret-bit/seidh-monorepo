package engine.application.dto;

import engine.domain.entities.character.base.CharacterStats;

/**
 * Request for spawning a character
 */
typedef SpawnCharacterRequest = {
    var entityType: String;
    var x: Float;
    var y: Float;
    var ownerId: String;
    var maxHp: Int;
    var level: Int;
    var stats: CharacterStats;
}
