package game.eventbus;

import engine.infrastructure.adapters.events.EventBus;
import engine.infrastructure.adapters.events.IEventBus;

/**
 * Singleton EventBus instance for game client-side events
 */
class GameEventBus {
	public static final instance: IEventBus = new EventBus();
}

