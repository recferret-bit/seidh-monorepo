package game.mvp.view;

import game.mvp.view.entities.character.ragnar.RagnarEntityView;
import game.mvp.view.entities.character.zombie_boy.ZombieBoyEntityView;
import game.mvp.view.entities.character.glamr.GlamrEntityView;
import game.mvp.view.entities.character.zombie_girl.ZombieGirlEntityView;
import engine.model.entities.EntityType;
import game.mvp.view.entities.BaseGameEntityView;
import game.mvp.view.entities.character.CharacterEntityView;
// import game.mvp.view.entities.consumable.ConsumableEntityView;
// import game.mvp.view.entities.effect.EffectEntityView;
import h2d.Object;

/**
 * Object pool for view entities
 * Manages typed pools for efficient view entity reuse
 * Implements acquire/release pattern for object pooling
 */

// TODO create a generic pool for all entity types
class EntityViewPool {
    // Typed pools for each entity type
    private var ragnarPool: Array<BaseGameEntityView>;
    private var zombieBoyPool: Array<BaseGameEntityView>;
    private var zombieGirlPool: Array<BaseGameEntityView>;
    private var glamrPool: Array<BaseGameEntityView>;
    
    // Pool statistics
    private var poolStats: Map<EntityType, PoolStats>;
    
    // Configuration
    private var maxPoolSize: Int;
    private var initialPoolSize: Int;
    
    public function new(maxPoolSize: Int = 50, initialPoolSize: Int = 5) {
        this.maxPoolSize = maxPoolSize;
        this.initialPoolSize = initialPoolSize;
        
        // Initialize pools
        ragnarPool = [];
        zombieBoyPool = [];
        zombieGirlPool = [];
        glamrPool = [];
        
        // Initialize statistics
        poolStats = new Map<EntityType, PoolStats>();
        poolStats.set(EntityType.RAGNAR, new PoolStats());
        poolStats.set(EntityType.ZOMBIE_BOY, new PoolStats());
        poolStats.set(EntityType.ZOMBIE_GIRL, new PoolStats());
        poolStats.set(EntityType.GLAMR, new PoolStats());
        
        // Pre-populate pools
        initializePools();
    }
    
    /**
     * Initialize pools with initial objects
     */
    private function initializePools(): Void {
        // Pre-create character views
        for (i in 0...initialPoolSize) {
            final view: BaseGameEntityView = new RagnarEntityView();
            view.setPoolType(EntityType.RAGNAR);
            view.reset();
            ragnarPool.push(view);
        }
    }
    
    /**
     * Acquire view from pool
     */
    public function acquire(type: EntityType, parent: Object = null): BaseGameEntityView {
        var view: BaseGameEntityView = null;
        
        switch (type) {
            case EntityType.RAGNAR:
                view = getFromPool(ragnarPool);
                if (view == null) {
                    view = new RagnarEntityView();
                    view.setPoolType(EntityType.RAGNAR);
                }
            case EntityType.ZOMBIE_BOY:
                view = getFromPool(zombieBoyPool);
                if (view == null) {
                    view = new ZombieBoyEntityView();
                    view.setPoolType(EntityType.ZOMBIE_BOY);
                }
            case EntityType.ZOMBIE_GIRL:
                view = getFromPool(zombieGirlPool);
                if (view == null) {
                    view = new ZombieGirlEntityView();
                    view.setPoolType(EntityType.ZOMBIE_GIRL);
                }
            case EntityType.GLAMR:
                view = getFromPool(glamrPool);
                if (view == null) {
                    view = new GlamrEntityView();
                    view.setPoolType(EntityType.GLAMR);
                }
            default:
                view = null;
        }
        
        if (view != null) {
            // Set parent if provided
            if (parent != null && view.parent != parent) {
                parent.addChild(view);
            }
            
            // Prepare for use
            view.acquire();
            
            // Update statistics
            final stats = poolStats.get(type);
            stats.acquired++;
            stats.activeCount++;
        }
        
        return view;
    }
    
