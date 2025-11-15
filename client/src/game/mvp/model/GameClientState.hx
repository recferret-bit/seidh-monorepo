package game.mvp.model;

import engine.model.entities.EntityType;
import engine.presenter.InputMessage;
import game.mvp.model.entities.BaseEntityModel;
import game.mvp.model.entities.CharacterModel;
import game.mvp.model.entities.ColliderModel;

/**
 * Game client state manager
 * Manages all entity models indexed by engine entity ID
 * Provides centralized access to game state
 */
class GameClientState {
    // Entity storage by ID
    private var entities: Map<Int, BaseEntityModel>;
    
    // Typed entity collections for quick access
    private var ragnars: Map<Int, CharacterModel>;
    private var zombieBoys: Map<Int, CharacterModel>;
    private var zombieGirls: Map<Int, CharacterModel>;
    private var glamrs: Map<Int, CharacterModel>;
    private var colliders: Map<Int, ColliderModel>;

    // State tracking
    private var nextLocalId: Int;
    private var lastUpdateTick: Int;
    private var playerControlledEntityId: Null<Int>;
    
    // Client prediction tracking
    private var pendingInputs: Array<InputMessage>;
    private var predictionHistory: Array<Dynamic>;
    private var maxPredictionHistory: Int;
    private var lastAcknowledgedSequence: Int;
    
    public function new() {
        entities = new Map<Int, BaseEntityModel>();
        ragnars = new Map<Int, CharacterModel>();
        zombieBoys = new Map<Int, CharacterModel>();
        zombieGirls = new Map<Int, CharacterModel>();
        glamrs = new Map<Int, CharacterModel>();
        colliders = new Map<Int, ColliderModel>();

        nextLocalId = 1;
        lastUpdateTick = 0;
        
        // Initialize prediction tracking
        pendingInputs = [];
        predictionHistory = [];
        maxPredictionHistory = 50;
        lastAcknowledgedSequence = -1;
    }
    
    /**
     * Add entity model to state
     */
    public function addEntity(model: BaseEntityModel): Void {
        entities.set(model.engineEntity.id, model);
        
        // Add to typed collection
        switch (model.type) {
            case RAGNAR:
                ragnars.set(model.engineEntity.id, cast model);
            case ZOMBIE_BOY:
                zombieBoys.set(model.engineEntity.id, cast model);
            case ZOMBIE_GIRL:
                zombieGirls.set(model.engineEntity.id, cast model);
            case GLAMR:
                glamrs.set(model.engineEntity.id, cast model);
            case COLLIDER:
                colliders.set(model.engineEntity.id, cast model);
            default:
                trace("addEntity: unknown entity type: " + model.type);
                // Handle unknown types if needed
        }
    }
    
    /**
     * Remove entity model from state
     */
    public function removeEntity(entityId: Int): Void {
        var model = entities.get(entityId);
        if (model != null) {
            // Remove from typed collection
            switch (model.type) {
                case RAGNAR:
                    ragnars.remove(entityId);
                case ZOMBIE_BOY:
                    zombieBoys.remove(entityId);
                case ZOMBIE_GIRL:
                    zombieGirls.remove(entityId);
                case GLAMR:
                    glamrs.remove(entityId);
                case COLLIDER:
                    colliders.remove(entityId);
                default:
                    trace("removeEntity: unknown entity type: " + model.type);
                    // Handle unknown types if needed
            }
            
            entities.remove(entityId);
        }
    }
    
    /**
     * Get entity model by ID
     */
    public function getEntity(entityId: Int): BaseEntityModel {
        return entities.get(entityId);
    }
    
    /**
     * Get character model by ID
     */
    public function getRagnar(entityId: Int): CharacterModel {
        return ragnars.get(entityId);
    }
    

    /**
     * Get zombie boy model by ID
     */
    public function getZombieBoy(entityId: Int): CharacterModel {
        return zombieBoys.get(entityId);
    }
    
