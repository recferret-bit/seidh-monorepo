package engine.domain.valueobjects;

/**
 * Immutable value object for health
 */
class Health {
    public final current: Int;
    public final maximum: Int;
    
    public function new(current: Int, maximum: Int) {
        this.current = current < 0 ? 0 : (current > maximum ? maximum : current);
        this.maximum = maximum < 0 ? 0 : maximum;
    }
    
    /**
     * Reduce health by amount, returning new Health
     */
    public function reduce(amount: Int): Health {
        if (amount <= 0) return this;
        return new Health(current - amount, maximum);
    }
    
    /**
     * Restore health by amount, returning new Health
     */
    public function restore(amount: Int): Health {
        if (amount <= 0) return this;
        return new Health(current + amount, maximum);
    }
    
    /**
     * Set health to specific value, returning new Health
     */
    public function set(value: Int): Health {
        return new Health(value, maximum);
    }
    
    /**
     * Check if health is at zero (dead)
     */
    public function isDead(): Bool {
        return current <= 0;
    }
    
    /**
     * Check if health is at maximum
     */
    public function isFull(): Bool {
        return current >= maximum;
    }
    
    /**
     * Get health as percentage (0.0 to 1.0)
     */
    public function percentage(): Float {
        if (maximum == 0) return 0.0;
        return current / maximum;
    }
    
    /**
     * Check if two health values are equal
     */
    public function equals(other: Health): Bool {
        return current == other.current && maximum == other.maximum;
    }
    
    /**
     * Create a copy of this health
     */
    public function copy(): Health {
        return new Health(current, maximum);
    }
}

