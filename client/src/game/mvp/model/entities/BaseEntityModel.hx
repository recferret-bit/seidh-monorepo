package game.mvp.model.entities;

import engine.model.entities.base.BaseEngineEntity;
import engine.model.entities.types.EntityType;

/**
 * Base entity model that wraps engine BaseEntity
 * Adds visual metadata and game-specific properties
 */
class BaseEntityModel {
    // Reference to engine entity (no duplication!)
    public var engineEntity: BaseEngineEntity;
    
    // Visual properties
    public var visualScale: Float;
    
    // Interpolation support
    public var previousPos: engine.geometry.Vec2;
    public var renderPos: engine.geometry.Vec2;
    public var positionHistory: Array<{tick: Int, pos: engine.geometry.Vec2}>;
    public var interpolationAlpha: Float;
    
    // Sync state
    public var needsVisualUpdate: Bool;
    public var lastUpdateTick: Int;
    
    public function new() {
        visualScale = 1.0;
        
        // Initialize interpolation fields
        previousPos = new engine.geometry.Vec2(0, 0);
        renderPos = new engine.geometry.Vec2(0, 0);
        positionHistory = [];
        interpolationAlpha = 0.0;
        
        needsVisualUpdate = true;
        lastUpdateTick = 0;
    }
    
    /**
     * Initialize with engine entity
     */
    public function initialize(engineEntity: BaseEngineEntity): Void {
        this.engineEntity = engineEntity;
        
        // Initialize interpolation with current position
        previousPos = new engine.geometry.Vec2(engineEntity.pos.x, engineEntity.pos.y);
        renderPos = new engine.geometry.Vec2(engineEntity.pos.x, engineEntity.pos.y);
        positionHistory = [{tick: 0, pos: new engine.geometry.Vec2(engineEntity.pos.x, engineEntity.pos.y)}];
        interpolationAlpha = 0.0;
        
        needsVisualUpdate = true;
        lastUpdateTick = 0;
    }
    
    /**
     * Update from engine entity (called each frame)
     */
    public function updateFromEngine(): Void {
        if (engineEntity == null) return;
        
        needsVisualUpdate = true;
        lastUpdateTick++;
    }
    
    /**
     * Reset for reuse in object pool
     */
    public function reset(): Void {
        engineEntity = null;
        visualScale = 1.0;
        
        // Reset interpolation fields
        previousPos = new engine.geometry.Vec2(0, 0);
        renderPos = new engine.geometry.Vec2(0, 0);
        positionHistory = [];
        interpolationAlpha = 0.0;
        
        needsVisualUpdate = true;
        lastUpdateTick = 0;
    }
    
    // Convenience getters that delegate to engine entity
    public var id(get, never): Int;
    public var type(get, never): EntityType;
    public var pos(get, never): engine.geometry.Vec2;
    public var vel(get, never): engine.geometry.Vec2;
    public var rotation(get, never): Float;
    public var ownerId(get, never): String;
    public var isAlive(get, never): Bool;
    public var colliderWidth(get, never): Float;
    public var colliderHeight(get, never): Float;
    public var colliderOffset(get, never): engine.geometry.Vec2;
    
    private function get_id(): Int return engineEntity != null ? engineEntity.id : 0;
    private function get_type(): EntityType return engineEntity != null ? engineEntity.type : GENERIC;
    private function get_pos(): engine.geometry.Vec2 return engineEntity != null ? engineEntity.pos : new engine.geometry.Vec2(0, 0);
    private function get_vel(): engine.geometry.Vec2 return engineEntity != null ? engineEntity.vel : new engine.geometry.Vec2(0, 0);
    private function get_rotation(): Float return engineEntity != null ? engineEntity.rotation : 0;
    private function get_ownerId(): String return engineEntity != null ? engineEntity.ownerId : "";
    private function get_isAlive(): Bool return engineEntity != null ? engineEntity.isAlive : false;
    private function get_colliderWidth(): Float return engineEntity != null ? engineEntity.colliderWidth : 1.0;
    private function get_colliderHeight(): Float return engineEntity != null ? engineEntity.colliderHeight : 1.0;
    private function get_colliderOffset(): engine.geometry.Vec2 return engineEntity != null ? engineEntity.colliderOffset : new engine.geometry.Vec2(0, 0);
}
