package engine.infrastructure.logging;

/**
 * Minimal logger with configurable debug output.
 */
class Logger {
    private static var debugEnabled: Bool = false;

    public static function configure(enableDebug: Bool): Void {
        debugEnabled = enableDebug;
    }

    public static function debug(message: String): Void {
        if (debugEnabled) {
            trace(message);
        }
    }

    public static function warn(message: String): Void {
        trace('[WARN] ' + message);
    }
}

