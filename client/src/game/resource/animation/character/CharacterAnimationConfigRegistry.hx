package game.resource.animation.character;

import engine.domain.types.EntityType;
import game.resource.Res.SeidhResource;
import game.resource.animation.character.BasicCharacterAnimation.AnimationConfig;

/**
 * Registry that maps EntityType to animation resource configurations.
 * Centralizes all character animation resource mappings.
 */
class CharacterAnimationConfigRegistry {
    
    /**
     * Get animation resource configuration for a given entity type and animation state.
     * Returns null if the animation is not available for that entity type.
     */
    public static function getConfig(entityType:EntityType, configType:AnimationConfigType):Null<AnimationConfig> {
        final resources = getResourcesForEntityType(entityType);
        if (resources == null) {
            return null;
        }
        
        final resource = resources.get(configType);
        if (resource == null) {
            return null;
        }
        
        // Get default offsets and speed based on entity type
        final offsets = getOffsetsForEntityType(entityType, configType);
        final speed = getSpeedForEntityType(entityType, configType);
        
        final tileSet = Res.instance.getTileResource(resource);
        if (tileSet == null) {
            return null;
        }
        
        return {
            tileSet: tileSet,
            dxOffset: offsets.dx,
            dyOffset: offsets.dy,
            speed: speed
        };
    }
    
    /**
     * Get all resource mappings for an entity type
     */
    private static function getResourcesForEntityType(entityType:EntityType):Null<Map<AnimationConfigType, Null<SeidhResource>>> {
        final map = new Map<AnimationConfigType, Null<SeidhResource>>();
        
        switch (entityType) {
            case EntityType.RAGNAR:
                map.set(IDLE, SeidhResource.RAGNAR_IDLE);
                map.set(RUN, SeidhResource.RAGNAR_RUN);
                map.set(ATTACK, SeidhResource.RAGNAR_ATTACK);
                map.set(DEATH, SeidhResource.RAGNAR_DEATH);
                map.set(SPAWN, null); // Ragnar doesn't have spawn animation
                map.set(ACTION_SPECIAL, null); // Ragnar doesn't have special action
            case EntityType.ZOMBIE_BOY:
                map.set(IDLE, SeidhResource.ZOMBIE_BOY_IDLE);
                map.set(RUN, SeidhResource.ZOMBIE_BOY_RUN);
                map.set(ATTACK, SeidhResource.ZOMBIE_BOY_ATTACK);
                map.set(DEATH, SeidhResource.ZOMBIE_BOY_DEATH);
                map.set(SPAWN, SeidhResource.ZOMBIE_BOY_SPAWN);
                map.set(ACTION_SPECIAL, null);
            case EntityType.ZOMBIE_GIRL:
                map.set(IDLE, SeidhResource.ZOMBIE_GIRL_IDLE);
                map.set(RUN, SeidhResource.ZOMBIE_GIRL_RUN);
                map.set(ATTACK, SeidhResource.ZOMBIE_GIRL_ATTACK);
                map.set(DEATH, SeidhResource.ZOMBIE_GIRL_DEATH);
                map.set(SPAWN, SeidhResource.ZOMBIE_GIRL_SPAWN);
                map.set(ACTION_SPECIAL, null);
            case EntityType.GLAMR:
                map.set(IDLE, SeidhResource.GLAMR_IDLE);
                map.set(RUN, SeidhResource.GLAMR_RUN);
                map.set(ATTACK, SeidhResource.GLAMR_ATTACK);
                map.set(DEATH, SeidhResource.GLAMR_DEATH);
                map.set(SPAWN, SeidhResource.GLAMR_SPAWN);
                map.set(ACTION_SPECIAL, SeidhResource.GLAMR_HAIL);
            default:
                return null;
        }
        
        return map;
    }
    
    /**
     * Get offsets for a specific entity type and animation config type
     */
    private static function getOffsetsForEntityType(entityType:EntityType, configType:AnimationConfigType):{dx:Null<Int>, dy:Null<Int>} {
        // Ragnar has a special offset for idle animation
        if (entityType == EntityType.RAGNAR && configType == IDLE) {
            return {dx: 30, dy: null};
        }
        return {dx: null, dy: null};
    }
    
    /**
     * Get animation speed for a specific entity type and animation config type
     */
    private static function getSpeedForEntityType(entityType:EntityType, configType:AnimationConfigType):Int {
        // Default speed is 10 for all animations
        return 10;
    }
}

/**
 * Animation configuration type enum
 */
enum abstract AnimationConfigType(String) {
    var IDLE = "idle";
    var RUN = "run";
    var ATTACK = "attack";
    var DEATH = "death";
    var SPAWN = "spawn";
    var ACTION_SPECIAL = "action_special";
}

