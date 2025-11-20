package engine.domain.specs;

import engine.domain.entities.character.base.CharacterStats;

/**
 * Character entity specification
 * Extends base spec with character-specific fields
 * Used for creating character entities (Ragnar, ZombieBoy, ZombieGirl, Glamr)
 */
typedef CharacterSpec = EntitySpec & {
    // Character attributes
    ?maxHp: Int,
    ?hp: Int,
    ?level: Int,
    ?stats: CharacterStats,
    ?attackDefs: Array<Dynamic>,  // TODO: type this properly with AttackDef
    ?spellBook: Array<Dynamic>,   // TODO: type this properly with SpellDef
    ?aiProfile: String,
    ?isInputDriven: Bool
}
