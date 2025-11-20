package engine.domain.entities.character.factory;

import engine.domain.entities.character.base.BaseCharacterEntity;
import engine.domain.entities.character.impl.RagnarEntity;
import engine.domain.entities.character.impl.ZombieBoyEntity;
import engine.domain.entities.character.impl.ZombieGirlEntity;
import engine.domain.entities.character.impl.GlamrEntity;
import engine.domain.specs.CharacterSpec;
import engine.domain.types.EntityType;

/**
 * Default implementation of the character entity factory
 * Uses CharacterSpec for type-safe character creation
 */
class DefaultCharacterEntityFactory implements CharacterEntityFactory {
    public function new() {}

    /**
     * Create character entity from specification
     * @param spec Character specification
     * @return Created character entity
     */
    public function create(spec: CharacterSpec): BaseCharacterEntity {
        final entity = instantiate(spec.type);
        entity.reset(spec);
        return entity;
    }

    private function instantiate(entityType: EntityType): BaseCharacterEntity {
        return switch (entityType) {
            case EntityType.RAGNAR: new RagnarEntity();
            case EntityType.ZOMBIE_BOY: new ZombieBoyEntity();
            case EntityType.ZOMBIE_GIRL: new ZombieGirlEntity();
            case EntityType.GLAMR: new GlamrEntity();
            default: new BaseCharacterEntity();
        };
    }

}
