package engine.model.entities.abs;

import engine.geometry.Vec2;
import engine.model.entities.types.EntityType;
import engine.model.entities.types.EngineEntitySpec;
import engine.model.entities.types.BaseEntityData;

/**
 * Entity contract for all game entities
 */
abstract class AbstractEngineEntity {
    /** Base entity data */
    public var base: BaseEntityData;
    
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
    public var colliderPxOffsetX(get, set): Float;
    public var colliderPxOffsetY(get, set): Float;
    
    private function get_id(): Int return base.id;
    private function set_id(v: Int): Int return base.id = v;
    private function get_type(): EntityType return base.type;
    private function set_type(v: EntityType): EntityType return base.type = v;
    private function get_pos(): Vec2 return base.pos;
    private function set_pos(v: Vec2): Vec2 return base.pos = v;
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
    private function set_colliderWidth(v: Float): Float return base.colliderWidth = v;
    private function get_colliderHeight(): Float return base.colliderHeight;
    private function set_colliderHeight(v: Float): Float return base.colliderHeight = v;
    private function get_colliderPxOffsetX(): Float return base.colliderPxOffsetX;
    private function set_colliderPxOffsetX(v: Float): Float return base.colliderPxOffsetX = v;
    private function get_colliderPxOffsetY(): Float return base.colliderPxOffsetY;
    private function set_colliderPxOffsetY(v: Float): Float return base.colliderPxOffsetY = v;
    
    /**
     * Serialize entity to JSON-serializable object
     * @return Serialized data
     */
    public abstract function serialize(): Dynamic;
    
    /**
     * Deserialize entity from data
     * @param data Serialized data
     */
    public abstract function deserialize(data: Dynamic): Void;
    
    /**
     * Reset entity to initial state from spec
     * @param spec Entity specification
     */
    public abstract function reset(spec: EngineEntitySpec): Void;
}

