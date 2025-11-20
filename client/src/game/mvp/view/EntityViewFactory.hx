package game.mvp.view;

import engine.domain.types.EntityType;
import game.mvp.view.entities.BaseGameEntityView;
import game.mvp.view.entities.character.glamr.GlamrEntityView;
import game.mvp.view.entities.character.ragnar.RagnarEntityView;
import game.mvp.view.entities.character.zombie_boy.ZombieBoyEntityView;
import game.mvp.view.entities.character.zombie_girl.ZombieGirlEntityView;
import game.mvp.view.entities.collider.ColliderEntityView;

/**
 * Centralized factory for creating entity views
 * Handles all view creation logic based on entity type
 */
class EntityViewFactory {
    /**
     * Create a new entity view for the given entity type
     * @param type The entity type to create a view for
     * @return A new entity view instance, or null if type is not supported
     */
    public static function create(type: EntityType): BaseGameEntityView {
        final view = switch (type) {
            case EntityType.RAGNAR:
                new RagnarEntityView();
            case EntityType.ZOMBIE_BOY:
                new ZombieBoyEntityView();
            case EntityType.ZOMBIE_GIRL:
                new ZombieGirlEntityView();
            case EntityType.GLAMR:
                new GlamrEntityView();
            case EntityType.COLLIDER:
                new ColliderEntityView();
            default:
                // Default fallback for unknown types
                new RagnarEntityView();
        };
        
        // Set pool type for object pooling support
        view.setPoolType(type);
        
        return view;
    }
    
    /**
     * Check if a factory exists for the given entity type
     * @param type The entity type to check
     * @return True if the type is supported, false otherwise
     */
    public static function isSupported(type: EntityType): Bool {
        return switch (type) {
            case EntityType.RAGNAR | EntityType.ZOMBIE_BOY | EntityType.ZOMBIE_GIRL | 
                 EntityType.GLAMR | EntityType.COLLIDER:
                true;
            default:
                false;
        };
    }
}

