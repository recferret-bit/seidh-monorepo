package engine.model;

import engine.model.DeterministicRng;
import engine.model.ObjectPool;
import engine.model.entities.EntityType;
import engine.model.entities.base.EngineEntityFactory;
import engine.model.entities.impl.EngineCharacterEntity;
import engine.model.entities.impl.EngineColliderEntity;
import engine.model.entities.impl.EngineConsumableEntity;
import engine.model.entities.impl.EngineEffectEntity;
import engine.model.managers.BaseEngineEntityManager;
import engine.model.managers.EngineEntityManagerRegistry;
import engine.model.managers.IEngineEntityManager;
import engine.model.managers.IEngineEntityManagerRegistry;

// Memento type definitions for snapshot system
typedef EngineEntityMemento = {
    id: Int,
    type: EntityType,
    pos: {x: Int, y: Int},
    vel: {x: Int, y: Int},
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
     * Get ragnar manager with explicit type
     * @return Ragnar entity manager
     */
    public function getRagnarManager(): IEngineEntityManager<EngineCharacterEntity> {
        return managers.get(EntityType.RAGNAR);
    }
    
    /**
     * Get zombie boy manager with explicit type
     * @return Zombie boy entity manager
     */
    public function getZombieBoyManager(): IEngineEntityManager<EngineCharacterEntity> {
        return managers.get(EntityType.ZOMBIE_BOY);
    }
    
    /**
     * Get zombie girl manager with explicit type
     * @return Zombie girl entity manager
     */
    public function getZombieGirlManager(): IEngineEntityManager<EngineCharacterEntity> {
        return managers.get(EntityType.ZOMBIE_GIRL);
    }

    /**
     * Get glamr manager with explicit type
     * @return Glamr entity manager
     */
    public function getGlamrManager(): IEngineEntityManager<EngineCharacterEntity> {
        return managers.get(EntityType.GLAMR);
    }
    
    /**
     * Get collider manager with explicit type
     * @return Collider entity manager
     */
    public function getColliderManager(): IEngineEntityManager<EngineColliderEntity> {
        return managers.get(EntityType.COLLIDER);
    }
    
    private function setupManagers(): Void {
        // Register core entity managers
        managers.register(EntityType.RAGNAR, new BaseEngineEntityManager<EngineCharacterEntity>(entityFactory));
        managers.register(EntityType.ZOMBIE_BOY, new BaseEngineEntityManager<EngineCharacterEntity>(entityFactory));
        managers.register(EntityType.ZOMBIE_GIRL, new BaseEngineEntityManager<EngineCharacterEntity>(entityFactory));
        managers.register(EntityType.GLAMR, new BaseEngineEntityManager<EngineCharacterEntity>(entityFactory));
        managers.register(EntityType.COLLIDER, new BaseEngineEntityManager<EngineColliderEntity>(entityFactory));
    }

}