    /**
     * Release view back to pool
     */
    public function release(view: BaseGameEntityView): Void {
        if (view == null || !view.isInObjectPool()) {
            return;
        }
        
        final type = view.getPoolType();
        final stats = poolStats.get(type);
        
        // Reset view for reuse
        view.release();
        
        // Add back to appropriate pool
        switch (type) {
            case EntityType.RAGNAR:
                if (ragnarPool.length < maxPoolSize) {
                    ragnarPool.push(view);
                } else {
                    // Pool is full, destroy the view
                    view.destroy();
                }
            case EntityType.ZOMBIE_BOY:
                if (zombieBoyPool.length < maxPoolSize) {
                    zombieBoyPool.push(view);
                } else {
                    view.destroy();
                }
            case EntityType.ZOMBIE_GIRL:
                if (zombieGirlPool.length < maxPoolSize) {
                    zombieGirlPool.push(view);
                } else {
                    view.destroy();
                }
            case EntityType.GLAMR:
                if (glamrPool.length < maxPoolSize) {
                    glamrPool.push(view);
                } else {
                    view.destroy();
                }
            default:
                view.destroy();
        }
        
        // Update statistics
        stats.released++;
        stats.activeCount--;
    }
    
    /**
     * Get view from pool (internal method)
     */
    private function getFromPool(pool: Array<BaseGameEntityView>): BaseGameEntityView {
        if (pool.length > 0) {
            return pool.pop();
        }
        return null;
    }
    
    /**
     * Get pool size for specific type
     */
    public function getPoolSize(type: EntityType): Int {
        switch (type) {
            case EntityType.RAGNAR:
                return ragnarPool.length;
            case EntityType.ZOMBIE_BOY:
                return zombieBoyPool.length;
            case EntityType.ZOMBIE_GIRL:
                return zombieGirlPool.length;
            case EntityType.GLAMR:
                return glamrPool.length;
            default:
                return 0;
        }
    }
    
    /**
     * Get total pool size
     */
    public function getTotalPoolSize(): Int {
        return ragnarPool.length + zombieBoyPool.length + zombieGirlPool.length + glamrPool.length;
    }
    
    /**
     * Get active count for specific type
     */
    public function getActiveCount(type: EntityType): Int {
        var stats = poolStats.get(type);
        return stats.activeCount;
    }
    
    /**
     * Get total active count
     */
    public function getTotalActiveCount(): Int {
        var total = 0;
        for (stats in poolStats) {
            total += stats.activeCount;
        }
        return total;
    }
    
    /**
     * Get pool statistics
     */
    public function getPoolStats(type: EntityType): PoolStats {
        return poolStats.get(type);
    }
    
    /**
     * Get all pool statistics
     */
    public function getAllPoolStats(): Map<EntityType, PoolStats> {
        return poolStats;
    }
    
    /**
     * Clear all pools
     */
    public function clear(): Void {
        // Destroy all pooled objects
        for (view in ragnarPool) {
            view.destroy();
        }
        for (view in zombieBoyPool) {
            view.destroy();
        }
        for (view in zombieGirlPool) {
            view.destroy();
        }
        for (view in glamrPool) {
            view.destroy();
        }
        
        // Clear pools
        ragnarPool = [];
        zombieBoyPool = [];
        zombieGirlPool = [];
        glamrPool = [];
        
        // Reset statistics
        for (stats in poolStats) {
            stats.reset();
        }
    }
    
    /**
     * Get pool summary for debugging
     */
    public function getPoolSummary(): Dynamic {
        return {
            totalPooled: getTotalPoolSize(),
            totalActive: getTotalActiveCount(),
            ragnarPool: {
                pooled: ragnarPool.length,
                active: getActiveCount(EntityType.RAGNAR),
                acquired: poolStats.get(EntityType.RAGNAR).acquired,
                released: poolStats.get(EntityType.RAGNAR).released
            },
            zombieBoyPool: {
                pooled: zombieBoyPool.length,
                active: getActiveCount(EntityType.ZOMBIE_BOY),
                acquired: poolStats.get(EntityType.ZOMBIE_BOY).acquired,
                released: poolStats.get(EntityType.ZOMBIE_BOY).released
            },
            zombieGirlPool: {
                pooled: zombieGirlPool.length,
                active: getActiveCount(EntityType.ZOMBIE_GIRL),
                acquired: poolStats.get(EntityType.ZOMBIE_GIRL).acquired,
                released: poolStats.get(EntityType.ZOMBIE_GIRL).released
            },
            glamrPool: {
                pooled: glamrPool.length,
                active: getActiveCount(EntityType.GLAMR),
                acquired: poolStats.get(EntityType.GLAMR).acquired,
                released: poolStats.get(EntityType.GLAMR).released
            }
        };
    }
}

/**
 * Pool statistics container
 */
class PoolStats {
    public var acquired: Int;
    public var released: Int;
    public var activeCount: Int;
    
    public function new() {
        acquired = 0;
        released = 0;
        activeCount = 0;
    }
    
    public function reset(): Void {
        acquired = 0;
        released = 0;
        activeCount = 0;
    }
}
