package engine.model.entities.character;

import engine.model.entities.types.EntityType;
import engine.model.entities.specs.EngineEntitySpec;

/**
 * Zombie Boy character entity
 */
class ZombieBoyEntity extends BaseCharacterEntity {
    
    public function new() {
        super();
    }
    
    public override function reset(spec: EngineEntitySpec): Void {
        super.reset(spec);
        
        if (spec != null) {
            type = EntityType.ZOMBIE_BOY;
        }
    }
}

