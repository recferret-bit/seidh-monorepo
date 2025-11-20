# Engine Architecture Review

**Date**: 2025-11-20  
**Reviewed**: `/src/engine` folder  
**Purpose**: Game engine for online game - logic only, no rendering

---

## Executive Summary

The engine follows a **Clean Architecture / Hexagonal Architecture** pattern with distinct layers. The architecture is generally solid with clear separation of concerns, but there are **significant issues in the infrastructure layer** - particularly entity duplication, unclear responsibilities, and organizational inconsistencies.

**Overall Grade**: B- (Good foundation, needs infrastructure cleanup)

---

## 1. Current Architecture Overview

### Layer Structure

```
┌─────────────────────────────────────────────────────────────┐
│ Presentation Layer (GameLoop, Input/Snapshot Management)   │
├─────────────────────────────────────────────────────────────┤
│ Application Layer (Services, Use Cases, DTOs, Ports)       │
├─────────────────────────────────────────────────────────────┤
│ Domain Layer (Entities, Value Objects, Domain Services)    │
├─────────────────────────────────────────────────────────────┤
│ Infrastructure Layer (Persistence, Managers, Events, etc.) │
└─────────────────────────────────────────────────────────────┘
```

### File Count: 82 files
- **Domain**: ~40 files (entities, services, value objects, events, repositories interfaces)
- **Application**: ~25 files (use cases, services, DTOs, ports)
- **Infrastructure**: ~40 files (implementations, managers, state, factories)
- **Presentation**: 4 files (GameLoop, InputBuffer, SnapshotManager, InputMessage)
- **Config**: 2 files (EngineConfig, EngineMode)

---

## 2. Architecture Strengths ✅

### 2.1 Clean Layering
- Clear separation between domain, application, and infrastructure
- Dependencies point inward (infrastructure → application → domain)
- Domain layer is isolated and has no external dependencies

### 2.2 Use Case Pattern
- Well-implemented use case pattern with single responsibility
- Clear flow: `UseCase → Domain Logic → Repository → Event Publisher`
- Examples: `MoveCharacterUseCase`, `IntegratePhysicsUseCase`

### 2.3 Application Services as Orchestrators
- Services act as pure orchestrators (`InputService`, `AIService`, `PhysicsService`)
- All business logic delegated to use cases
- Clean comments documenting this pattern

### 2.4 Domain-Driven Design
- Rich domain model with value objects (`Position`, `Velocity`, `Health`)
- Domain events (`EntityMoved`, `DamageDealt`, `EntityDied`)
- Domain services for business logic (`CollisionService`, `AIDecisionService`)

### 2.5 Repository Pattern
- Clear contracts in domain (`IEntityRepository`, `ICharacterRepository`)
- Infrastructure implements with adapters (`EntityRepository`)
- Proper abstraction of persistence

### 2.6 Event-Driven Architecture
- Event bus with pub/sub pattern
- Domain events converted to infrastructure events via `EventPublisher`
- Clean separation between domain and infrastructure events

---

## 3. Critical Problems 🔴

### 3.1 **MAJOR: Entity Duplication Between Domain and Infrastructure**

**Problem**: Almost complete duplication of entity hierarchies:

**Domain Layer**:
```
domain/entities/
├── BaseEntity (interface)
├── character/
│   ├── base/BaseCharacterEntity (interface)
│   ├── factory/CharacterEntityFactory (interface)
│   └── impl/ (GlamrEntity, RagnarEntity, etc.)
├── collider/ColliderEntity (interface) + factory
└── consumable/BaseConsumableEntity (interface) + factory
```

**Infrastructure Layer**:
```
infrastructure/entities/
├── base/BaseEngineEntity (abstract class)
├── character/
│   ├── BaseCharacterEntity (concrete class)
│   ├── DefaultCharacterEntityFactory
│   └── impl/ (GlamrEntity, RagnarEntity, etc.)
├── collider/ColliderEntity (concrete class) + factory
└── consumable/BaseConsumableEntity (concrete class) + factory
```

**Issues**:
1. **Two parallel hierarchies** that mirror each other exactly
2. Infrastructure classes implement domain interfaces, making domain layer NOT pure
3. Naming confusion: `BaseCharacterEntity` exists in both layers
4. Domain "interfaces" are actually doing more than contracts (e.g., `move()`, `takeDamage()` methods have behavior expectations)
5. **EntityRepository converts between them**, adding complexity and conversion overhead

**Why This is Wrong**:
- Domain entities should NOT be interfaces for infrastructure entities
- Domain should be pure business logic, infrastructure should handle technical concerns
- This creates unnecessary coupling and conversion logic

