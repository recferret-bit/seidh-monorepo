package engine.infrastructure.adapters.persistence;

import engine.domain.repositories.ICharacterRepository;
import engine.domain.repositories.IEntityRepository;
import engine.domain.entities.character.base.BaseCharacterEntity;

/**
 * Character-specific repository that wraps the generic entity repository
 */
class CharacterRepository implements ICharacterRepository {
    private final entityRepository: IEntityRepository;
    
    public function new(entityRepository: IEntityRepository) {
        this.entityRepository = entityRepository;
    }
    
    public function findById(id: Int): BaseCharacterEntity {
        final entity = entityRepository.findById(id);
        return Std.isOfType(entity, BaseCharacterEntity) ? cast entity : null;
    }
    
    public function findAll(): Array<BaseCharacterEntity> {
        final result: Array<BaseCharacterEntity> = [];
        final allEntities = entityRepository.findAll();
        for (entity in allEntities) {
            final character = cast(entity, BaseCharacterEntity);
            if (character != null) {
                result.push(character);
            }
        }
        return result;
    }
    
    public function save(entity: BaseCharacterEntity): Void {
        entityRepository.save(entity);
    }
    
    public function delete(id: Int): Void {
        entityRepository.delete(id);
    }
    
    public function exists(id: Int): Bool {
        return findById(id) != null;
    }
}

