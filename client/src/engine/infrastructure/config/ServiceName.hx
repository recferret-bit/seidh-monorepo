package engine.infrastructure.config;

/**
 * Service name definitions as abstract string enum
 */
enum abstract ServiceName(String) from String to String {
    var INPUT = "input";
    var PHYSICS = "physics";
    var AI = "ai";
    var SPAWN = "spawn";
}

