package engine.domain.entities.consumable.factory;

import engine.domain.entities.consumable.base.BaseConsumableEntity;
import engine.domain.geometry.Vec2;
import engine.domain.specs.EntitySpec;
import engine.domain.types.EntityType;
import engine.domain.valueobjects.Position;
import engine.domain.valueobjects.Velocity;

/**
 * Default implementation of the consumable entity factory.
 */
class DefaultConsumableEntityFactory implements ConsumableEntityFactory {
    public function new() {}

    public function create(
        entityType: String,
        id: Int,
        position: Position,
        ownerId: String,
        effectId: String,
        durationTicks: Int = 0,
        stackable: Bool = false,
        charges: Int = 1,
        useRange: Float = 16.0
    ): BaseConsumableEntity {
        final resolvedType = resolveType(entityType);
        
        final spec: EntitySpec = {
            id: id,
            type: resolvedType,
            pos: toVec(position),
            vel: new Vec2(0, 0),
            rotation: 0,
            ownerId: ownerId,
            isAlive: true,
            isInputDriven: false,
            effectId: effectId,
            durationTicks: durationTicks,
            stackable: stackable,
            charges: charges,
            useRange: useRange
        };

        final entity = new BaseConsumableEntity();
        entity.reset(spec);
        entity.velocity = new Velocity(0, 0);
        return entity;
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
