package engine.domain.entities;

import engine.domain.geometry.Rect;
import engine.domain.geometry.Vec2;
import engine.domain.types.EntityType;
import engine.domain.valueobjects.Position;
import engine.domain.valueobjects.Velocity;
import engine.domain.specs.EntitySpec;
import engine.domain.specs.EntitySpec.BaseEntitySpec;

/**
 * Abstract base entity with common fields and default implementations.
 * This is the single source of truth for all entities in the engine.
 */
abstract class BaseEntity {
    /** Base entity data */
    public var base: BaseEntitySpec;
    
    /** Collider rectangle instance (kept and updated automatically) */
    public var colliderRect: Rect;
    
    // Property accessors for backward compatibility
    public var id(get, set): Int;
    public var type(get, set): EntityType;
    public var pos(get, set): Vec2;
    public var vel(get, set): Vec2;
    public var rotation(get, set): Float;
    public var ownerId(get, set): String;
    public var isAlive(get, set): Bool;
    public var isInputDriven(get, set): Bool;
    public var colliderWidth(get, set): Float;
    public var colliderHeight(get, set): Float;

    // Domain contract surface
    public var position(get, set): Position;
    public var velocity(get, set): Velocity;
    public var entityType(get, set): String;
    public var colliderOffset(get, set): Position;

    private var domainEvents: Array<Dynamic>;
    
    // Unit pixels configuration (injected to remove SeidhEngine dependency)
    public static var unitPixels: Int = 64; // Default value
    
    public static function setUnitPixels(pixels: Int): Void {
        unitPixels = pixels;
    }
    
    private function get_id(): Int return base.id;
    private function set_id(v: Int): Int return base.id = v;
    private function get_type(): EntityType return base.type;
    private function set_type(v: EntityType): EntityType return base.type = v;
    private function get_pos(): Vec2 return base.pos;
    private function set_pos(v: Vec2): Vec2 {
        base.pos = v;
        updateColliderRect();
        return v;
    }
    private function get_vel(): Vec2 return base.vel;
    private function set_vel(v: Vec2): Vec2 return base.vel = v;
    private function get_rotation(): Float return base.rotation;
    private function set_rotation(v: Float): Float return base.rotation = v;
    private function get_ownerId(): String return base.ownerId;
    private function set_ownerId(v: String): String return base.ownerId = v;
    private function get_isAlive(): Bool return base.isAlive;
    private function set_isAlive(v: Bool): Bool return base.isAlive = v;
    private function get_isInputDriven(): Bool return base.isInputDriven;
    private function set_isInputDriven(v: Bool): Bool return base.isInputDriven = v;
    private function get_colliderWidth(): Float return base.colliderWidth;
    private function set_colliderWidth(v: Float): Float {
        base.colliderWidth = v;
        updateColliderRect();
        return v;
    }
    private function get_colliderHeight(): Float return base.colliderHeight;
    private function set_colliderHeight(v: Float): Float {
        base.colliderHeight = v;
        updateColliderRect();
        return v;
    }
    private function get_position(): Position {
        return new Position(base.pos.x, base.pos.y);
    }
    private function set_position(value: Position): Position {
        base.pos = new Vec2(Std.int(value.x), Std.int(value.y));
        updateColliderRect();
        return value;
    }
    private function get_velocity(): Velocity {
        return new Velocity(base.vel.x, base.vel.y);
    }
    private function set_velocity(value: Velocity): Velocity {
        base.vel = new Vec2(Std.int(value.x), Std.int(value.y));
        return value;
    }
    private function get_entityType(): String {
        return base.type;
    }
    private function set_entityType(value: String): String {
        base.type = value != null ? cast value : EntityType.GENERIC;
        return value;
    }
    private function get_colliderOffset(): Position {
        if (colliderRect == null || colliderRect.offset == null) {
            return new Position(0, 0);
        }
        return new Position(colliderRect.offset.x, colliderRect.offset.y);
    }
    private function set_colliderOffset(value: Position): Position {
        if (colliderRect != null) {
            colliderRect.offset = new Vec2(Std.int(value.x), Std.int(value.y));
            updateColliderRect();
        }
        return value;
    }
    
    /** Movement correction */
    public var movementCorrection: Vec2 = new Vec2(0, 0);

    public function new() {
        base = createDefaultBaseData();
        colliderRect = new Rect();
        domainEvents = [];
        reset(null);
    }
    
    /**
     * Create default base entity data
     */
    private function createDefaultBaseData(): BaseEntitySpec {
        return {
            id: 0,
            type: EntityType.GENERIC,
            pos: new Vec2(0, 0),
            vel: new Vec2(0, 0),
            rotation: 0,
            ownerId: "",
            isAlive: false,
            isInputDriven: false,
            colliderWidth: 1,
            colliderHeight: 1,
            colliderOffset: null // No longer stored in base, stored in rect
        };
    }
    
