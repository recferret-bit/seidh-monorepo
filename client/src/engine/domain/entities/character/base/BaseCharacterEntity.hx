package engine.domain.entities.character.base;

import engine.domain.entities.BaseEntity;
import engine.domain.entities.character.base.CharacterStats;
import engine.domain.events.DamageDealt;
import engine.domain.events.EntityDied;
import engine.domain.events.EntityMoved;
import engine.domain.specs.EntitySpec;
import engine.domain.valueobjects.Health;
import engine.domain.valueobjects.Position;
import engine.domain.valueobjects.Velocity;

/**
 * Base character entity with combat stats and abilities
 * All character types extend this class
 */
class BaseCharacterEntity extends BaseEntity {
    private var _health: Health;
    private var _level: Int;
    private var _stats: CharacterStats;
    private var _attackDefs: Array<Dynamic>;
    private var _spellBook: Array<Dynamic>;
    private var _aiProfile: String;
    public var health(get, set): Health;
    public var level(get, set): Int;
    public var stats(get, set): CharacterStats;
    public var attackDefs(get, set): Array<Dynamic>;
    public var spellBook(get, set): Array<Dynamic>;
    public var aiProfile(get, set): String;
    
    public function new() {
        super();
        _health = new Health(100, 100);
        level = 1;
        stats = defaultStats();
        attackDefs = [];
        spellBook = [];
        aiProfile = "";
        colliderOffset = new Position(0, 0);
    }
    
    public override function serialize(): Dynamic {
        final base = super.serialize();
        base.maxHp = _health != null ? _health.maximum : 0;
        base.hp = _health != null ? _health.current : 0;
        base.level = level;
        base.stats = stats != null ? {
            power: Std.int(stats.power),
            armor: Std.int(stats.defense),
            speed: Std.int(stats.speed),
            castSpeed: Std.int(stats.castSpeed)
        } : null;
        base.attackDefs = attackDefs;
        base.spellBook = spellBook;
        base.aiProfile = aiProfile;
        return base;
    }
    
    public override function deserialize(data: Dynamic): Void {
        super.deserialize(data);
        final deserializedMaxHp = data.maxHp != null ? data.maxHp : 100;
        final deserializedHp = data.hp != null ? data.hp : deserializedMaxHp;
        _health = new Health(deserializedHp, deserializedMaxHp);
        level = data.level != null ? data.level : 1;
        stats = data.stats != null
            ? new CharacterStats(
                data.stats.power,
                data.stats.armor,
                data.stats.speed,
                data.stats.castSpeed
            )
            : defaultStats();
        attackDefs = data.attackDefs != null ? data.attackDefs : [];
        spellBook = data.spellBook != null ? data.spellBook : [];
        aiProfile = data.aiProfile != null ? data.aiProfile : "";
    }
    
    public override function reset(spec: EntitySpec): Void {
        super.reset(spec);

        if (spec == null) {
            _health = new Health(100, 100);
            level = 1;
            stats = defaultStats();
            attackDefs = [];
            spellBook = [];
            aiProfile = "";
            
            // Character-specific collider dimensions (smaller than default)
            colliderWidth = 3;
            colliderHeight = 5;
            colliderOffset = new Position(0, 0);
            
            // Characters are input-driven by default
            isInputDriven = true;

            return;
        }

        final maxHpValue = spec.maxHp != null ? spec.maxHp : 100;
        final hpValue = spec.hp != null ? spec.hp : maxHpValue;
        _health = new Health(hpValue, maxHpValue);
        level = spec.level != null ? spec.level : 1;
        stats = spec.stats != null
            ? new CharacterStats(
                spec.stats.power,
                spec.stats.armor,
                spec.stats.speed,
                spec.stats.castSpeed
            )
            : defaultStats();
        attackDefs = spec.attackDefs != null ? spec.attackDefs : [];
        spellBook = spec.spellBook != null ? spec.spellBook : [];
        aiProfile = spec.aiProfile != null ? spec.aiProfile : "";
        
        // Character-specific collider dimensions (smaller than default)
        if (spec.colliderWidth == null) colliderWidth = 3;
        if (spec.colliderHeight == null) colliderHeight = 5;
        if (spec.colliderOffset == null) {
            colliderOffset = new Position(0, 0);
        }
        
        // Characters are input-driven by default
        isInputDriven = spec.isInputDriven != null ? spec.isInputDriven : true;
    }

