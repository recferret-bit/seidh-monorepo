package engine.infrastructure.services;

/**
 * Service for mapping clients to entities
 */
class ClientEntityMappingService {
    private final clientEntityMap: Map<String, Int>;
    
    public function new() {
        this.clientEntityMap = new Map();
    }
    
    /**
     * Set mapping between client and entity
     * @param clientId Client ID
     * @param entityId Entity ID
     */
    public function setMapping(clientId: String, entityId: Int): Void {
        clientEntityMap.set(clientId, entityId);
    }

    /**
     * Backwards-compatible alias for setMapping
     */
    public inline function setClientEntity(clientId: String, entityId: Int): Void {
        setMapping(clientId, entityId);
    }
    
    /**
     * Get entity ID for client
     * @param clientId Client ID
     * @return Entity ID or null if not found
     */
    public function getEntityId(clientId: String): Null<Int> {
        return clientEntityMap.exists(clientId) ? clientEntityMap.get(clientId) : null;
    }
    
    /**
     * Remove mapping for client
     * @param clientId Client ID
     */
    public function removeMapping(clientId: String): Void {
        if (clientEntityMap.exists(clientId)) {
            clientEntityMap.remove(clientId);
        }
    }
    
    /**
     * Check if client has a mapping
     * @param clientId Client ID
     * @return True if mapping exists
     */
    public function hasMapping(clientId: String): Bool {
        return clientEntityMap.exists(clientId);
    }
    
    /**
     * Clear all mappings
     */
    public function clear(): Void {
        clientEntityMap.clear();
    }
}

