package engine.model.entities.consumable;

import engine.model.entities.types.EntityType;
import engine.model.entities.types.EngineEntitySpec;

/**
 * Salmon consumable entity
 */
class SalmonEntity extends BaseConsumableEntity {
    
    public function new() {
        super();
    }
    
    public override function reset(spec: EngineEntitySpec): Void {
        super.reset(spec);
        
        if (spec != null) {
            type = EntityType.SALMON;
        }
    }
}

