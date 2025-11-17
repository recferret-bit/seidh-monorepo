package engine;

import engine.EngineConfig;
import engine.eventbus.EventBus;
import engine.eventbus.IEventBus;
import engine.eventbus.events.EntityCorrectionEvent;
import engine.eventbus.events.EntityDeathEvent;
import engine.eventbus.events.EntitySpawnEvent;
import engine.eventbus.events.SnapshotEvent;
import engine.model.GameModelState;
import engine.model.entities.base.BaseEngineEntity;
import engine.model.entities.specs.EngineEntitySpec;
import engine.model.entities.types.EntityType;
import engine.model.managers.IEngineEntityManager;
import engine.modules.ModuleName;
import engine.modules.impl.AIModule;
import engine.modules.impl.InputModule;
import engine.modules.impl.PhysicsModule;
import engine.modules.impl.SpawnModule;
import engine.modules.registry.ModuleRegistry;
import engine.presenter.GameLoop;
import engine.presenter.InputMessage;
import engine.presenter.SnapshotManager;

/**
 * Main Seidh Engine - portable game engine with MVP architecture
 * 
 * Usage:
 * ```haxe
 * var config = {
 *   mode: SINGLEPLAYER,
 *   tickRate: 60,
 *   entitySizePixels: 32,
 *   aiUpdateInterval: 10,
 *   snapshotBufferSize: 1000,
 *   spatialHashCellSize: 64,
 *   rngSeed: 12345,
 *   snapshotEmissionInterval: 5
 * };
 * 
 * var engine = SeidhEngine.create(config);
 * engine.start();
 * 
 * // Subscribe to events
 * var token = engine.subscribeEvent(EventBusConstants.ENTITY_SPAWN, function(event) {
 *   trace("Entity spawned: " + event.entityId);
 * });
 * 
 * // Spawn entities
 * var entityId = engine.spawnEntity(EntityType.CHARACTER, {
 *   pos: {x: 100, y: 200},
 *   ownerId: "player1",
 *   params: {level: 1, maxHp: 100}
 * });
 * 
 * // Queue inputs
 * engine.queueInput({
 *   clientId: "player1",
 *   sequence: 1,
 *   clientTick: 1,
 *   intendedServerTick: 1,
 *   movement: {x: 1, y: 0},
 *   actions: []
 * });
 * ```
 */
@:expose()
class SeidhEngine {
    public static final Config: EngineConfig = {
        mode: SINGLEPLAYER,
        tickRate: 60,
        unitPixels: 32,
        aiUpdateInterval: 10,
        snapshotBufferSize: 1000,
        rngSeed: 12345,
        snapshotEmissionInterval: 5
    };
    
    private var state: GameModelState;
    private var modules: ModuleRegistry;
    private var eventBus: IEventBus;
    private var gameLoop: GameLoop;
    private var snapshotManager: SnapshotManager;
    private var running: Bool;
    
    private function new() {
        this.state = new GameModelState(Config.rngSeed);
        this.modules = new ModuleRegistry();
        this.eventBus = new EventBus();
        this.snapshotManager = new SnapshotManager(Config.snapshotBufferSize);
        this.running = false;
        
        setupModules();
        this.gameLoop = new GameLoop(state, modules, eventBus);
    }
    
    /**
     * Create new engine instance
     * @return Engine instance
     */
    public static function create(): SeidhEngine {
        return new SeidhEngine();
    }
    
    /**
     * Main function for compilation
     */
    public static function main(): Void {
        // This is just for compilation - the engine is used as a library
        trace("Seidh Engine compiled successfully");
    }
    
    /**
     * Start the engine
     */
    public function start(): Void {
        running = true;
        gameLoop.start();
    }
    
    /**
     * Stop the engine
     */
    public function stop(): Void {
        running = false;
        gameLoop.stop();
    }
    
    /**
     * Stop simulation (alias for stop)
     */
    public function stopSimulation(): Void {
        stop();
    }
    
    /**
     * Step engine simulation
     * @param dt Delta time
     */
    public function step(dt: Float): Void {
        stepFixed();
    }
    
    /**
     * Queue input from client
     * @param input Input message
     */
    public function queueInput(input: InputMessage): Void {
        final inputModule = cast(modules.get(ModuleName.INPUT), InputModule);
        if (inputModule != null) {
            inputModule.queueInput(input);
        }
    }
    
    /**
     * Spawn entity
     * @param type Entity type
     * @param spec Entity specification
     * @return Entity ID
     */
    public function spawnEntity(spec: EngineEntitySpec): Int {
        final entityId = state.allocateEntityId();
        spec.id = entityId;
        
        // Find appropriate manager
        final manager: IEngineEntityManager<BaseEngineEntity> = state.managers.get(spec.type);
        if (manager != null) {
            final entity = manager.create(spec);
            
            // Emit spawn event
            eventBus.emit(EntitySpawnEvent.NAME, {
                tick: state.tick,
                entityId: entity.id,
                type: entity.type,
                pos: entity.pos,
                ownerId: entity.ownerId
            });
            
            return entity.id;
        }
        
        return 0;
    }
    
