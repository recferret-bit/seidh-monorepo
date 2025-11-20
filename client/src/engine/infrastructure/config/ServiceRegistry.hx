package engine.infrastructure.config;

import engine.application.services.IService;
import engine.infrastructure.config.ServiceName;

/**
 * Registry for engine services
 */
class ServiceRegistry {
    private var services: Map<String, IService>;
    
    public function new() {
        services = new Map();
    }
    
    /**
     * Register a service
     * @param name Service name
     * @param service Service instance
     */
    public function register(name: ServiceName, service: IService): Void {
        services.set(name, service);
    }
    
    /**
     * Get service by name
     * @param name Service name
     * @return Service or null
     */
    public function get(name: ServiceName): IService {
        return services.exists(name) ? services.get(name) : null;
    }
    
    /**
     * Get all services
     * @return Array of services
     */
    public function getAll(): Array<IService> {
        final result = [];
        for (service in services) {
            result.push(service);
        }
        return result;
    }
}

