package engine.model.entities.types;

/**
 * Entity direction definitions as abstract string enum
 */
enum abstract EntityDirection(String) from String to String {
    var LEFT = "left";
    var RIGHT = "right";
    var UP = "up";
    var DOWN = "down";
}

