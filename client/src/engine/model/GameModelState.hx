package engine.model;

import engine.geometry.Vec2;
import engine.model.DeterministicRng;
import engine.model.ObjectPool;
import engine.model.entities.types.EntityType;
import engine.model.entities.factory.EngineEntityFactory;
import engine.model.entities.base.BaseEngineEntity;
import engine.model.entities.character.BaseCharacterEntity;
import engine.model.entities.collider.ColliderEntity;
import engine.model.entities.consumable.BaseConsumableEntity;
import engine.model.managers.BaseEngineEntityManager;
import engine.model.managers.EngineEntityManagerRegistry;
import engine.model.managers.IEngineEntityManager;
import engine.model.managers.IEngineEntityManagerRegistry;

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

typedef EntityManagerMemento = {
    type: EntityType,
    entities: Array<EngineEntityMemento>
}

typedef GameStateMemento = {
    tick: Int,
    nextEntityId: Int,
    rng: {seed: Int, state: Int},
    transientColliders: Array<Dynamic>,
    managers: Array<EntityManagerMemento>
}

/**
 * Central game state container
 */
class GameModelState {
    public var tick: Int;
    public var nextEntityId: Int;
    public var rng: DeterministicRng;
    public var managers: IEngineEntityManagerRegistry;
    public var transientColliders: Array<Dynamic>;

    private var entityFactory: EngineEntityFactory;
    private var objectPool: ObjectPool;
    
    public function new(seed: Int) {
        tick = 0;
        nextEntityId = 1;
        rng = new DeterministicRng(seed);
        transientColliders = [];
        
        objectPool = new ObjectPool();
        entityFactory = new EngineEntityFactory(objectPool);
        managers = new EngineEntityManagerRegistry();
        
        setupManagers();
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
            managers: managers.saveMemento()
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
        managers.restoreMemento(memento.managers);
    }
    
    /**
     * Get manager by entity type
     * @param type Entity type
     * @return Manager for the specified entity type
     */
    public function getManager<T:BaseEngineEntity>(type: EntityType): IEngineEntityManager<T> {
        return managers.get(type);
    }
    
    private function setupManagers(): Void {
        // Register core entity managers
        managers.register(EntityType.RAGNAR, new BaseEngineEntityManager<BaseCharacterEntity>(entityFactory));
        managers.register(EntityType.ZOMBIE_BOY, new BaseEngineEntityManager<BaseCharacterEntity>(entityFactory));
        managers.register(EntityType.ZOMBIE_GIRL, new BaseEngineEntityManager<BaseCharacterEntity>(entityFactory));
        managers.register(EntityType.GLAMR, new BaseEngineEntityManager<BaseCharacterEntity>(entityFactory));
        managers.register(EntityType.COLLIDER, new BaseEngineEntityManager<ColliderEntity>(entityFactory));
        managers.register(EntityType.HEALTH_POTION, new BaseEngineEntityManager<BaseConsumableEntity>(entityFactory));
        managers.register(EntityType.ARMOR_POTION, new BaseEngineEntityManager<BaseConsumableEntity>(entityFactory));
        managers.register(EntityType.SALMON, new BaseEngineEntityManager<BaseConsumableEntity>(entityFactory));
    }

}