---

### 3.2 **MAJOR: Infrastructure Folder Organization is Messy**

The `infrastructure/` folder contains too many disparate concepts without clear organization:

```
infrastructure/
├── config/           # ✅ OK - service configuration
├── entities/         # ❌ PROBLEM - duplicates domain
├── eventbus/         # ✅ OK - technical concern
├── events/           # ❌ REDUNDANT - EventPublisher only
├── factories/        # ✅ OK - entity factory
├── logging/          # ✅ OK - technical concern
├── managers/         # ❌ UNCLEAR - entity lifecycle management
├── persistence/      # ✅ OK - repository implementations
├── pooling/          # ✅ OK - performance optimization
├── services/         # ❌ CONFUSING - mix of concerns
├── specs/            # ❌ UNCLEAR - spec types
└── state/            # ✅ OK - game state management
```

**Issues**:
1. `entities/` - Should not exist; domain should handle entities
2. `events/` - Single file `EventPublisher.hx` doesn't need folder
3. `managers/` - Unclear what "manager" means; overlaps with repositories
4. `services/` - Contains 3 disparate services (IdGenerator, ClientMapping, InputBuffer)
5. `specs/` - Not infrastructure concerns, should be in domain or shared

---

### 3.3 **Entity Managers vs Repositories Confusion**

There are TWO systems for entity lifecycle:

1. **Managers** (`IEngineEntityManager`, `BaseEngineEntityManager`)
   - Located in `infrastructure/managers/`
   - Handles CRUD operations per entity type
   - Used by `GameModelState`
   
2. **Repositories** (`IEntityRepository`, `EntityRepository`)
   - Located in `domain/repositories/` and `infrastructure/persistence/`
   - Also handles CRUD operations
   - Wraps managers and converts entities

**Problem**: 
- Two overlapping systems doing the same thing
- Repository wraps manager, adding unnecessary conversion layer
- Unclear which to use when
- Managers are tied to infrastructure entities, repositories to domain entities

---

### 3.4 **Specs System is Convoluted**

Multiple spec types exist:
1. `BaseEntitySpec` (infrastructure/specs/)
2. `EngineEntitySpec` (infrastructure/specs/)
3. `EngineEntitySpecs.hx` (infrastructure/specs/) - seed data helper

**Issues**:
- Specs are used for both entity creation AND runtime entity data
- Mixing specification objects with data transfer objects
- Located in infrastructure but used everywhere

---

### 3.5 **Inconsistent Service Locations**

Services exist in THREE places:

1. **Application Services** (`application/services/`)
   - `InputService`, `AIService`, `PhysicsService`, `SpawnService`
   - Pure orchestrators

2. **Domain Services** (`domain/services/`)
   - `CollisionService`, `AIDecisionService`, `PhysicsService`, `TargetingService`
   - Business logic services

3. **Infrastructure Services** (`infrastructure/services/`)
   - `IdGeneratorService`, `ClientEntityMappingService`, `InputBufferService`
   - Technical services

**Issues**:
- `PhysicsService` exists in BOTH application and domain layers
- Naming collision between layers
- Unclear boundaries

---

## 4. Moderate Issues ⚠️

### 4.1 Config in Wrong Place
- `EngineConfig` and `EngineMode` are in `engine/config/`
- Should be in `domain/` since they define business rules (tick rate, AI intervals)

### 4.2 UseCaseFactory is Massive
- 200+ lines file acting as dependency injection container
- Contains all use case instantiation logic
- Should consider proper DI framework or split into smaller factories

### 4.3 Presentation Layer Concerns Leak
- `InputMessage` is in presentation but used in application layer
- `SnapshotManager` serialization is presentation but uses domain types
- Should consider cleaner adapter pattern

### 4.4 Missing Clear Module Boundaries
- No clear "module" organization (e.g., Character module, Physics module, AI module)
- Cross-cutting concerns scattered across layers

---

## 5. Minor Issues 📝

### 5.1 Inconsistent Naming
- `BaseEntity` vs `BaseEngineEntity` vs `BaseCharacterEntity`
- `IService` (interface) vs services without `I` prefix in domain
- Some files use `Default` prefix, others don't

### 5.2 Comments Inconsistency
- Some files have excellent documentation (Services, UseCases)
- Others have minimal or no comments (some domain entities)

### 5.3 Mixed Line Endings
- Some files use `\r\n` (Windows), others use `\n` (Unix)
- Should standardize

---

## 6. Improvement Proposals 🎯

