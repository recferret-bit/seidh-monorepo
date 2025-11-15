package game.mvp.view;

import game.mvp.view.entities.character.ragnar.RagnarEntityView;
import game.mvp.view.entities.character.zombie_boy.ZombieBoyEntityView;
import game.mvp.view.entities.character.zombie_girl.ZombieGirlEntityView;
import game.mvp.view.entities.character.glamr.GlamrEntityView;
import engine.model.entities.EntityType;
import game.mvp.model.GameClientState;
import game.mvp.model.entities.BaseEntityModel;
import game.mvp.view.entities.BaseGameEntityView;
import game.mvp.view.entities.character.CharacterEntityView;
import game.mvp.view.entities.collider.ColliderEntityView;
// import game.mvp.view.entities.consumable.ConsumableEntityView;
// import game.mvp.view.entities.effect.EffectEntityView;
import game.mvp.view.camera.CameraController;
import game.mvp.view.camera.CameraConfig;
import h2d.Graphics;
import h2d.Object;
import h2d.Scene;

/**
 * Game view orchestrator
 * Manages view lifecycle, synchronization with models, and visual hierarchy
 * Handles view creation, updates, and destruction with object pooling
 */
class GameViewOrchestrator {
    // Core components
    private final gameClientState: GameClientState;
    private final entityViewPool: EntityViewPool;
    private final parent: Object;
    private final scene: Scene;
    
    // Camera controller
    private var cameraController: CameraController;
    
    // View management
    private final entityViews: Map<Int, BaseGameEntityView>;
    private final viewLayers: Map<EntityType, Object>;
    
    // Debug graphics
    private var debugGraphics: Graphics;
    private var showDebugInfo: Bool;
    
    // Configuration
    private var enableObjectPooling: Bool;
    private var enableInterpolation: Bool;
    
    public function new(gameClientState: GameClientState, parent: Object, scene: Scene) {
        this.gameClientState = gameClientState;
        this.parent = parent;
        this.scene = scene;
        
        // Initialize components
        entityViewPool = new EntityViewPool();
        entityViews = new Map<Int, BaseGameEntityView>();
        viewLayers = new Map<EntityType, Object>();
        
        // Configuration
        enableObjectPooling = true;
        enableInterpolation = true;
        showDebugInfo = false;
        
        // Create view layers
        createViewLayers();
        
        // Create debug graphics
        debugGraphics = new Graphics(parent);
        
        // Initialize camera controller
        initializeCameraController();
    }
    
    /**
     * Create view layers for organization
     */
    private function createViewLayers(): Void {
        // Ragnar layer
        final characterLayer = new Object(parent);
        viewLayers.set(EntityType.RAGNAR, characterLayer);
        
        // Zombie boy layer
        final consumableLayer = new Object(parent);
        viewLayers.set(EntityType.ZOMBIE_BOY, consumableLayer);
        
        // Zombie girl layer
        final effectLayer = new Object(parent);
        viewLayers.set(EntityType.ZOMBIE_GIRL, effectLayer);

        // Glamr layer
        final glamrLayer = new Object(parent);
        viewLayers.set(EntityType.GLAMR, glamrLayer);
        
        // Collider layer
        final colliderLayer = new Object(parent);
        viewLayers.set(EntityType.COLLIDER, colliderLayer);
    }
    
    /**
     * Initialize camera controller
     */
    private function initializeCameraController(): Void {
        final cameraConfig = CameraConfig.createLerpConfig(0.15); // Default smooth following
        
        // Center the character in the camera view
        // Offset camera by half screen size so character appears centered
        final screenWidth = scene.width;
        final screenHeight = scene.height;
        cameraConfig.setViewportOffset(-screenWidth * 0.5, -screenHeight * 0.5);
        
        cameraController = new CameraController(scene, gameClientState, cameraConfig);
    }
    
    /**
     * Update all views
     */
    public function update(dt: Float): Void {
        // Update all active views
        for (view in entityViews) {
            if (view.isViewInitialized()) {
                view.update();
            }
        }
        
        // Update camera controller
        if (cameraController != null) {
            cameraController.update(dt);
        }
        
        // Update debug graphics
        if (showDebugInfo) {
            updateDebugGraphics();
        }
    }
    
    /**
     * Sync views with models
     */
    public function syncWithModels(): Void {
        // Get all models from game state
        final allModels = gameClientState.getAliveEntities();
        
        // Track which models have views
        final modelsWithViews = new Map<Int, Bool>();
        
        // Update existing views
        for (model in allModels) {
            final view = entityViews.get(model.id);
            if (view != null) {
                // Update existing view
                view.update();
                modelsWithViews.set(model.id, true);
            } else {
                // Create new view for model
                createViewForModel(model);
                modelsWithViews.set(model.id, true);
            }
        }
        
        // Remove views for models that no longer exist
        final viewsToRemove = [];
        for (entityId in entityViews.keys()) {
            if (!modelsWithViews.exists(entityId)) {
                viewsToRemove.push(entityId);
            }
        }
        
        for (entityId in viewsToRemove) {
            removeView(entityId);
        }
    }
    
