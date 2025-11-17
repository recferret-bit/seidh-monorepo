package game.eventbus;

import engine.eventbus.EventBus;
import engine.eventbus.IEventBus;

/**
 * Singleton EventBus instance for game client-side events
 */
class GameEventBus {
	public static final instance: IEventBus = new EventBus();
}

