package game.eventbus;

import engine.infrastructure.eventbus.EventBus;
import engine.infrastructure.eventbus.IEventBus;

/**
 * Singleton EventBus instance for game client-side events
 */
class GameEventBus {
	public static final instance: IEventBus = new EventBus();
}

