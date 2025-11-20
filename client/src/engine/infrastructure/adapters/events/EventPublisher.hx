package engine.infrastructure.adapters.events;

import engine.application.ports.output.IEventPublisher;
import engine.infrastructure.adapters.events.IEventBus;
import engine.domain.events.EntitySpawned;
import engine.domain.events.EntityMoved;
import engine.domain.events.EntityDied;
import engine.domain.events.DamageDealt;
import engine.infrastructure.adapters.events.events.EntitySpawnEvent;
import engine.infrastructure.adapters.events.events.EntityMoveEvent;
import engine.infrastructure.adapters.events.events.EntityDeathEvent;
import engine.infrastructure.adapters.events.events.EntityDamageEvent;
import engine.infrastructure.state.GameModelState;

/**
 * Event publisher implementation
 * Converts domain events to infrastructure events and publishes via EventBus
 */
class EventPublisher implements IEventPublisher {
    private final eventBus: IEventBus;
    private final state: GameModelState;
    
    public function new(eventBus: IEventBus, state: GameModelState) {
        this.eventBus = eventBus;
        this.state = state;
    }
    
    public function publish(event: Dynamic): Void {
        // Convert domain events to infrastructure events
        final currentTick = state.tick;
        
        if (Std.isOfType(event, EntitySpawned)) {
            final domainEvent: EntitySpawned = cast event;
            eventBus.emit(EntitySpawnEvent.NAME, {
                tick: domainEvent.tick != 0 ? domainEvent.tick : currentTick,
                entityId: domainEvent.entityId,
                type: domainEvent.entityType,
                pos: {x: Std.int(domainEvent.position.x), y: Std.int(domainEvent.position.y)},
                ownerId: domainEvent.ownerId
            });
        } else if (Std.isOfType(event, EntityMoved)) {
            final domainEvent: EntityMoved = cast event;
            eventBus.emit(EntityMoveEvent.NAME, {
                tick: domainEvent.tick != 0 ? domainEvent.tick : currentTick,
                entityId: domainEvent.entityId,
                pos: {x: Std.int(domainEvent.toPosition.x), y: Std.int(domainEvent.toPosition.y)},
                vel: {x: 0, y: 0}, // Velocity not in domain event
                rotation: 0.0
            });
        } else if (Std.isOfType(event, EntityDied)) {
            final domainEvent: EntityDied = cast event;
            eventBus.emit(EntityDeathEvent.NAME, {
                tick: domainEvent.tick != 0 ? domainEvent.tick : currentTick,
                entityId: domainEvent.entityId,
                killerId: domainEvent.killerId
            });
        } else if (Std.isOfType(event, DamageDealt)) {
            final domainEvent: DamageDealt = cast event;
            eventBus.emit(EntityDamageEvent.NAME, {
                tick: domainEvent.tick != 0 ? domainEvent.tick : currentTick,
                entityId: domainEvent.entityId,
                damage: domainEvent.damage,
                attackerId: domainEvent.attackerId,
                newHp: domainEvent.newHealth.current
            });
        }
    }
}

