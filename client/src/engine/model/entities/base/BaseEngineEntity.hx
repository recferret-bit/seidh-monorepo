package engine.model.entities.base;

import engine.geometry.Vec2;
import engine.geometry.Rect;
import engine.model.entities.types.EntityType;
import engine.model.entities.specs.EngineEntitySpec;
import engine.model.entities.specs.BaseEntitySpec;
import engine.SeidhEngine;

/**
 * Abstract base entity with common fields and default implementations
 */
abstract class BaseEngineEntity {
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
    public var colliderOffset(get, set): Vec2;
    
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
    private function get_colliderOffset(): Vec2 {
        return colliderRect != null ? colliderRect.offset : new Vec2(0, 0);
    }
    private function set_colliderOffset(v: Vec2): Vec2 {
        if (colliderRect != null) {
            colliderRect.offset = v;
            updateColliderRect();
        }
        return v;
    }
    
    /** Movement correction */
    public var movementCorrection: Vec2 = new Vec2(0, 0);

    public function new() {
        base = createDefaultBaseData();
        colliderRect = new Rect();
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
        
        final unitPixels = SeidhEngine.Config.unitPixels;
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
     * Abstract interface implementation
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
    
    public function reset(spec: EngineEntitySpec): Void {
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
