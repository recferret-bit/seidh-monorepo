package engine.application.dto;

/**
 * DTO for consuming an item
 */
typedef ConsumeItemRequest = {
    var entityId: Int;
    var consumerId: Int;
    var tick: Int;
}

