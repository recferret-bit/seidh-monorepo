package engine.domain.entities.character.factory;

import engine.domain.entities.character.base.BaseCharacterEntity;
import engine.domain.entities.character.base.CharacterStats;
import engine.domain.valueobjects.Position;
import engine.domain.valueobjects.Health;

/**
 * Contract for creating character entities by type.
 */
interface CharacterEntityFactory {
    function create(
        entityType: String,
        id: Int,
        position: Position,
        health: Health,
        ownerId: String,
        level: Int = 1,
        stats: CharacterStats = null,
        isInputDriven: Bool = true
    ): BaseCharacterEntity;
}

