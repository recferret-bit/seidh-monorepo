package game.event;

interface EventListener {
	function notify(event:String, params:Dynamic):Void;
}

class EventManager {

	// Networking events

	// Internal events
	public static final EVENT_LOAD_HOME_SCENE = 'EVENT_LOAD_HOME_SCENE';
	public static final EVENT_LOAD_GAME_SCENE = 'EVENT_LOAD_GAME_SCENE';

	// Animation events
	public static final EVENT_CHARACTER_ANIM_END = 'EVENT_CHARACTER_ANIM_END';
	public static final EVENT_CHARACTER_DEATH_ANIM_END = 'EVENT_CHARACTER_DEATH_ANIM_END';

	private final listeners = new Map<String, List<EventListener>>();

	public static final instance:EventManager = new EventManager();

	private function new() {}

	public function subscribe(eventType:String, listener:EventListener) {
		if (listeners.exists(eventType)) {
			final listenersList = listeners.get(eventType);
			listenersList.add(listener);
		} else {
			final newList = new List();
			newList.add(listener);
			listeners.set(eventType, newList);
		}
	}

	public function unsubscribe(eventType:String, listener:EventListener) {
		final listenersList = listeners.get(eventType);
		if (listenersList == null) {
			return;
		}
		listenersList.remove(listener);
	}

	public function notify(eventType:String, params:Dynamic) {
		final ls = listeners.get(eventType);
		if (ls == null) {
			return;
		}
		for (listener in ls) {
			listener.notify(eventType, params);
		}
	}
}