    /**
     * Get zombie girl model by ID
     */
    public function getZombieGirl(entityId: Int): CharacterModel {
        return zombieGirls.get(entityId);
    }

    /**
     * Get glamr model by ID
     */
    public function getGlamr(entityId: Int): CharacterModel {
        return glamrs.get(entityId);
    }


    /**
     * Get collider model by ID
     */
    public function getCollider(entityId: Int): ColliderModel {
        return colliders.get(entityId);
    }

    /**
     * Get all entities of a specific type
     */
    public function getEntitiesByType(type: EntityType): Array<BaseEntityModel> {
        final result = [];
        for (entity in entities) {
            if (entity.type == type) {
                result.push(entity);
            }
        }
        return result;
    }
    
    /**
     * Get all characters
     */
    public function getAllCharacters(): Array<CharacterModel> {
        final result = [];
        for (ragnar in ragnars) {
            result.push(ragnar);
        }
        for (zombieBoy in zombieBoys) {
            result.push(zombieBoy);
        }
        for (zombieGirl in zombieGirls) {
            result.push(zombieGirl);
        }
        for (glamr in glamrs) {
            result.push(glamr);
        }
        return result;
    }

    /**
     * Get all colliders
     */
    public function getAllColliders(): Array<ColliderModel> {
        final result = [];
        for (collider in colliders) {
            result.push(collider);
        }
        return result;
    }

    /**
     * Get all alive entities
     */
    public function getAliveEntities(): Array<BaseEntityModel> {
        var result = [];
        for (entity in entities) {
            if (entity.isAlive) {
                result.push(entity);
            }
        }
        return result;
    }
    
    /**
     * Get entities by owner ID
     */
    public function getEntitiesByOwner(ownerId: String): Array<BaseEntityModel> {
        var result = [];
        for (entity in entities) {
            if (entity.ownerId == ownerId) {
                result.push(entity);
            }
        }
        return result;
    }
    
    /**
     * Get player character (ownerId = "playerControlledEntityId")
     */
    // public function getPlayerCharacter(): CharacterModel {
    //     for (ragnar in ragnars) {
    //         if (ragnar.ownerId == playerControlledEntityId) {
    //             return ragnar;
    //         }
    //     }
    //     return null;
    // }
    
    /**
     * Set player controlled entity ID
     */
    public function setPlayerControlledEntity(entityId: Int): Void {
        playerControlledEntityId = entityId;
    }
    
    /**
     * Get player controlled entity
     */
    public function getPlayerControlledEntity(): CharacterModel {
        if (playerControlledEntityId != null) {
            return ragnars.get(playerControlledEntityId);
        }
        return null;
    }
    
    /**
     * Update all entities
     */
    public function update(dt: Float, currentTick: Int): Void {
        lastUpdateTick = currentTick;
        
        // Update all models from engine entities
        for (entity in entities) {
            if (entity.isAlive) {
                entity.updateFromEngine();
            }
        }
        
        // Update consumables (they have animations)
        // for (consumable in consumables) {
        //     if (consumable.isAlive) {
        //         consumable.update(dt);
        //     }
        // }
        
        // Update effects (they have animations and duration)
        // for (effect in effects) {
        //     if (effect.isAlive) {
        //         effect.update(dt);
        //         if (effect.isExpired()) {
        //             // Mark effect as dead through engine entity
        //             if (effect.effectEntity != null) {
        //                 effect.effectEntity.isAlive = false;
        //             }
        //         }
        //     }
        // }
    }
    
    /**
     * Clean up dead entities
     */
    public function cleanupDeadEntities(): Void {
        var toRemove = [];
        
        for (entityId in entities.keys()) {
            var entity = entities.get(entityId);
            if (!entity.isAlive) {
                toRemove.push(entityId);
            }
        }
        
        for (entityId in toRemove) {
            removeEntity(entityId);
        }
    }
    
    /**
     * Get entity count by type
     */
    public function getEntityCount(type: EntityType): Int {
        return getEntitiesByType(type).length;
    }
    
