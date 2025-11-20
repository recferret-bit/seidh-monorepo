package engine.domain.entities.character.base;

/**
 * Character stats value object
 */
class CharacterStats {
    public final power: Float;
    public final defense: Float;
    public final speed: Float;
    public final castSpeed: Float;
    
    public function new(power: Float, defense: Float, speed: Float, castSpeed: Float) {
        this.power = power;
        this.defense = defense;
        this.speed = speed;
        this.castSpeed = castSpeed;
    }
}
