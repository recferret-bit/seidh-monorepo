package engine.infrastructure.configuration;

import engine.domain.repositories.IEntityRepository;
import engine.domain.repositories.ICharacterRepository;
import engine.application.ports.output.IEventPublisher;
import engine.application.usecases.character.SpawnCharacterUseCase;
import engine.application.usecases.character.MoveCharacterUseCase;
import engine.application.usecases.character.KillCharacterUseCase;
import engine.application.usecases.character.ApplyDamageUseCase;
import engine.application.usecases.character.AttackCharacterUseCase;
import engine.application.usecases.character.CleanupDeadEntitiesUseCase;
import engine.application.usecases.consumable.SpawnConsumableUseCase;
import engine.application.usecases.consumable.ConsumeItemUseCase;
import engine.application.usecases.collider.SpawnColliderUseCase;
import engine.application.usecases.ai.UpdateAIBehaviorUseCase;
import engine.application.usecases.input.ProcessInputUseCase;
import engine.application.usecases.physics.IntegratePhysicsUseCase;
import engine.application.usecases.physics.ResolveCollisionUseCase;
import engine.application.dto.SpawnCharacterRequest;
import engine.application.dto.SpawnConsumableRequest;
import engine.application.dto.SpawnColliderRequest;
import engine.domain.specs.EntitySpec;
import engine.domain.types.EntityType;
import engine.domain.entities.character.base.CharacterStats;
import engine.domain.entities.character.factory.CharacterEntityFactory;
import engine.domain.entities.consumable.factory.ConsumableEntityFactory;
import engine.domain.entities.collider.ColliderEntityFactory;
import engine.domain.services.PhysicsService as DomainPhysicsService;
import engine.domain.services.CollisionService;
import engine.domain.services.AIDecisionService;
import engine.infrastructure.state.GameModelState;
import engine.domain.services.DeterministicRng;
import engine.domain.services.TargetingService;
import engine.infrastructure.utilities.IdGeneratorService;
import engine.infrastructure.utilities.ClientEntityMappingService;
import engine.infrastructure.utilities.InputBufferService;
import engine.infrastructure.adapters.persistence.CharacterRepository;
import engine.domain.entities.character.factory.DefaultCharacterEntityFactory;
import engine.domain.entities.consumable.factory.DefaultConsumableEntityFactory;
import engine.domain.entities.collider.DefaultColliderEntityFactory;

/**
 * Factory for creating use cases with all dependencies
 */
class UseCaseFactory {
    private final entityRepository: IEntityRepository;
    private final eventPublisher: IEventPublisher;
    private final characterRepository: ICharacterRepository;
    private final state: GameModelState;
    public final idGenerator: IdGeneratorService;
    public final clientEntityMappingService: ClientEntityMappingService;
    public final inputBufferService: InputBufferService;
    private final domainPhysicsService: DomainPhysicsService;
    private final collisionService: CollisionService;
    private final aiDecisionService: AIDecisionService;
    private final targetingService: TargetingService;
    private final rng: DeterministicRng;
    private final characterFactory: CharacterEntityFactory;
    private final consumableFactory: ConsumableEntityFactory;
    private final colliderFactory: ColliderEntityFactory;
    
    // Use cases
    public final spawnCharacterUseCase: SpawnCharacterUseCase;
    public final moveCharacterUseCase: MoveCharacterUseCase;
    public final applyDamageUseCase: ApplyDamageUseCase;
    public final attackCharacterUseCase: AttackCharacterUseCase;
    public final killCharacterUseCase: KillCharacterUseCase;
    public final cleanupDeadEntitiesUseCase: CleanupDeadEntitiesUseCase;
    public final spawnConsumableUseCase: SpawnConsumableUseCase;
    public final spawnColliderUseCase: SpawnColliderUseCase;
    public final consumeItemUseCase: ConsumeItemUseCase;
    public final updateAIBehaviorUseCase: UpdateAIBehaviorUseCase;
    public final processInputUseCase: ProcessInputUseCase;
    public final integratePhysicsUseCase: IntegratePhysicsUseCase;
    public final resolveCollisionUseCase: ResolveCollisionUseCase;
    
