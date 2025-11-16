package engine.model.entities.base;

import engine.geometry.Vec2;
import engine.geometry.Vec2Utils;
import engine.model.entities.types.EntityType;
import engine.model.entities.abs.AbstractEngineEntity;
import engine.model.entities.types.EngineEntitySpec;
import engine.model.entities.types.BaseEntityData;
import engine.model.entities.types.BaseEntitySpec;

/**
 * Abstract base entity with common fields and default implementations
 */
abstract class BaseEngineEntity extends AbstractEngineEntity {
    
    /** Movement correction */
    public var movementCorrection: Vec2 = Vec2Utils.create(0, 0);

    public function new() {
        base = createDefaultBaseData();
        reset(null);
    }
    
    /**
     * Create default base entity data
     */
    private function createDefaultBaseData(): BaseEntityData {
        return {
            id: 0,
            type: EntityType.GENERIC,
            pos: Vec2Utils.create(0, 0),
            vel: Vec2Utils.create(0, 0),
            rotation: 0,
            ownerId: "",
            isAlive: false,
            isInputDriven: false,
            colliderWidth: 1,
            colliderHeight: 1,
            colliderPxOffsetX: 0,
            colliderPxOffsetY: 0
        };
    }
    
    /**
     * Convert spec to base data
     */
    private function specToBaseData(spec: BaseEntitySpec): BaseEntityData {
        return {
            id: spec.id != null ? spec.id : 0,
            type: spec.type != null ? spec.type : EntityType.GENERIC,
            pos: spec.pos != null ? Vec2Utils.create(spec.pos.x, spec.pos.y) : Vec2Utils.create(0, 0),
            vel: spec.vel != null ? Vec2Utils.create(spec.vel.x, spec.vel.y) : Vec2Utils.create(0, 0),
            rotation: spec.rotation != null ? spec.rotation : 0,
            ownerId: spec.ownerId != null ? spec.ownerId : "",
            isAlive: spec.isAlive != null ? spec.isAlive : true,
            isInputDriven: spec.isInputDriven != null ? spec.isInputDriven : false,
            colliderWidth: spec.colliderWidth != null ? spec.colliderWidth : 1,
            colliderHeight: spec.colliderHeight != null ? spec.colliderHeight : 1,
            colliderPxOffsetX: spec.colliderPxOffsetX != null ? spec.colliderPxOffsetX : 0,
            colliderPxOffsetY: spec.colliderPxOffsetY != null ? spec.colliderPxOffsetY : 0
        };
    }
    
    /**
     * Abstract interface implementation
     */

    public function serialize(): Dynamic {
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
            colliderHeight: base.colliderHeight
        };
    }
    
    public function deserialize(data: Dynamic): Void {
        base = {
            id: data.id,
            type: data.type,
            pos: Vec2Utils.create(data.pos.x, data.pos.y),
            vel: Vec2Utils.create(data.vel.x, data.vel.y),
            rotation: data.rotation,
            ownerId: data.ownerId,
            isAlive: data.isAlive,
            isInputDriven: data.isInputDriven != null ? data.isInputDriven : false,
            colliderWidth: data.colliderWidth != null ? data.colliderWidth : 1,
            colliderHeight: data.colliderHeight != null ? data.colliderHeight : 1,
            colliderPxOffsetX: data.colliderPxOffsetX != null ? data.colliderPxOffsetX : 0,
            colliderPxOffsetY: data.colliderPxOffsetY != null ? data.colliderPxOffsetY : 0
        };
    }
    
    public function reset(spec: EngineEntitySpec): Void {
        if (spec == null) {
            base = createDefaultBaseData();
            return;
        }

        base = specToBaseData(spec);
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
        movementCorrection = Vec2Utils.create(0, 0);
    }
}
