package engine.domain.entities.character.factory;

import engine.domain.entities.character.base.BaseCharacterEntity;
import engine.domain.entities.character.impl.RagnarEntity;
import engine.domain.entities.character.impl.ZombieBoyEntity;
import engine.domain.entities.character.impl.ZombieGirlEntity;
import engine.domain.entities.character.impl.GlamrEntity;
import engine.domain.entities.character.base.CharacterStats;
import engine.domain.geometry.Vec2;
import engine.domain.specs.EntitySpec;
import engine.domain.types.EntityType;
import engine.domain.valueobjects.Health;
import engine.domain.valueobjects.Position;
import engine.domain.valueobjects.Velocity;

/**
 * Default implementation of the character entity factory.
 */
class DefaultCharacterEntityFactory implements CharacterEntityFactory {
    public function new() {}

    public function create(
        entityType: String,
        id: Int,
        position: Position,
        health: Health,
        ownerId: String,
        level: Int = 1,
        stats: CharacterStats = null,
        isInputDriven: Bool = true
    ): BaseCharacterEntity {
        final resolvedType = resolveType(entityType);
        final spec = buildSpec(resolvedType, id, position, health, ownerId, level, stats, isInputDriven);
        final entity = instantiate(resolvedType);
        entity.reset(spec);
        entity.velocity = new Velocity(0, 0);
        return entity;
    }

    private function buildSpec(
        entityType: EntityType,
        id: Int,
        position: Position,
        health: Health,
        ownerId: String,
        level: Int,
        stats: CharacterStats,
        isInputDriven: Bool
    ): EntitySpec {
        final statsSpec = stats != null ? {
            power: Std.int(stats.power),
            armor: Std.int(stats.defense),
            speed: Std.int(stats.speed),
            castSpeed: Std.int(stats.castSpeed)
        } : null;

        return {
            id: id,
            type: entityType,
            pos: toVec(position),
            vel: new Vec2(0, 0),
            rotation: 0,
            ownerId: ownerId,
            isAlive: true,
            isInputDriven: isInputDriven,
            maxHp: health != null ? health.maximum : 100,
            hp: health != null ? health.current : 100,
            level: level,
            stats: statsSpec
        };
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

    private inline function resolveType(entityType: String): EntityType {
        return entityType != null ? cast entityType : EntityType.GENERIC;
    }

    private inline function toVec(position: Position): Vec2 {
        if (position == null) {
            return new Vec2(0, 0);
        }
        return new Vec2(Std.int(position.x), Std.int(position.y));
    }
}
