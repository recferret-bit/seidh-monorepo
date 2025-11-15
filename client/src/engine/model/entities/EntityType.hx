package engine.model.entities;

/**
 * Entity type definitions as abstract string enum
 */
enum abstract EntityType(String) from String to String {
    var RAGNAR = "ragnar";
    var ZOMBIE_BOY = "zombie_boy";
    var ZOMBIE_GIRL = "zombie_girl";
    var GLAMR = "glamr";
    var COLLIDER = "collider";
    var GENERIC = "generic";
}
