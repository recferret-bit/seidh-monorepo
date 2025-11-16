package engine.model.entities.types;

/**
 * Entity state definitions as abstract string enum
 */
enum abstract EntityState(String) from String to String {
    var IDLE = "idle";
    var RUN = "run";
    var DEATH = "death";
    var SPAWN = "spawn";
    var ACTION_MAIN = "action_main";
    var ACTION_SPECIAL = "action_special";
}

