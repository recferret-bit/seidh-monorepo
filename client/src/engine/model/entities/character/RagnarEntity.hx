package engine.model.entities.character;

import engine.model.entities.types.EntityType;
import engine.model.entities.types.EngineEntitySpec;

/**
 * Ragnar character entity
 */
class RagnarEntity extends BaseCharacterEntity {
    
    public function new() {
        super();
    }
    
    public override function reset(spec: EngineEntitySpec): Void {
        super.reset(spec);
        
        if (spec != null) {
            type = EntityType.RAGNAR;
        }

        colliderWidth = 4;
        colliderHeight = 6;
        colliderPxOffsetX = -20;
        colliderPxOffsetY = 20;
    }
}