    public function new(
        entityRepository: IEntityRepository,
        eventPublisher: IEventPublisher,
        state: GameModelState,
        characterFactory: CharacterEntityFactory,
        consumableFactory: ConsumableEntityFactory,
        colliderFactory: ColliderEntityFactory
    ) {
        this.entityRepository = entityRepository;
        this.eventPublisher = eventPublisher;
        this.characterRepository = new CharacterRepository(entityRepository);
        this.state = state;
        this.idGenerator = new IdGeneratorService(state);
        this.clientEntityMappingService = new ClientEntityMappingService();
        this.inputBufferService = new InputBufferService();
        this.domainPhysicsService = new DomainPhysicsService();
        this.collisionService = new CollisionService();
        this.targetingService = new TargetingService(characterRepository);
        this.aiDecisionService = new AIDecisionService(targetingService);
        this.rng = state.rng;
        this.characterFactory = characterFactory != null ? characterFactory : new DefaultCharacterEntityFactory();
        this.consumableFactory = consumableFactory != null ? consumableFactory : new DefaultConsumableEntityFactory();
        this.colliderFactory = colliderFactory != null ? colliderFactory : new DefaultColliderEntityFactory();
        
        // Create use cases (order matters for dependencies)
        this.spawnCharacterUseCase = new SpawnCharacterUseCase(entityRepository, eventPublisher, idGenerator, this.characterFactory);
        this.moveCharacterUseCase = new MoveCharacterUseCase(characterRepository, eventPublisher);
        this.applyDamageUseCase = new ApplyDamageUseCase(characterRepository, eventPublisher);
        this.attackCharacterUseCase = new AttackCharacterUseCase(characterRepository, applyDamageUseCase);
        this.killCharacterUseCase = new KillCharacterUseCase(characterRepository, applyDamageUseCase);
        this.cleanupDeadEntitiesUseCase = new CleanupDeadEntitiesUseCase(entityRepository, eventPublisher);
        this.spawnConsumableUseCase = new SpawnConsumableUseCase(entityRepository, eventPublisher, idGenerator, this.consumableFactory);
        this.spawnColliderUseCase = new SpawnColliderUseCase(entityRepository, eventPublisher, idGenerator, this.colliderFactory);
        this.consumeItemUseCase = new ConsumeItemUseCase(entityRepository, eventPublisher);
        this.updateAIBehaviorUseCase = new UpdateAIBehaviorUseCase(characterRepository, moveCharacterUseCase, attackCharacterUseCase, aiDecisionService, rng);
        this.processInputUseCase = new ProcessInputUseCase(moveCharacterUseCase, attackCharacterUseCase, characterRepository, targetingService);
        this.integratePhysicsUseCase = new IntegratePhysicsUseCase(entityRepository, eventPublisher, domainPhysicsService);
        this.resolveCollisionUseCase = new ResolveCollisionUseCase(entityRepository, eventPublisher, collisionService);
    }

    public function spawnEntity(spec: EntitySpec): Int {
        if (spec == null || spec.type == null) {
            return 0;
        }

        final entityType = spec.type;
        if (isCharacter(entityType)) {
            return spawnCharacter(spec);
        }

        if (isConsumable(entityType)) {
            return spawnConsumable(spec);
        }

        if (entityType == EntityType.COLLIDER) {
            return spawnCollider(spec);
        }

        return 0;
    }

    public function despawnEntity(entityId: Int): Void {
        final domainEntity = entityRepository.findById(entityId);
        if (domainEntity == null) {
            return;
        }

        final entityType = toEntityType(domainEntity.entityType);
        if (entityType != null && isCharacter(entityType)) {
            killCharacterUseCase.execute(entityId, 0, state.tick);
        } else {
            entityRepository.delete(entityId);
        }
    }

    private function spawnCharacter(spec: EntitySpec): Int {
        final request: SpawnCharacterRequest = {
            entityType: spec.type,
            x: spec.pos.x,
            y: spec.pos.y,
            ownerId: spec.ownerId,
            maxHp: spec.maxHp != null ? spec.maxHp : 100,
            level: spec.level != null ? spec.level : 1,
            stats: buildCharacterStats(spec.stats)
        };
        return spawnCharacterUseCase.execute(request);
    }

    private function spawnConsumable(spec: EntitySpec): Int {
        final request: SpawnConsumableRequest = {
            entityType: spec.type,
            x: spec.pos.x,
            y: spec.pos.y,
            ownerId: spec.ownerId,
            effectId: spec.effectId != null ? spec.effectId : "",
            durationTicks: spec.durationTicks != null ? spec.durationTicks : 0,
            stackable: spec.stackable != null ? spec.stackable : false,
            charges: spec.charges != null ? spec.charges : 1,
            useRange: spec.useRange != null ? spec.useRange : 16.0
        };
        return spawnConsumableUseCase.execute(request);
    }

    private function spawnCollider(spec: EntitySpec): Int {
        final request: SpawnColliderRequest = {
            x: spec.pos.x,
            y: spec.pos.y,
            width: spec.colliderWidth != null ? spec.colliderWidth : 2.0,
            height: spec.colliderHeight != null ? spec.colliderHeight : 2.0,
            ownerId: spec.ownerId,
            passable: spec.passable != null ? spec.passable : false,
            isTrigger: spec.isTrigger != null ? spec.isTrigger : false
        };
        return spawnColliderUseCase.execute(request);
    }

    private inline function isCharacter(type: EntityType): Bool {
        return switch (type) {
            case EntityType.RAGNAR, EntityType.ZOMBIE_BOY, EntityType.ZOMBIE_GIRL, EntityType.GLAMR: true;
            default: false;
        };
    }

    private inline function isConsumable(type: EntityType): Bool {
        return switch (type) {
            case EntityType.HEALTH_POTION, EntityType.ARMOR_POTION, EntityType.SALMON: true;
            default: false;
        };
    }

    private inline function toEntityType(value: String): Null<EntityType> {
        return value != null ? cast value : null;
    }

    private function buildCharacterStats(stats: Dynamic): CharacterStats {
        if (stats == null) {
            return null;
        }
        return new CharacterStats(
            stats.power,
            stats.armor,
            stats.speed,
            stats.castSpeed
        );
    }
}

