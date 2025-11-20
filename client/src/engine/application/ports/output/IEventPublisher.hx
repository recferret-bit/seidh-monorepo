package engine.application.ports.output;

/**
 * Port for publishing domain events
 * Infrastructure layer will implement this interface
 */
interface IEventPublisher {
    /**
     * Publish a domain event
     * @param event Domain event to publish
     */
    function publish(event: Dynamic): Void;
}

