package engine;

import engine.config.EngineConfig;
import engine.config.EngineMode;
import engine.domain.entities.BaseEntity;
import engine.infrastructure.eventbus.EventBus;
import engine.infrastructure.eventbus.IEventBus;
import engine.infrastructure.eventbus.events.EntityCorrectionEvent;
import engine.infrastructure.eventbus.events.EntityDeathEvent;
import engine.infrastructure.eventbus.events.EntitySpawnEvent;
import engine.infrastructure.eventbus.events.SnapshotEvent;
import engine.infrastructure.state.GameModelState;
import engine.domain.entities.BaseEntity;
import engine.domain.specs.EntitySpec;
import engine.domain.types.EntityType;
import engine.infrastructure.managers.IEngineEntityManager;
import engine.infrastructure.config.ServiceRegistry;
import engine.infrastructure.config.ServiceName;
import engine.application.services.InputService;
import engine.application.services.AIService;
import engine.application.services.PhysicsService;
import engine.application.services.SpawnService;
import engine.infrastructure.config.UseCaseFactory;
import engine.infrastructure.persistence.EntityRepository;
import engine.infrastructure.events.EventPublisher;
import engine.presentation.GameLoop;
import engine.presentation.InputMessage;
import engine.presentation.SnapshotManager;
import engine.domain.entities.character.factory.DefaultCharacterEntityFactory;
import engine.domain.entities.collider.DefaultColliderEntityFactory;
import engine.domain.entities.consumable.factory.DefaultConsumableEntityFactory;
import engine.infrastructure.logging.Logger;
import engine.infrastructure.services.ClientEntityMappingService;

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
    public static final DEFAULT_CONFIG: EngineConfig = {
        mode: SINGLEPLAYER,
        tickRate: 60,
        unitPixels: 32,
        aiUpdateInterval: 10,
        snapshotBufferSize: 1000,
        rngSeed: 12345,
        snapshotEmissionInterval: 5,
        debugLogging: false
    };
    public static var Config(default, null): EngineConfig;

    private final config: EngineConfig;
    private var state: GameModelState;
    private var services: ServiceRegistry;
    private var eventBus: IEventBus;
    private var gameLoop: GameLoop;
    private var snapshotManager: SnapshotManager;
    private var running: Bool;
    private var useCaseFactory: UseCaseFactory;
    private var entityRepository: EntityRepository;
    private var eventPublisher: EventPublisher;
    
    private function new(config: EngineConfig) {
        this.config = config;
        SeidhEngine.Config = config;
        Logger.configure(config.debugLogging == true);
        
        // Initialize BaseEntity static configuration
        BaseEntity.setUnitPixels(config.unitPixels);
        
        this.state = new GameModelState(config);
        this.services = new ServiceRegistry();
        this.eventBus = new EventBus();
        this.snapshotManager = new SnapshotManager(config.snapshotBufferSize);
        this.running = false;
        
        // Create infrastructure implementations
        final characterFactory = new DefaultCharacterEntityFactory();
        final consumableFactory = new DefaultConsumableEntityFactory();
        final colliderFactory = new DefaultColliderEntityFactory();
        this.eventPublisher = new EventPublisher(eventBus, state);
        this.entityRepository = new EntityRepository(state, characterFactory, consumableFactory, colliderFactory);
        
        // Create use case factory (creates all use cases)
        this.useCaseFactory = new UseCaseFactory(
            entityRepository,
            eventPublisher,
            state,
            characterFactory,
            consumableFactory,
            colliderFactory
        );
        
        setupServices();
        this.gameLoop = new GameLoop(state, services, eventBus, config.tickRate);
    }
    
    /**
     * Create new engine instance
     * @return Engine instance
     */
    public static function create(?config: EngineConfig): SeidhEngine {
        final engineConfig = config != null ? config : DEFAULT_CONFIG;
        return new SeidhEngine(engineConfig);
    }
    
    /**
     * Main function for compilation
     */
    public static function main(): Void {
        Logger.debug("Seidh Engine compiled successfully");
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
        final inputService = cast(services.get(ServiceName.INPUT), InputService);
        if (inputService != null) {
            inputService.queueInput(input);
        }
    }
    
    /**
     * Spawn entity
     * @param spec Entity specification
     * @return Entity ID
     */
    public function spawnEntity(spec: EntitySpec): Int {
        final entityId = useCaseFactory.spawnEntity(spec);
        if (entityId == 0 && spec != null && spec.type != null) {
            Logger.warn('Failed to spawn entity of type: ${spec.type}');
        }
        return entityId;
    }
    
    /**
     * Despawn entity
     * @param entityId Entity ID
     */
    public function despawnEntity(entityId: Int): Void {
        useCaseFactory.despawnEntity(entityId);
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
     * Get input service
     * @return Input service instance
     */
    public function getInputService(): InputService {
        return cast(services.get(ServiceName.INPUT), InputService);
    }

    /**
     * Get client entity mapping module
     */
    public function getInputModule(): ClientEntityMappingService {
        return useCaseFactory != null ? useCaseFactory.clientEntityMappingService : null;
    }
    
    /**
     * Get entity by ID and type
     * @param id Entity ID
     * @param type Entity type
     * @return Entity or null
     */
    public function getEntityById(id: Int, type: EntityType): BaseEntity {
        final manager: IEngineEntityManager<BaseEntity> = state.managers.get(type);
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
     * Rollback and replay for client prediction
     * @param anchorTick Anchor tick for rollback
     * @param pendingInputs Pending inputs to replay
     */
    public function rollbackAndReplay(anchorTick: Int, pendingInputs: Array<InputMessage>): Void {
        // Load anchor state
        final anchorMemento = snapshotManager.load(anchorTick);
        if (anchorMemento == null) {
            Logger.warn("No snapshot found for anchor tick " + anchorTick);
            return;
        }

        // Remember how far we had already simulated
        final targetTick = state.tick;

        // Rollback to anchor state
        state.restoreMemento(anchorMemento);

        // Nothing to replay if we were already at or before the anchor tick
        if (targetTick <= anchorTick) {
            emitCorrectionEvents();
            return;
        }

        // Replay pending inputs in deterministic order
        final inputsToReplay = pendingInputs.copy();
        inputsToReplay.sort(function(a, b) {
            if (a.intendedServerTick != b.intendedServerTick) {
                return a.intendedServerTick - b.intendedServerTick;
            }
            return a.sequence - b.sequence;
        });

        for (input in inputsToReplay) {
            if (input.intendedServerTick > anchorTick) {
                queueInput(input);
            }
        }

        // Step forward to previously simulated tick
        while (state.tick < targetTick) {
            final tickBeforeStep = state.tick;
            stepFixed();

            if (state.tick == tickBeforeStep) {
                Logger.warn("Unable to advance simulation during rollback replay");
                break;
            }
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
    
    private function setupServices(): Void {
        // Create and register services
        final inputService = new InputService(
            useCaseFactory.processInputUseCase,
            useCaseFactory.inputBufferService,
            useCaseFactory.clientEntityMappingService
        );
        final physicsService = new PhysicsService(
            useCaseFactory.integratePhysicsUseCase,
            useCaseFactory.resolveCollisionUseCase
        );
        final aiService = new AIService(useCaseFactory.updateAIBehaviorUseCase);
        final spawnService = new SpawnService(useCaseFactory.cleanupDeadEntitiesUseCase);
        
        services.register(ServiceName.INPUT, inputService);
        services.register(ServiceName.PHYSICS, physicsService);
        services.register(ServiceName.AI, aiService);
        services.register(ServiceName.SPAWN, spawnService);
    }

    private function emitSnapshotEvents(): Void {
        switch (config.mode) {
            case SINGLEPLAYER:
                // No snapshot events for singleplayer
            case SERVER:
                if (state.tick % config.snapshotEmissionInterval == 0) {
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