    /**
     * Create view for model
     */
    private function createViewForModel(model: BaseEntityModel): Void {
        var view: BaseGameEntityView = null;
        var layer: Object = null;
        
        // Get appropriate layer
        layer = viewLayers.get(model.type);
        if (layer == null) return;
        
        // Acquire view from pool or create new
        if (enableObjectPooling && model.type != EntityType.COLLIDER) {
            // Skip object pooling for colliders as requested
            view = entityViewPool.acquire(model.type, layer);
        } else {
            switch (model.type) {
                case EntityType.RAGNAR:
                    view = new RagnarEntityView();
                case EntityType.ZOMBIE_BOY:
                    view = new ZombieBoyEntityView();
                case EntityType.ZOMBIE_GIRL:
                    view = new ZombieGirlEntityView();
                case EntityType.GLAMR:
                    view = new GlamrEntityView();
                default:
                    view = new RagnarEntityView(); // Default fallback
            }
        }
        
        if (view != null) {
            // Initialize view with model
            view.initialize(model);
            
            // Store reference
            entityViews.set(model.id, view);
        }
    }
    
    /**
     * Remove view by entity ID
     */
    private function removeView(entityId: Int): Void {
        final view = entityViews.get(entityId);
        if (view != null) {
            // Remove from map
            entityViews.remove(entityId);
            
            // Return to pool or destroy
            if (enableObjectPooling) {
                entityViewPool.release(view);
            } else {
                view.destroy();
            }
        }
    }
    
    /**
     * Get view by entity ID
     */
    public function getView(entityId: Int): BaseGameEntityView {
        return entityViews.get(entityId);
    }
    
    /**
     * Get all views of specific type
     */
    public function getViewsByType(type: EntityType): Array<BaseGameEntityView> {
        final result = [];
        for (view in entityViews) {
            if (view.getModel() != null && view.getModel().type == type) {
                result.push(view);
            }
        }
        return result;
    }
    
    /**
     * Get ragnar views
     */
    public function getRagnarViews(): Array<RagnarEntityView> {
        final result = [];
        for (view in entityViews) {
            if (Std.isOfType(view, RagnarEntityView)) {
                result.push(cast view);
            }
        }
        return result;
    }
    
    /**
     * Update debug graphics
     */
    private function updateDebugGraphics(): Void {
        debugGraphics.clear();
    }
    
    /**
     * Set debug info visibility
     */
    public function setDebugInfoVisible(visible: Bool): Void {
        showDebugInfo = visible;
        if (debugGraphics != null) {
            debugGraphics.visible = visible;
        }
    }
    
    /**
     * Set object pooling enabled
     */
    public function setObjectPoolingEnabled(enabled: Bool): Void {
        enableObjectPooling = enabled;
    }
    
    /**
     * Set interpolation enabled
     */
    public function setInterpolationEnabled(enabled: Bool): Void {
        enableInterpolation = enabled;
    }
    
    /**
     * Get view count
     */
    public function getViewCount(): Int {
        var count = 0;
        for (view in entityViews) {
            count++;
        }
        return count;
    }
    
    /**
     * Get view count by type
     */
    public function getViewCountByType(type: EntityType): Int {
        return getViewsByType(type).length;
    }
    
    /**
     * Clear all views
     */
    public function clear(): Void {
        // Remove all views
        for (entityId in entityViews.keys()) {
            removeView(entityId);
        }
        
        // Clear entity views map
        entityViews.clear();
    }
    
    /**
     * Destroy orchestrator
     */
    public function destroy(): Void {
        // Clear all views
        clear();
        
        // Clear view layers
        for (layer in viewLayers) {
            layer.remove();
        }
        viewLayers.clear();
        
        // Clear debug graphics
        if (debugGraphics != null) {
            debugGraphics.remove();
            debugGraphics = null;
        }
        
        // Clear pool
        entityViewPool.clear();
    }
    
    /**
     * Get camera controller
     */
    public function getCameraController(): CameraController {
        return cameraController;
    }
    
    /**
     * Update camera centering for screen size changes
     */
    public function updateCameraCentering(): Void {
        if (cameraController != null) {
            final screenWidth = scene.width;
            final screenHeight = scene.height;
            cameraController.setViewportOffset(-screenWidth * 0.5, -screenHeight * 0.5);
        }
    }
    
    /**
     * Get orchestrator summary for debugging
     */
    public function getOrchestratorSummary(): Dynamic {
        return {
            viewCount: getViewCount(),
            ragnarViews: getViewCountByType(RAGNAR),
            zombieBoyViews: getViewCountByType(ZOMBIE_BOY),
            zombieGirlViews: getViewCountByType(ZOMBIE_GIRL),
            glamrViews: getViewCountByType(GLAMR),
            poolSummary: entityViewPool.getPoolSummary(),
            objectPoolingEnabled: enableObjectPooling,
            interpolationEnabled: enableInterpolation,
            cameraState: cameraController != null ? cameraController.getCameraState() : null
        };
    }
}
