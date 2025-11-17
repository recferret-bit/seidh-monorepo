package engine.model.entities.character;

import engine.model.entities.types.EntityType;
import engine.model.entities.specs.EngineEntitySpec;

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
        colliderOffset = new engine.geometry.Vec2(-20, 20);
    }
}