### Proposal 1: Eliminate Entity Duplication ⭐⭐⭐⭐⭐

**Priority**: CRITICAL

**Current Problem**: Domain and infrastructure have duplicate entity hierarchies

**Solution**: Choose ONE of two approaches:

#### Option A: Pure Domain Model (Recommended)
1. **Remove** all domain entity interfaces
2. Make infrastructure entities THE entities
3. Move infrastructure entities to domain layer as concrete classes
4. Keep domain pure by having entities not depend on infrastructure

**Structure**:
```
domain/entities/
├── BaseEntity.hx (concrete abstract class)
├── character/
│   ├── BaseCharacterEntity.hx (concrete)
│   └── impl/ (RagnarEntity, etc.)
├── collider/ColliderEntity.hx (concrete)
└── consumable/BaseConsumableEntity.hx (concrete)
```

**Benefits**:
- Single source of truth
- No conversion overhead
- Clearer ownership
- Easier to maintain

#### Option B: Keep Interfaces (Not Recommended)
If domain entities must be interfaces:
1. Rename infrastructure entities to avoid confusion
2. Keep conversion layer but optimize it
3. Document why this complexity exists

---

### Proposal 2: Reorganize Infrastructure Folder ⭐⭐⭐⭐

**Priority**: HIGH

**New Structure**:
```
infrastructure/
├── adapters/           # NEW - external system adapters
│   ├── persistence/   # EntityRepository, CharacterRepository
│   └── events/        # EventPublisher, EventBus
├── configuration/     # ServiceRegistry, UseCaseFactory
├── factories/         # EngineEntityFactory (concrete creation)
├── logging/           # Logger
├── pooling/           # ObjectPool
├── state/             # GameModelState
└── utilities/         # NEW - technical utilities
    ├── IdGeneratorService
    ├── ClientEntityMappingService
    └── InputBufferService
```

**Changes**:
- Move `entities/` to domain (remove duplication)
- Consolidate `persistence/` + `events/` into `adapters/`
- Remove `managers/` (consolidate with repositories)
- Rename `services/` to `utilities/` for clarity
- Move `specs/` to domain or shared

---

### Proposal 3: Merge Manager and Repository ⭐⭐⭐⭐

**Priority**: HIGH

**Problem**: Two systems doing the same thing

**Solution**: Keep Repositories, remove Managers

1. Make `EntityRepository` directly manage entity lifecycle (no manager wrapper)
2. Move pooling logic into repository
3. Remove `IEngineEntityManager`, `BaseEngineEntityManager`
4. Update `GameModelState` to use repositories directly

**Benefits**:
- Single responsibility
- Less indirection
- Clearer ownership
- Better performance

---

### Proposal 4: Simplify Specs System ⭐⭐⭐

**Priority**: MEDIUM

**Solution**: Create clear separation

1. **Move to domain**: Create `domain/specs/` for entity specifications
2. **Split concerns**:
   - `EntitySpec.hx` - for entity creation (immutable)
   - `EntityData.hx` - for serialization/runtime data (if needed)
3. **Remove** `EngineEntitySpecs.hx` seed data (move to tests or separate config)

---

### Proposal 5: Fix Service Naming Collision ⭐⭐⭐

**Priority**: MEDIUM

**Solution**: Rename to avoid conflicts

1. Rename domain `PhysicsService` → `PhysicsDomainService` or `MovementService`
2. Keep application `PhysicsService` as orchestrator
3. Add namespace prefixes for clarity

**Alternative**: Use module organization
```
domain/modules/physics/PhysicsService
application/modules/physics/PhysicsService
```

---

### Proposal 6: Introduce Module Organization ⭐⭐

**Priority**: LOW-MEDIUM

**Solution**: Group by feature modules

```
engine/modules/
├── character/
│   ├── domain/
│   ├── application/
│   └── infrastructure/
├── physics/
├── ai/
└── combat/
```

**Benefits**:
- Clear feature boundaries
- Easier to understand related code
- Better scalability

**Tradeoff**: Requires significant restructuring

---

### Proposal 7: Move Config to Domain ⭐⭐

**Priority**: LOW

Move `config/` to `domain/config/` since:
- Tick rate affects game rules
- AI update intervals are domain concerns
- These are NOT infrastructure configs

---

### Proposal 8: Introduce Proper DI Container ⭐

**Priority**: LOW

Replace `UseCaseFactory` with proper dependency injection:
- Consider using DI framework or creating lightweight container
- Split factory into feature-specific factories
- Make dependencies more explicit

---

