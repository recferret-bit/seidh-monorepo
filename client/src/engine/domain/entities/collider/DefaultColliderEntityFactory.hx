package engine.domain.entities.collider;

import engine.domain.geometry.Vec2;
import engine.domain.specs.EntitySpec;
import engine.domain.types.EntityType;
import engine.domain.valueobjects.Position;
import engine.domain.valueobjects.Velocity;

/**
 * Default implementation of the collider entity factory.
 */
class DefaultColliderEntityFactory implements ColliderEntityFactory {
    public function new() {}

    public function create(
        id: Int,
        position: Position,
        ownerId: String,
        width: Float,
        height: Float,
        passable: Bool = false,
        isTrigger: Bool = false
    ): ColliderEntity {
        final spec: EntitySpec = {
            id: id,
            type: EntityType.COLLIDER,
            pos: toVec(position),
            vel: new Vec2(0, 0),
            rotation: 0,
            ownerId: ownerId,
            isAlive: true,
            isInputDriven: false,
            colliderWidth: width,
            colliderHeight: height,
            passable: passable,
            isTrigger: isTrigger
        };

        final entity = new ColliderEntity();
        entity.reset(spec);
        entity.velocity = new Velocity(0, 0);
        return entity;
    }

    private inline function toVec(position: Position): Vec2 {
        if (position == null) {
            return new Vec2(0, 0);
        }
        return new Vec2(Std.int(position.x), Std.int(position.y));
    }
}
