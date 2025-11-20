package engine.domain.repositories;

import engine.domain.entities.character.base.BaseCharacterEntity;

/**
 * Repository contract for character aggregates
 */
interface ICharacterRepository {
    function findById(id: Int): BaseCharacterEntity;
    function findAll(): Array<BaseCharacterEntity>;
    function save(entity: BaseCharacterEntity): Void;
    function delete(id: Int): Void;
    function exists(id: Int): Bool;
}