## 7. Recommended Action Plan

### Phase 1: Critical Fixes (1-2 weeks)
1. ✅ **Eliminate entity duplication** (Proposal 1)
   - Choose approach and document decision
   - Merge entity hierarchies
   - Remove conversion layer
   - Update all references

2. ✅ **Reorganize infrastructure folder** (Proposal 2)
   - Create new folder structure
   - Move files systematically
   - Update imports

3. ✅ **Merge manager and repository** (Proposal 3)
   - Consolidate into single system
   - Remove redundant abstractions

### Phase 2: Important Improvements (1 week)
4. ✅ **Simplify specs system** (Proposal 4)
5. ✅ **Fix service naming collision** (Proposal 5)
6. ✅ **Move config to domain** (Proposal 7)

### Phase 3: Optional Enhancements (Future)
7. ⏸️ **Module organization** (Proposal 6) - if project grows
8. ⏸️ **DI container** (Proposal 8) - if complexity increases

---

## 8. Architectural Patterns Analysis

### ✅ What's Working Well

1. **Clean Architecture**: Clear layer separation maintained
2. **Repository Pattern**: Good abstraction of data access
3. **Use Case Pattern**: Single responsibility, testable
4. **Event Sourcing**: Domain events for state changes
5. **Memento Pattern**: Snapshot system for rollback
6. **Object Pool Pattern**: Performance optimization for entities
7. **Service Orchestration**: Services as pure coordinators

### ❌ What's Not Working

1. **Entity Model**: Duplication violates DRY principle
2. **Infrastructure Organization**: Too many disparate concerns
3. **Manager Pattern**: Overlaps with repository, adds confusion
4. **Specification Pattern**: Overloaded with multiple concerns

---

## 9. Code Quality Metrics

### Complexity
- **High**: `EntityRepository.hx` (14KB, entity conversion)
- **High**: `UseCaseFactory.hx` (10KB, DI container)
- **High**: `BaseEngineEntity.hx` (10KB, base entity logic)
- **Moderate**: Most use cases (well-scoped, <100 lines)
- **Low**: Services (pure orchestration, <100 lines)

### Maintainability
- **Good**: Use cases, application services, domain services
- **Moderate**: Domain entities, value objects
- **Poor**: Entity conversion, manager/repository duplication

### Testability
- **Excellent**: Use cases (dependencies injected)
- **Good**: Domain services (pure functions)
- **Good**: Application services (orchestrators)
- **Moderate**: Infrastructure (tight coupling to state)

---

## 10. Security & Performance Notes

### Performance Considerations
- ✅ Object pooling implemented
- ✅ Memento pattern for efficient rollback
- ❌ Entity conversion adds overhead (should remove)
- ✅ Fixed timestep loop for determinism

### Potential Issues
- Entity conversion in hot loop (physics updates)
- Large state serialization for snapshots
- No lazy loading for entities

### Security
- ✅ No external dependencies in domain
- ✅ Input validation in use cases
- ✅ No direct database access (repository abstraction)

---

## 11. Summary & Verdict

### Strengths
- Solid clean architecture foundation
- Good separation of concerns in application/domain layers
- Well-implemented use case pattern
- Clear service orchestration

### Critical Issues
1. **Entity duplication** between domain and infrastructure
2. **Infrastructure folder** is disorganized and messy
3. **Manager/Repository** overlap creates confusion

### Recommendation
**Proceed with Phase 1 refactoring immediately**. The architecture is fundamentally sound but needs infrastructure cleanup to be maintainable long-term. The entity duplication is the biggest technical debt that will compound if left unaddressed.

### Grade Breakdown
- **Domain Layer**: A- (Clean, but entity interfaces are problematic)
- **Application Layer**: A (Excellent use case and service patterns)
- **Infrastructure Layer**: C (Messy organization, duplication issues)
- **Presentation Layer**: B+ (Clean, but some concerns leak)

**Overall**: B- (Good foundation, needs critical refactoring)

---

## 12. Additional Observations

### Positive Patterns Found
- Consistent use of `final` for immutability
- Good inline documentation in key files
- Proper abstraction of external concerns (event bus, logging)
- Deterministic RNG for multiplayer consistency

### Anti-Patterns Found
- Anemic domain model (entities converted to DTOs)
- Leaky abstractions (specs used everywhere)
- God object tendency (UseCaseFactory, EntityRepository)
- Shotgun surgery risk (entity changes require updates in multiple places)

---

**End of Review**

*This review focuses on architectural patterns and code organization. No rendering code was found as expected for a pure game logic engine.*
