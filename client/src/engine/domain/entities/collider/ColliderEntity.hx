package engine.domain.entities.collider;

import engine.domain.entities.BaseEntity;
import engine.domain.specs.EntitySpec;
import engine.domain.specs.ColliderSpec;
import engine.domain.valueobjects.Position;

/**
 * Collider entity for map building and collision detection
 * Static entities that can be passable or impassable, with optional trigger functionality
 */
class ColliderEntity extends BaseEntity {
    private var _passable: Bool;
    private var _isTrigger: Bool;
    public var passable(get, set): Bool;
    public var isTrigger(get, set): Bool;
    
    public function new() {
        super();
        passable = false;
        isTrigger = false;
    }
    
    public override function serialize(): Dynamic {
        final base = super.serialize();
        base.passable = passable;
        base.isTrigger = isTrigger;
        return base;
    }
    
    public override function deserialize(data: Dynamic): Void {
        super.deserialize(data);
        passable = data.passable != null ? data.passable : false;
        isTrigger = data.isTrigger != null ? data.isTrigger : false;
    }
    
    public override function reset(spec: EntitySpec): Void {
        super.reset(spec);

        if (spec == null) {
            passable = false;
            isTrigger = false;
            vel.x = 0;
            vel.y = 0;
            colliderWidth = 2;
            colliderHeight = 2;
            colliderOffset = new Position(0, 0);
            return;
        }

        // Cast to ColliderSpec for type-safe access to collider fields
        final colliderSpec: ColliderSpec = cast spec;
        
        passable = colliderSpec.passable != null ? colliderSpec.passable : false;
        isTrigger = colliderSpec.isTrigger != null ? colliderSpec.isTrigger : false;
        
        // Colliders are always static
        vel.x = 0;
        vel.y = 0;

        colliderWidth = spec.colliderWidth != null ? spec.colliderWidth : 1;
        colliderHeight = spec.colliderHeight != null ? spec.colliderHeight : 1;
    }

    public function containsPoint(point: Position): Bool {
        final halfWidth = colliderWidth / 2.0;
        final halfHeight = colliderHeight / 2.0;
        final centerX = position.x + colliderOffset.x;
        final centerY = position.y + colliderOffset.y;
        
        return point.x >= centerX - halfWidth &&
               point.x <= centerX + halfWidth &&
               point.y >= centerY - halfHeight &&
               point.y <= centerY + halfHeight;
    }

    public function intersects(other: ColliderEntity): Bool {
        final thisHalfWidth = colliderWidth / 2.0;
        final thisHalfHeight = colliderHeight / 2.0;
        final thisCenterX = position.x + colliderOffset.x;
        final thisCenterY = position.y + colliderOffset.y;
        
        final otherHalfWidth = other.colliderWidth / 2.0;
        final otherHalfHeight = other.colliderHeight / 2.0;
        final otherCenterX = other.position.x + other.colliderOffset.x;
        final otherCenterY = other.position.y + other.colliderOffset.y;
        
        return thisCenterX - thisHalfWidth < otherCenterX + otherHalfWidth &&
               thisCenterX + thisHalfWidth > otherCenterX - otherHalfWidth &&
               thisCenterY - thisHalfHeight < otherCenterY + otherHalfHeight &&
               thisCenterY + thisHalfHeight > otherCenterY - otherHalfHeight;
    }

    private function get_passable(): Bool {
        return _passable;
    }

    private function set_passable(value: Bool): Bool {
        _passable = value;
        return _passable;
    }

    private function get_isTrigger(): Bool {
        return _isTrigger;
    }

    private function set_isTrigger(value: Bool): Bool {
        _isTrigger = value;
        return _isTrigger;
    }
}

