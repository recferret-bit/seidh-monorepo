package engine.domain.entities.consumable.base;

import engine.domain.entities.BaseEntity;
import engine.domain.events.EntityDied;
import engine.domain.specs.EntitySpec;

/**
 * Base consumable item entity (potions, food, etc.)
 * All consumable types extend this class
 */
class BaseConsumableEntity extends BaseEntity {
    private var _effectId: String;
    private var _durationTicks: Int;
    private var _stackable: Bool;
    private var _charges: Int;
    private var _useRange: Float;
    public var effectId(get, set): String;
    public var durationTicks(get, set): Int;
    public var stackable(get, set): Bool;
    public var charges(get, set): Int;
    public var useRange(get, set): Float;
    
    public function new() {
        super();
        isInputDriven = false;
        effectId = "";
        durationTicks = 0;
        stackable = false;
        charges = 0;
        useRange = 16.0;
    }
    
    public override function serialize(): Dynamic {
        final base = super.serialize();
        base.effectId = effectId;
        base.durationTicks = durationTicks;
        base.stackable = stackable;
        base.charges = charges;
        base.useRange = useRange;
        return base;
    }
    
    public override function deserialize(data: Dynamic): Void {
        super.deserialize(data);
        effectId = data.effectId;
        durationTicks = data.durationTicks;
        stackable = data.stackable;
        charges = data.charges;
        useRange = data.useRange;
    }
    
    public override function reset(spec: EntitySpec): Void {
        super.reset(spec);
        effectId = spec.effectId != null ? spec.effectId : "";
        durationTicks = spec.durationTicks != null ? spec.durationTicks : 0;
        stackable = spec.stackable != null ? spec.stackable : false;
        charges = spec.charges != null ? spec.charges : 1;
        useRange = spec.useRange != null ? spec.useRange : 16.0;
        isInputDriven = false;
    }

    public function consume(tick: Int): Bool {
        if (!canBeUsed()) {
            return false;
        }
        
        charges--;
        if (charges <= 0) {
            isAlive = false;
            addDomainEvent(new EntityDied(id, 0, tick));
        }
        return true;
    }

    public function canBeUsed(): Bool {
        return isAlive && charges > 0;
    }

    public function addCharges(amount: Int): Void {
        if (amount > 0) {
            charges += amount;
        }
    }

    private function get_effectId(): String {
        return _effectId;
    }

    private function set_effectId(value: String): String {
        _effectId = value != null ? value : "";
        return _effectId;
    }

    private function get_durationTicks(): Int {
        return _durationTicks;
    }

    private function set_durationTicks(value: Int): Int {
        _durationTicks = value;
        return _durationTicks;
    }

    private function get_stackable(): Bool {
        return _stackable;
    }

    private function set_stackable(value: Bool): Bool {
        _stackable = value;
        return _stackable;
    }

    private function get_charges(): Int {
        return _charges;
    }

    private function set_charges(value: Int): Int {
        _charges = value;
        return _charges;
    }

    private function get_useRange(): Float {
        return _useRange;
    }

    private function set_useRange(value: Float): Float {
        _useRange = value;
        return _useRange;
    }
}

