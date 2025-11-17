package game.mvp.view;

import engine.model.entities.types.EntityType;
import game.mvp.view.entities.BaseGameEntityView;
import h2d.Object;

/**
 * Object pool for view entities
 * Manages typed pools for efficient view entity reuse
 * Implements acquire/release pattern for object pooling
 */

class EntityViewPool {
    // Unified pool map for all entity types
    private var pools: Map<EntityType, Array<BaseGameEntityView>>;
    
    // Factory functions for creating views
    private var factories: Map<EntityType, Void->BaseGameEntityView>;
    
    // Pool statistics
    private var poolStats: Map<EntityType, PoolStats>;
    
    // Configuration
    private var maxPoolSize: Int;
    private var initialPoolSize: Int;
    
    public function new(maxPoolSize: Int = 50, initialPoolSize: Int = 5) {
        this.maxPoolSize = maxPoolSize;
        this.initialPoolSize = initialPoolSize;
        
        // Initialize pools map
        pools = new Map<EntityType, Array<BaseGameEntityView>>();
        
        // Initialize factory map
        factories = new Map<EntityType, Void->BaseGameEntityView>();
        registerFactories();

        // Initialize statistics
        poolStats = new Map<EntityType, PoolStats>();
        initializeStats();

        // Pre-populate pools
        initializePools();
    }
    
    /**
     * Register factory functions for each entity type
     */
    private function registerFactories(): Void {
        // Register factories for all supported entity types
        final supportedTypes = [
            EntityType.RAGNAR,
            EntityType.ZOMBIE_BOY,
            EntityType.ZOMBIE_GIRL,
            EntityType.GLAMR,
            EntityType.COLLIDER
        ];
        
        for (type in supportedTypes) {
            if (EntityViewFactory.isSupported(type)) {
                // Capture type in local variable to avoid closure issues
                final entityType = type;
                factories.set(type, function() {
                    return EntityViewFactory.create(entityType);
                });
            }
        }
    }
    
    /**
     * Initialize statistics for all entity types
     */
    private function initializeStats(): Void {
        for (type => _ in factories) {
            pools.set(type, []);
            poolStats.set(type, new PoolStats());
        }
    }
    
    /**
     * Initialize pools with initial objects
     */
    private function initializePools(): Void {
        // Pre-create views for each entity type
        for (type => factory in factories) {
            final pool = pools.get(type);
            for (i in 0...initialPoolSize) {
                final view = factory();
                view.reset();
                pool.push(view);
            }
        }
    }
    
    /**
     * Acquire view from pool
     */
    public function acquire(type: EntityType, parent: Object): BaseGameEntityView {
        var view: BaseGameEntityView = null;
        
        // Get pool for this entity type
        final pool = pools.get(type);
        final factory = factories.get(type);
        
        if (pool == null || factory == null) {
            return null;
        }
        
        // Try to get from pool, or create new if pool is empty
        view = getFromPool(pool);
        if (view == null) {
            view = factory();
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
            if (stats != null) {
                stats.acquired++;
                stats.activeCount++;
            }
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
        final pool = pools.get(type);
        final stats = poolStats.get(type);
        
        if (pool == null || stats == null) {
            view.destroy();
            return;
        }
        
        // Reset view for reuse
        view.release();
        
        // Add back to pool if not full, otherwise destroy
        if (pool.length < maxPoolSize) {
            pool.push(view);
        } else {
            // Pool is full, destroy the view
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
        final pool = pools.get(type);
        return pool != null ? pool.length : 0;
    }
    
    /**
     * Get total pool size
     */
    public function getTotalPoolSize(): Int {
        var total = 0;
        for (pool in pools) {
            total += pool.length;
        }
        return total;
    }
    
    /**
     * Get active count for specific type
     */
    public function getActiveCount(type: EntityType): Int {
        var stats = poolStats.get(type);
        return stats != null ? stats.activeCount : 0;
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
        for (pool in pools) {
            for (view in pool) {
                view.destroy();
            }
            pool.resize(0);
        }
        
        // Reset statistics
        for (stats in poolStats) {
            stats.reset();
        }
    }
    
    /**
     * Get pool summary for debugging
     */
    public function getPoolSummary(): Dynamic {
        final summary: Dynamic = {
            totalPooled: getTotalPoolSize(),
            totalActive: getTotalActiveCount(),
            pools: {}
        };
        
        // Add summary for each pool type
        for (type => pool in pools) {
            final stats = poolStats.get(type);
            Reflect.setField(summary.pools, type, {
                pooled: pool.length,
                active: stats != null ? stats.activeCount : 0,
                acquired: stats != null ? stats.acquired : 0,
                released: stats != null ? stats.released : 0
            });
        }
        
        return summary;
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
