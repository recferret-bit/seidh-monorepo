package engine.modules;

/**
 * Module name definitions as abstract string enum
 */
enum abstract ModuleName(String) from String to String {
    var INPUT = "input";
    var PHYSICS = "physics";
    var AI = "ai";
    var SPAWN = "spawn";
}

