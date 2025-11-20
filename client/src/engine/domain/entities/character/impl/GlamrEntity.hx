package engine.domain.entities.character.impl;

import engine.domain.entities.character.base.BaseCharacterEntity;
import engine.domain.specs.EntitySpec;
import engine.domain.types.EntityType;

/**
 * Glamr character entity
 */
class GlamrEntity extends BaseCharacterEntity {
    
    public function new() {
        super();
    }
    
    public override function reset(spec: EntitySpec): Void {
        super.reset(spec);
        
        if (spec != null) {
            type = EntityType.GLAMR;
        }
    }
}

