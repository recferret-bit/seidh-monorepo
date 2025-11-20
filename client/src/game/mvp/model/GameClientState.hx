package game.mvp.model;

import engine.domain.types.EntityType;
import engine.presentation.InputMessage;
import game.mvp.model.entities.BaseEntityModel;
import game.mvp.model.entities.CharacterModel;
import game.mvp.model.entities.ColliderModel;

/**
 * Game client state manager
 * Manages all entity models indexed by engine entity ID
 * Provides centralized access to game state
 */
class GameClientState {
    // Single entity storage by ID - source of truth
    private var entities: Map<Int, BaseEntityModel>;

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
    }
    
    /**
     * Remove entity model from state
     */
    public function removeEntity(entityId: Int): Void {
        entities.remove(entityId);
    }
    
    /**
     * Get entity model by ID
     */
    public function getEntity(entityId: Int): BaseEntityModel {
        return entities.get(entityId);
    }
    
    /**
     * Generic helper: Get entity by ID and type, with type-safe casting
     */
    private function getEntityByType<T:BaseEntityModel>(entityId: Int, expectedType: EntityType): Null<T> {
        var entity = entities.get(entityId);
        if (entity != null && entity.type == expectedType) {
            return cast entity;
        }
        return null;
    }
    
    /**
     * Get character model by ID (type-safe)
     */
    public function getRagnar(entityId: Int): Null<CharacterModel> {
        var result: Null<CharacterModel> = getEntityByType(entityId, RAGNAR);
        return result;
    }

    /**
     * Get zombie boy model by ID (type-safe)
     */
    public function getZombieBoy(entityId: Int): Null<CharacterModel> {
        var result: Null<CharacterModel> = getEntityByType(entityId, ZOMBIE_BOY);
        return result;
    }

    /**
     * Get zombie girl model by ID (type-safe)
     */
    public function getZombieGirl(entityId: Int): Null<CharacterModel> {
        var result: Null<CharacterModel> = getEntityByType(entityId, ZOMBIE_GIRL);
        return result;
    }

    /**
     * Get glamr model by ID (type-safe)
     */
    public function getGlamr(entityId: Int): Null<CharacterModel> {
        var result: Null<CharacterModel> = getEntityByType(entityId, GLAMR);
        return result;
    }

    /**
     * Get collider model by ID (type-safe)
     */
    public function getCollider(entityId: Int): Null<ColliderModel> {
        var result: Null<ColliderModel> = getEntityByType(entityId, COLLIDER);
        return result;
    }

    /**
     * Generic helper: Get all entities of a specific type with type-safe casting
     */
    private function getEntitiesByTypeGeneric<T:BaseEntityModel>(type: EntityType): Array<T> {
        final result: Array<T> = [];
        for (entity in entities) {
            if (entity.type == type) {
                result.push(cast entity);
            }
        }
        return result;
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
     * Get all characters (type-safe)
     */
    public function getAllCharacters(): Array<CharacterModel> {
        final result: Array<CharacterModel> = [];
        final characterTypes = [RAGNAR, ZOMBIE_BOY, ZOMBIE_GIRL, GLAMR];
        for (entity in entities) {
            if (characterTypes.indexOf(entity.type) >= 0) {
                result.push(cast entity);
            }
        }
        return result;
    }

    /**
     * Get all colliders (type-safe)
     */
    public function getAllColliders(): Array<ColliderModel> {
        var result: Array<ColliderModel> = getEntitiesByTypeGeneric(COLLIDER);
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
    public function getPlayerControlledEntity(): Null<CharacterModel> {
        if (playerControlledEntityId != null) {
            return getRagnar(playerControlledEntityId);
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
    public function getPendingInputs(): Array<engine.presentation.InputMessage> {
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
