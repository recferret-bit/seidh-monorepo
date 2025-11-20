package engine.infrastructure.pooling;

import engine.domain.entities.BaseEntity;
import engine.domain.geometry.Vec2;
import engine.domain.types.EntityType;

/**
 * Generic object pool for entity reuse
 */
class ObjectPool {
    private var pools: Map<EntityType, Array<BaseEntity>>;
    
    public function new() {
        pools = new Map();
    }
    
    /**
     * Prewarm pool with objects
     * @param kind Entity type
     * @param count Number of objects to create
     * @param factory Factory function to create objects
     */
    public function prewarm(kind: EntityType, count: Int, factory: Void->BaseEntity): Void {
        if (!pools.exists(kind)) {
            pools.set(kind, []);
        }
        
        final pool = pools.get(kind);
        for (i in 0...count) {
            pool.push(factory());
        }
    }
    
    /**
     * Acquire object from pool or create new one
     * @param kind Entity type
     * @param factory Factory function if pool is empty
     * @return Entity instance
     */
    public function acquire(kind: EntityType, factory: Void->BaseEntity): BaseEntity {
        if (!pools.exists(kind)) {
            pools.set(kind, []);
        }
        
        final pool = pools.get(kind);
        if (pool.length > 0) {
            return pool.pop();
        }
        
        return factory();
    }
    
    /**
     * Release object back to pool
     * @param kind Entity type
     * @param obj Object to release
     */
    public function release(kind: EntityType, obj: BaseEntity): Void {
        if (!pools.exists(kind)) {
            pools.set(kind, []);
        }
        
        // Reset to default state
        obj.reset({
            id: 0,
            type: kind,
            pos: new Vec2(0, 0),
            vel: new Vec2(0, 0),
            rotation: 0,
            ownerId: "",
            isAlive: false
        });
        
        pools.get(kind).push(obj);
    }
}