    /**
     * Despawn entity
     * @param entityId Entity ID
     */
    public function despawnEntity(entityId: Int): Void {
        // Find entity in managers
        for (manager in state.managers.getAll()) {
            final entity = manager.find(entityId);
            if (entity != null) {
                // Emit death event
                eventBus.emit(EntityDeathEvent.NAME, {
                    tick: state.tick,
                    entityId: entityId,
                    killerId: 0
                });
                
                manager.destroy(entityId);
                break;
            }
        }
    }
    
    /**
     * Get current snapshot
     * @return State memento
     */
    public function getSnapshot(): GameStateMemento {
        return state.saveMemento();
    }
    
    /**
     * Get event bus for subscribing to events
     * @return Event bus instance
     */
    public function getEventBus(): IEventBus {
        return eventBus;
    }
    
    /**
     * Get input module
     * @return Input module instance
     */
    public function getInputModule(): InputModule {
        return cast(modules.get(ModuleName.INPUT), InputModule);
    }
    
    /**
     * Get entity by ID and type
     * @param id Entity ID
     * @param type Entity type
     * @return Entity or null
     */
    public function getEntityById(id: Int, type: EntityType): BaseEngineEntity {
        final manager: IEngineEntityManager<BaseEngineEntity> = state.managers.get(type);
        if (manager != null) {
            return manager.find(id);
        }
        return null;
    }
    
    /**
     * Get current engine tick
     * @return Current tick
     */
    public function getCurrentTick(): Int {
        return state.tick;
    }

    /**
     * Get all entities from all managers
     * @return Array of all entities
     */
    private function getAllEntities(): Array<Dynamic> {
        final entities = [];
        for (manager in state.managers.getAll()) {
            manager.iterate(function(entity) {
                entities.push(entity);
            });
        }
        return entities;
    }
    
    /**
     * Rollback and replay for client prediction
     * @param anchorTick Anchor tick for rollback
     * @param pendingInputs Pending inputs to replay
     */
    public function rollbackAndReplay(anchorTick: Int, pendingInputs: Array<InputMessage>): Void {
        // Load anchor state
        final anchorMemento = snapshotManager.load(anchorTick);
        if (anchorMemento == null) {
            trace("Warning: No snapshot found for anchor tick " + anchorTick);
            return;
        }
        
        // Rollback to anchor state
        state.restoreMemento(anchorMemento);
        
        // Replay pending inputs
        for (input in pendingInputs) {
            if (input.intendedServerTick > anchorTick) {
                queueInput(input);
            }
        }
        
        // Step forward to current tick
        final currentTick = state.tick;
        while (state.tick < currentTick) {
            gameLoop.stepFixed();
        }
        
        // Emit correction events
        emitCorrectionEvents();
    }
    
    /**
     * Execute single engine step
     */
    public function stepFixed(): Void {
        gameLoop.stepFixed();
        
        // Store snapshot
        snapshotManager.store(state.tick, state.saveMemento());
        
        // Emit snapshot events based on mode
        emitSnapshotEvents();
    }
    
    private function setupModules(): Void {
        // Create and register modules
        final inputModule = new InputModule();
        final physicsModule = new PhysicsModule();
        final aiModule = new AIModule();
        final spawnModule = new SpawnModule();
        
        modules.register(ModuleName.INPUT, inputModule);
        modules.register(ModuleName.PHYSICS, physicsModule);
        modules.register(ModuleName.AI, aiModule);
        modules.register(ModuleName.SPAWN, spawnModule);
    }

    private function emitSnapshotEvents(): Void {
        switch (SeidhEngine.Config.mode) {
            case SINGLEPLAYER:
                // No snapshot events for singleplayer
            case SERVER:
                if (state.tick % SeidhEngine.Config.snapshotEmissionInterval == 0) {
                    eventBus.emit(SnapshotEvent.NAME, {
                        tick: state.tick,
                        serializedState: state.saveMemento()
                    });
                }
            case CLIENT_PREDICTION:
                // Always emit snapshots for client prediction
                eventBus.emit(SnapshotEvent.NAME, {
                    tick: state.tick,
                    serializedState: state.saveMemento()
                });
        }
    }
    
    private function emitCorrectionEvents(): Void {
        // Emit entity correction events for client prediction
        for (manager in state.managers.getAll()) {
            manager.iterate(function(entity) {
                eventBus.emit(EntityCorrectionEvent.NAME, {
                    tick: state.tick,
                    entityId: entity.id,
                    correctedPos: entity.pos,
                    correctedVel: entity.vel
                });
            });
        }
    }
}
