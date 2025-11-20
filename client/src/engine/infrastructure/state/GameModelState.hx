package engine.infrastructure.state;

import engine.domain.config.EngineConfig;
import engine.domain.geometry.Vec2;
import engine.domain.services.DeterministicRng;
import engine.domain.types.EntityType;
import engine.infrastructure.adapters.persistence.EntityRepository;
import engine.infrastructure.factories.EngineEntityFactory;
import engine.infrastructure.pooling.ObjectPool;

// Memento type definitions for snapshot system
typedef EngineEntityMemento = {
    id: Int,
    type: EntityType,
    pos: Vec2,
    vel: Vec2,
    rotation: Float,
    ownerId: String,
    isAlive: Bool,
    // Additional entity-specific data
    ?maxHp: Int,
    ?hp: Int,
    ?level: Int,
    ?stats: Dynamic,
    ?attackDefs: Array<Dynamic>,
    ?spellBook: Array<Dynamic>,
    ?aiProfile: String,
    ?effectType: String,
    ?duration: Int,
    ?consumableType: String,
    ?quantity: Int
}

typedef GameStateMemento = {
    tick: Int,
    nextEntityId: Int,
    rng: {seed: Int, state: Int},
    transientColliders: Array<Dynamic>,
    entities: Array<Dynamic>
}

/**
 * Central game state container
 */
class GameModelState {
    public var tick: Int;
    public var nextEntityId: Int;
    public var rng: DeterministicRng;
    public var entityRepository: EntityRepository;
    public var transientColliders: Array<Dynamic>;
    public var config: EngineConfig;

    private var entityFactory: EngineEntityFactory;
    private var objectPool: ObjectPool;
    
    public function new(config: EngineConfig) {
        this.config = config != null ? config : SeidhEngine.DEFAULT_CONFIG;
        tick = 0;
        nextEntityId = 1;
        rng = new DeterministicRng(this.config.rngSeed);
        transientColliders = [];
        
        objectPool = new ObjectPool();
        entityFactory = new EngineEntityFactory(objectPool);
        entityRepository = new EntityRepository(entityFactory, objectPool);
    }
    
    /**
     * Allocate next entity ID
     * @return New entity ID
     */
    public function allocateEntityId(): Int {
        return nextEntityId++;
    }
    
    /**
     * Save current state as memento
     * @return State memento
     */
    public function saveMemento(): GameStateMemento {
        return {
            tick: tick,
            nextEntityId: nextEntityId,
            rng: rng.serialize(),
            transientColliders: transientColliders,
            entities: entityRepository.saveMemento()
        };
    }
    
    /**
     * Restore state from memento
     * @param memento State memento
     */
    public function restoreMemento(memento: GameStateMemento): Void {
        tick = memento.tick;
        nextEntityId = memento.nextEntityId;
        rng.deserialize(memento.rng);
        transientColliders = memento.transientColliders;
        entityRepository.restoreMemento(memento.entities);
    }

}

