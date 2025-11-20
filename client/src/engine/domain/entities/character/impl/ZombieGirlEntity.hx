package engine.domain.entities.character.impl;

import engine.domain.entities.character.base.BaseCharacterEntity;
import engine.domain.specs.EntitySpec;
import engine.domain.types.EntityType;

/**
 * Zombie Girl character entity
 */
class ZombieGirlEntity extends BaseCharacterEntity {
    
    public function new() {
        super();
    }
    
    public override function reset(spec: EntitySpec): Void {
        super.reset(spec);
        
        if (spec != null) {
            type = EntityType.ZOMBIE_GIRL;
        }
    }
}