    /**
     * Convert spec to base data with defaults applied
     */
    private function specToBaseData(spec: BaseEntitySpec): BaseEntitySpec {
        return {
            id: spec.id != null ? spec.id : 0,
            type: spec.type != null ? spec.type : EntityType.GENERIC,
            pos: spec.pos != null ? spec.pos : new Vec2(0, 0),
            vel: spec.vel != null ? spec.vel : new Vec2(0, 0),
            rotation: spec.rotation != null ? spec.rotation : 0,
            ownerId: spec.ownerId != null ? spec.ownerId : "",
            isAlive: spec.isAlive != null ? spec.isAlive : true,
            isInputDriven: spec.isInputDriven != null ? spec.isInputDriven : false,
            colliderWidth: spec.colliderWidth != null ? spec.colliderWidth : 1,
            colliderHeight: spec.colliderHeight != null ? spec.colliderHeight : 1,
            colliderOffset: null // No longer stored in base, stored in rect
        };
    }
    
    /**
     * Update collider rectangle position and size based on entity position, collider dimensions, and offset
     * Call this after directly modifying pos.x or pos.y to ensure colliderRect stays in sync
     */
    public function updateColliderRect(): Void {
        if (colliderRect == null) {
            colliderRect = new Rect();
        }
        
        final offset = colliderRect.offset;
        
        // Calculate collider center position in pixels
        final colliderCenterX = pos.x + offset.x;
        final colliderCenterY = pos.y + offset.y;
        
        // Calculate collider dimensions in pixels
        final colliderWidthPx = colliderWidth * unitPixels;
        final colliderHeightPx = colliderHeight * unitPixels;
        
        // Update the rect instance (no new instance creation)
        colliderRect.setPosition(colliderCenterX, colliderCenterY);
        colliderRect.setSize(colliderWidthPx, colliderHeightPx);
    }
    
    /**
     * Domain event helpers
     */
    public function getDomainEvents(): Array<Dynamic> {
        final events = domainEvents.copy();
        domainEvents = [];
        return events;
    }

    function addDomainEvent(event: Dynamic): Void {
        domainEvents.push(event);
    }

    /**
     * Serialization for snapshots
     */
    public function serialize(): Dynamic {
        final offset = colliderRect != null ? colliderRect.offset : new Vec2(0, 0);
        return {
            id: base.id,
            type: base.type,
            pos: {x: base.pos.x, y: base.pos.y},
            vel: {x: base.vel.x, y: base.vel.y},
            rotation: base.rotation,
            ownerId: base.ownerId,
            isAlive: base.isAlive,
            isInputDriven: base.isInputDriven,
            colliderWidth: base.colliderWidth,
            colliderHeight: base.colliderHeight,
            colliderOffset: {x: offset.x, y: offset.y}
        };
    }
    
    public function deserialize(data: Dynamic): Void {
        base = {
            id: data.id,
            type: data.type,
            pos: data.pos != null ? new Vec2(data.pos.x, data.pos.y) : new Vec2(0, 0),
            vel: data.vel != null ? new Vec2(data.vel.x, data.vel.y) : new Vec2(0, 0),
            rotation: data.rotation,
            ownerId: data.ownerId,
            isAlive: data.isAlive,
            isInputDriven: data.isInputDriven != null ? data.isInputDriven : false,
            colliderWidth: data.colliderWidth != null ? data.colliderWidth : 1,
            colliderHeight: data.colliderHeight != null ? data.colliderHeight : 1,
            colliderOffset: null // No longer stored in base, stored in rect
        };
        
        // Set offset on colliderRect from deserialized data
        if (colliderRect != null) {
            if (data.colliderOffset != null) {
                colliderRect.offset = new Vec2(data.colliderOffset.x, data.colliderOffset.y);
            } else if (data.colliderPxOffsetX != null || data.colliderPxOffsetY != null) {
                colliderRect.offset = new Vec2(
                    data.colliderPxOffsetX != null ? Std.int(data.colliderPxOffsetX) : 0, 
                    data.colliderPxOffsetY != null ? Std.int(data.colliderPxOffsetY) : 0
                );
            } else {
                colliderRect.offset = new Vec2(0, 0);
            }
        }
        updateColliderRect();
    }
    
    public function reset(spec: EntitySpec): Void {
        if (spec == null) {
            base = createDefaultBaseData();
            if (colliderRect != null) {
                colliderRect.offset = new Vec2(0, 0);
            }
            updateColliderRect();
            return;
        }

        base = specToBaseData(spec);
        // Set offset on colliderRect from spec
        if (colliderRect != null && spec.colliderOffset != null) {
            colliderRect.offset = spec.colliderOffset;
        } else if (colliderRect != null) {
            colliderRect.offset = new Vec2(0, 0);
        }
        updateColliderRect();
    }

    /**
     * Apply movement correction
     */
    public function applyMovementCorrection(correction: Vec2): Void {
        movementCorrection = correction;
    }

    /**
     * Reset movement correction
     */
    public function clearMovementCorrection(): Void {
        movementCorrection = new Vec2(0, 0);
    }
}