    /**
     * Get total entity count
     */
    public function getTotalEntityCount(): Int {
        var count = 0;
        for (entity in entities) {
            count++;
        }
        return count;
    }
    
    /**
     * Clear all entities
     */
    public function clear(): Void {
        entities.clear();
        ragnars.clear();
        zombieBoys.clear();
        zombieGirls.clear();
        glamrs.clear();
        colliders.clear();

        nextLocalId = 1;
        playerControlledEntityId = null;
        
        // Clear prediction state
        pendingInputs = [];
        predictionHistory = [];
        lastAcknowledgedSequence = -1;
    }
    
    /**
     * Add pending input for prediction tracking
     */
    public function addPendingInput(input: InputMessage): Void {
        pendingInputs.push(input);
    }
    
    /**
     * Get pending inputs
     */
    public function getPendingInputs(): Array<engine.presenter.InputMessage> {
        return cast pendingInputs.copy();
    }
    
    /**
     * Clear acknowledged inputs
     */
    public function clearAcknowledgedInputs(sequence: Int): Void {
        lastAcknowledgedSequence = sequence;
        pendingInputs = pendingInputs.filter(function(input: InputMessage) {
            return input.sequence > sequence;
        });
    }
    
    /**
     * Add prediction to history
     */
    public function addPrediction(prediction: Dynamic): Void {
        predictionHistory.push(prediction);
        
        // Limit history size
        if (predictionHistory.length > maxPredictionHistory) {
            predictionHistory.shift();
        }
    }
    
    /**
     * Get prediction history
     */
    public function getPredictionHistory(): Array<Dynamic> {
        return predictionHistory.copy();
    }
    
    /**
     * Clear prediction history
     */
    public function clearPredictionHistory(): Void {
        predictionHistory = [];
    }
    
    /**
     * Get state summary for debugging
     */
    // TODO do not use Dynamic
    public function getStateSummary(): Dynamic {
        return {
            totalEntities: getTotalEntityCount(),
            ragnars: getEntityCount(RAGNAR),
            zombieBoys: getEntityCount(ZOMBIE_BOY),
            zombieGirls: getEntityCount(ZOMBIE_GIRL),
            glamrs: getEntityCount(GLAMR),
            aliveEntities: getAliveEntities().length,
            lastUpdateTick: lastUpdateTick,
            pendingInputs: pendingInputs.length,
            predictionHistory: predictionHistory.length,
            lastAcknowledgedSequence: lastAcknowledgedSequence
        };
    }
    
    /**
     * Serialize state for debugging
     */
    public function serialize(): Dynamic {
        var serializedEntities = [];
        for (entity in entities) {
            if (entity.engineEntity != null) {
                serializedEntities.push(entity.engineEntity.serialize());
            }
        }
        
        return {
            entities: serializedEntities,
            nextLocalId: nextLocalId,
            lastUpdateTick: lastUpdateTick
        };
    }
    
    /**
     * Deserialize state
     */
    // TODO do not use Dynamic
    public function deserialize(data: Dynamic): Void {
        clear();
        
        if (data.entities != null) {
            var entitiesArray: Array<Dynamic> = cast data.entities;
            for (entityData in entitiesArray) {
                var model = createModelFromData(entityData);
                if (model != null) {
                    addEntity( model);
                }
            }
        }
        
        nextLocalId = data.nextLocalId;
        lastUpdateTick = data.lastUpdateTick;
    }
    
    /**
     * Create model from serialized data
     */
    // TODO do not use Dynamic
    private function createModelFromData(data: Dynamic): BaseEntityModel {
        var model: BaseEntityModel = null;
        
        // switch (data.type) {
        //     case CHARACTER:
        //         model = new CharacterModel();
        //     case COLLIDER:
        //         model = new ColliderModel();
        //     case CONSUMABLE:
        //         model = new ConsumableModel();
        //     case EFFECT:
        //         model = new EffectModel();
        //     default:
        //         return null;
        // }
        
        if (model.engineEntity != null) {
            model.engineEntity.deserialize(data);
        }

        return model;
    }
}
