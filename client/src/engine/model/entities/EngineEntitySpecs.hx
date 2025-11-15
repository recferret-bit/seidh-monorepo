package engine.model.entities;

import engine.model.entities.EntityType;
import engine.model.entities.base.EngineEntitySpec;

/**
 * EntitySpecs - Entity specification seed data for the engine
 * Provides standardized entity specifications for different types
 * Migrated and enhanced from AcolyteSpecs.hx
 */
class EngineEntitySpecs {
    
    /**
     * Get player character spec
     */
    public static function getRagnarSpec(): EngineEntitySpec {
        return {
            type: EntityType.RAGNAR,
            pos: {x: 100, y: 100},
            ownerId: "player1",
            level: 1,
            maxHp: 100,
            hp: 100,
            stats: {
                speed: 8,
                power: 25,
                armor: 15,
                castSpeed: 1
            },
            attackDefs: [],
            spellBook: [],
            aiProfile: "player"
        };
    }

    public static function getZombieBoySpec(): EngineEntitySpec {
        return {
            type: EntityType.ZOMBIE_BOY,
            pos: {x: 100, y: 100},
            ownerId: "player1",
            level: 1,
            maxHp: 100,
            hp: 100,
        };
    }

    public static function getZombieGirlSpec(): EngineEntitySpec {
        return {
            type: EntityType.ZOMBIE_GIRL,
            pos: {x: 100, y: 100},
            ownerId: "player1",
            level: 1,
            maxHp: 100,
            hp: 100,
        };
    }

    public static function getGlamrSpec(): EngineEntitySpec {
        return {
            type: EntityType.GLAMR,
            pos: {x: 100, y: 100},
            ownerId: "player1",
            level: 1,
            maxHp: 100,
            hp: 100,
        };
    }
    /**
     * Get spawn positions for different entity types
     */
    public static function getSpawnPositions(): {
        player: Array<{x: Int, y: Int}>,
        acolytes: Array<{x: Int, y: Int}>,
        monsters: Array<{x: Int, y: Int}>,
        consumables: Array<{x: Int, y: Int}>,
        effects: Array<{x: Int, y: Int}>
    } {
        return {
            player: [
                { x: 100, y: 100 }
            ],
            acolytes: [
                { x: 150, y: 100 },
                { x: 120, y: 150 }
            ],
            monsters: [
                { x: 200, y: 200 },
                { x: 300, y: 150 },
                { x: 250, y: 300 },
                { x: 180, y: 250 },
                { x: 320, y: 280 }
            ],
            consumables: [
                { x: 250, y: 150 },
                { x: 300, y: 150 },
                { x: 350, y: 200 }
            ],
            effects: [
                { x: 200, y: 100 },
                { x: 250, y: 200 }
            ]
        };
    }
    
    /**
     * Get collider spec
     */
    public static function getColliderSpec(x: Int, y: Int, passable: Bool, isTrigger: Bool): EngineEntitySpec {
        return {
            type: EntityType.COLLIDER,
            pos: {x: x, y: y},
            ownerId: "world",
            isAlive: true,  // explicitly set colliders as alive
            passable: passable,
            isTrigger: isTrigger,
            colliderWidth: 2,  // reasonable size for collision
            colliderHeight: 2  // reasonable size for collision
        };
    }
    
    /**
     * Generate map colliders in chess pattern
     * @param rows Number of rows
     * @param cols Number of columns
     * @return Array of collider specs
     */
    public static function generateMapColliders(rows: Int, cols: Int): Array<EngineEntitySpec> {
        final colliders = [];
        final spacing = 10 * SeidhEngine.Config.unitPixels; // 10 units between each collider
        
        for (row in 1...rows + 1) {
            for (col in 1...cols + 1) {
                final x = col * spacing;
                final y = row * spacing;
                
                // Chess pattern: alternate passable/impassable
                // final passable = (row + col) % 2 == 0;
                final passable = false;
                final isTrigger = false; // No triggers in basic map
                
                colliders.push(getColliderSpec(x, y, passable, isTrigger));
            }
        }
        
        return colliders;
    }
    
    /**
     * Get entity spec by type and index
     */
    public static function getDefaultEntitySpec(type: EntityType): EngineEntitySpec {
        switch (type) {
            case EntityType.RAGNAR:
                return getRagnarSpec();
            case EntityType.ZOMBIE_BOY:
                return getZombieBoySpec();
            case EntityType.ZOMBIE_GIRL:
                return getZombieGirlSpec();
            case EntityType.GLAMR:
                return getGlamrSpec();
            case COLLIDER:
                return getColliderSpec(0, 0, false, false);
            default:
                return getColliderSpec(0, 0, false, false);
        }
    }
}
