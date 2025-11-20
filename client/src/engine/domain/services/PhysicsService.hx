package engine.domain.services;

import engine.domain.valueobjects.Position;
import engine.domain.valueobjects.Velocity;

/**
 * Domain service for physics integration rules
 * Contains physics business logic (not technical implementation)
 */
class PhysicsService {
    
    public function new() {
    }
    
    /**
     * Integrate velocity into position
     * Business rule: position = position + velocity * deltaTime
     * @param position Current position
     * @param velocity Current velocity
     * @param deltaTime Time step
     * @return New position after integration
     */
    public function integrateVelocity(position: Position, velocity: Velocity, deltaTime: Float): Position {
        return position.add(velocity.x * deltaTime, velocity.y * deltaTime);
    }
    
    /**
     * Apply friction to velocity
     * Business rule: velocity = velocity * frictionCoefficient
     * @param velocity Current velocity
     * @param frictionCoefficient Friction coefficient (0.0 to 1.0)
     * @return New velocity after friction
     */
    public function applyFriction(velocity: Velocity, frictionCoefficient: Float): Velocity {
        return velocity.scale(frictionCoefficient);
    }
}

