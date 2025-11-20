package engine.domain.entities.character.factory;

import engine.domain.entities.character.base.BaseCharacterEntity;
import engine.domain.specs.CharacterSpec;

/**
 * Contract for creating character entities
 * Uses CharacterSpec for type-safe character creation
 */
interface CharacterEntityFactory {
    /**
     * Create character entity from specification
     * @param spec Character specification with all required fields
     * @return Created character entity
     */
    function create(spec: CharacterSpec): BaseCharacterEntity;
}