    /**
     * Apply movement step to position
     * @param movementX Movement input X (-1 to 1)
     * @param movementY Movement input Y (-1 to 1)
     * @param dt Delta time
     */
    public function applyMovementStep(movementX: Float, movementY: Float, dt: Float): Void {
        final movementStep = calculateMovementStep(movementX, movementY, dt);
        final correctedX = movementStep.x + movementCorrection.x;
        final correctedY = movementStep.y + movementCorrection.y;

        position = position.add(correctedX, correctedY);
        velocity = new Velocity(0, 0);
        clearMovementCorrection();
    }

    /**
     * Calculate movement step from input
     * @param movementX Movement input X (-1 to 1)
     * @param movementY Movement input Y (-1 to 1)
     * @param dt Delta time
     * @return Movement step as Position delta
     */
    public function calculateMovementStep(movementX: Float, movementY: Float, dt: Float): Position {
        // Use static unitPixels from BaseEntity
        final speed = (stats != null ? stats.speed : 1.0) * BaseEntity.unitPixels;
        return new Position(
            movementX * speed * dt,
            movementY * speed * dt
        );
    }

    public function getColliderDimensions(): {width: Float, height: Float, offset: Position} {
        return {
            width: colliderWidth,
            height: colliderHeight,
            offset: colliderOffset
        };
    }

    public function move(deltaX: Float, deltaY: Float, dt: Float, tick: Int): Void {
        if (!isAlive) return;
        final fromPosition = position.copy();
        final movementStep = calculateMovementStep(deltaX, deltaY, dt);
        position = position.add(movementStep.x, movementStep.y);
        addDomainEvent(new EntityMoved(id, fromPosition, position, tick));
    }

    public function takeDamage(amount: Int, attackerId: Int, tick: Int): Void {
        if (!isAlive || amount <= 0) return;
        final newHealth = _health.reduce(amount);
        _health = newHealth;
        addDomainEvent(new DamageDealt(id, attackerId, amount, _health, tick));

        if (_health.isDead()) {
            isAlive = false;
            addDomainEvent(new EntityDied(id, attackerId, tick));
        }
    }

    public function heal(amount: Int): Void {
        if (!isAlive || amount <= 0) return;
        _health = _health.restore(amount);
    }

    private function get_health(): Health {
        return _health;
    }

    private function set_health(value: Health): Health {
        _health = value != null ? value : new Health(0, 0);
        return _health;
    }

    private function get_level(): Int {
        return _level;
    }

    private function set_level(value: Int): Int {
        _level = value;
        return _level;
    }

    private function get_stats(): CharacterStats {
        return _stats;
    }

    private function set_stats(value: CharacterStats): CharacterStats {
        _stats = value != null ? value : defaultStats();
        return _stats;
    }

    private function get_attackDefs(): Array<Dynamic> {
        return _attackDefs;
    }

    private function set_attackDefs(value: Array<Dynamic>): Array<Dynamic> {
        _attackDefs = value != null ? value : [];
        return _attackDefs;
    }

    private function get_spellBook(): Array<Dynamic> {
        return _spellBook;
    }

    private function set_spellBook(value: Array<Dynamic>): Array<Dynamic> {
        _spellBook = value != null ? value : [];
        return _spellBook;
    }

    private function get_aiProfile(): String {
        return _aiProfile;
    }

    private function set_aiProfile(value: String): String {
        _aiProfile = value != null ? value : "";
        return _aiProfile;
    }

    private inline function defaultStats(): CharacterStats {
        return new CharacterStats(1.0, 1.0, 1.0, 1.0);
    }
}

