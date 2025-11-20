# Phase 2: Engine Architecture Important Improvements

## Overview
This plan addresses three important architectural improvements identified in the engine review:
1. **Simplify specs system** - Reduce duplication and unclear separation
2. **Fix service naming collision** - PhysicsService exists in both application and domain
3. **Move config to domain layer** - EngineConfig/EngineMode are business rules, not infrastructure

**Status**: Phase 1 Complete ✅ (Entity duplication eliminated, infrastructure reorganized, managers merged)

**Estimated Timeline**: 1 week (3-5 working days)

**Risk Level**: Low-Medium (smaller changes, less invasive than Phase 1)

**Testing Strategy**: After each fix, verify engine compiles and functionality works

---

## Prerequisites
- ✅ Phase 1 complete and merged to main
- ✅ All tests passing
- ✅ Clean working directory

---

## Fix 4: Simplify Specs System (Days 1-2)

### Current Problem

**Current State**:
```
domain/specs/
└── EntitySpec.hx  # Single typedef with ALL entity fields mixed together
```

**Problems**:
1. **Massive typedef**: `EntitySpec` has 30+ optional fields for ALL entity types
   - Character: maxHp, hp, level, stats, attackDefs, spellBook, aiProfile
   - Consumable: effectId, durationTicks, stackable, charges, useRange, quantity
   - Effect: effectType, intensity, targetId, casterId, duration
   - Collider: passable, isTrigger
   - Base: id, type, pos, vel, rotation, ownerId, isAlive, colliderWidth, etc.

2. **Type Safety Issues**:
   - When creating a character, IDE shows ALL consumable/collider fields
   - No compile-time validation of field combinations
   - Easy to pass wrong fields

3. **Unclear Separation**:
   - Used for BOTH entity creation AND runtime serialization
   - Mixing specification vs data transfer object concerns

4. **Poor Discoverability**:
   - Hard to know which fields are required for specific entity types
   - IDE autocomplete shows irrelevant fields

### Solution: Type-Specific Specs

**New Structure**:
```
domain/specs/
├── EntitySpec.hx           # Base spec (common fields only)
├── CharacterSpec.hx        # Character-specific spec
├── ConsumableSpec.hx       # Consumable-specific spec
├── ColliderSpec.hx         # Collider-specific spec
└── SerializedEntityData.hx # For memento pattern only
```

**Benefits**:
- Type safety: Only relevant fields per entity type
- Better IDE autocomplete and discoverability
- Clearer intent (what entity am I creating?)
- Separation between creation specs and serialization DTOs

### Implementation Steps

#### Step 4.1: Analyze Current Spec Usage (1 hour)
```bash
grep -r "EntitySpec" src/engine/
```

**Expected locations**:
- Entity factories (all 3 types)
- Use cases (Spawn* use cases)
- Entity `reset()` methods
- EntityRepository.create()
- Serialization (entity.serialize(), restoreMemento)
- UseCaseFactory spawn methods

#### Step 4.2: Design New Spec Hierarchy (2 hours)

**Base Spec** (common to all entities):
```haxe
typedef EntitySpec = {
    ?id: Int,
    type: EntityType,
    pos: Vec2,
    vel: Vec2,
    ?rotation: Float,
    ownerId: String,
    ?isAlive: Bool,
    ?colliderWidth: Float,
    ?colliderHeight: Float,
    ?colliderOffset: Vec2
}
```

**Character Spec**:
```haxe
typedef CharacterSpec = EntitySpec & {
    ?maxHp: Int,
    ?hp: Int,
    ?level: Int,
    ?stats: CharacterStats,
    ?attackDefs: Array<Dynamic>,
    ?spellBook: Array<Dynamic>,
    ?aiProfile: String,
    ?isInputDriven: Bool
}
```

**Consumable Spec**:
```haxe
typedef ConsumableSpec = EntitySpec & {
    effectId: String,
    ?durationTicks: Int,
    ?stackable: Bool,
    ?charges: Int,
    ?useRange: Float,
    ?quantity: Int,
    ?effectValue: Dynamic
}
```

**Collider Spec**:
```haxe
typedef ColliderSpec = EntitySpec & {
    ?passable: Bool,
    ?isTrigger: Bool
}
```

**Serialization DTO** (for snapshot/restore only):
```haxe
typedef SerializedEntityData = {
    id: Int,
    type: EntityType,
    // ALL fields from all entity types (for memento pattern)
    // ...
}
```

#### Step 4.3: Create New Spec Files (1 hour)
- Create `domain/specs/CharacterSpec.hx`
- Create `domain/specs/ConsumableSpec.hx`
- Create `domain/specs/ColliderSpec.hx`
- Create `domain/specs/SerializedEntityData.hx`
- Update `domain/specs/EntitySpec.hx` - reduce to base fields only

#### Step 4.4: Update Entity Factories (2 hours)

**Files to update**:
- `domain/entities/character/factory/CharacterEntityFactory.hx`
- `domain/entities/character/factory/DefaultCharacterEntityFactory.hx`
- `domain/entities/consumable/factory/ConsumableEntityFactory.hx`
- `domain/entities/consumable/factory/DefaultConsumableEntityFactory.hx`
- `domain/entities/collider/ColliderEntityFactory.hx`
- `domain/entities/collider/DefaultColliderEntityFactory.hx`

**Change**: Update factory signatures to use specific spec types:
```haxe
interface CharacterEntityFactory {
    function create(spec: CharacterSpec): BaseCharacterEntity;
}
```

#### Step 4.5: Update Entity reset() Methods (1 hour)

**Change**: Update entity signatures to accept specific spec types:
```haxe
// BaseCharacterEntity
override public function reset(spec: CharacterSpec): Void {
    super.reset(spec);
    // Reset character-specific fields
}
```

#### Step 4.6: Update Use Cases (2 hours)

**Files to update** (~8 files):
- `application/usecases/character/SpawnCharacterUseCase.hx`
- `application/usecases/consumable/SpawnConsumableUseCase.hx`
- `application/usecases/collider/SpawnColliderUseCase.hx`

**Change**: Create specific spec types when spawning:
```haxe
final spec: CharacterSpec = {
    type: request.entityType,
    pos: new Vec2(request.x, request.y),
    vel: new Vec2(0, 0),
    ownerId: request.ownerId,
    maxHp: request.maxHp,
    level: request.level,
    stats: request.stats
};
```

#### Step 4.7: Update Repository and Serialization (2 hours)

**EntityRepository**: Keep accepting base `EntitySpec`:
```haxe
public function create(spec: EntitySpec): BaseEntity {
    final entity: BaseEntity = entityFactory.create(spec.type, spec);
    // ...
}
```

**Entity Serialization**: Use `SerializedEntityData`:
```haxe
public function serialize(): SerializedEntityData {
    return {
        id: this.id,
        type: this.type,
        // ... all fields
    };
}
```

#### Step 4.8: Update EngineEntityFactory (1 hour)
- Keep accepting base `EntitySpec`
- Delegate to type-specific factories internally

#### Step 4.9: Update UseCaseFactory (30 min)
- Update spawn helper methods to use specific spec types

#### Step 4.10: Testing & Verification (2 hours)

**Type Safety Tests**:
- Create character with CharacterSpec → only character fields accessible
- Try passing wrong spec type → compile error (expected!)

**Functionality Tests**:
- Spawn character/consumable/collider → all fields set correctly
- Serialize/deserialize → verify full lifecycle
- Snapshot/restore → verify memento pattern works

---

## Fix 5: Fix Service Naming Collision (Day 3)

### Current Problem

**PhysicsService exists in TWO places**:

1. **Application Layer** (`application/services/PhysicsService.hx`)
   - Orchestrator implementing `IService`
   - Delegates to physics use cases
   - Used by GameLoop

2. **Domain Layer** (`domain/services/PhysicsService.hx`)
   - Domain service with physics calculations
   - Methods: `integrateVelocity()`, `applyFriction()`
   - Used by IntegratePhysicsUseCase

**Problems**:
- Name collision causes confusion
- Imports require full package paths
- Not clear which service to use where

### Solution: Rename Domain Service

Rename domain `PhysicsService` → `PhysicsCalculationService`

**Rationale**:
- Application orchestrator keeps common name
- Domain service performs calculations, so name is more descriptive
- Clear distinction: orchestration vs calculation

### Implementation Steps

#### Step 5.1: Analyze PhysicsService Usage (30 min)
```bash
grep -r "PhysicsService" src/engine/
grep -r "import.*PhysicsService" src/engine/
```

**Expected locations**:
- `application/services/PhysicsService.hx` - keep
- `domain/services/PhysicsService.hx` - rename
- `application/usecases/physics/IntegratePhysicsUseCase.hx` - update import
- `infrastructure/configuration/UseCaseFactory.hx` - update import

#### Step 5.2: Rename Domain Service (30 min)

**Actions**:
- Rename file: `domain/services/PhysicsService.hx` → `domain/services/PhysicsCalculationService.hx`
- Update class name: `PhysicsService` → `PhysicsCalculationService`
- Update documentation

#### Step 5.3: Update All Imports (1 hour)

**Files to update** (~3 files):
- `application/usecases/physics/IntegratePhysicsUseCase.hx`
- `infrastructure/configuration/UseCaseFactory.hx`
- Any tests using the domain service

**Change**:
```haxe
// OLD:
import engine.domain.services.PhysicsService;

// NEW:
import engine.domain.services.PhysicsCalculationService;
```

#### Step 5.4: Update Variable Names (30 min)

**Change for clarity**:
```haxe
// Before:
private final domainPhysicsService: PhysicsService;  // Ambiguous!

// After:
private final physicsCalculationService: PhysicsCalculationService;
```

#### Step 5.5: Testing & Verification (1 hour)

**Tests**:
- Verify no import errors
- Physics integration works (entity movement)
- Collision detection works
- Friction applies correctly
- Search for remaining domain `PhysicsService` references

---

## Fix 6: Move Config to Domain Layer (Day 4)

### Current Problem

**Config in wrong location**:
```
engine/config/
├── EngineConfig.hx
└── EngineMode.hx
```

**Problems**:
1. **Not infrastructure concerns** - config defines business rules:
   - Tick rate affects game simulation
   - AI update intervals are domain timing
   - Unit pixels affect gameplay positioning
   - RNG seed affects deterministic behavior

2. **Imported across all layers** - creates wrong dependency direction

3. **Unclear ownership** - is config infrastructure or domain?

### Solution: Move to Domain

Move `config/` to `domain/config/`

**Rationale**:
- Config defines domain business rules
- Domain should own these rules
- Other layers import from domain (correct dependency)

### Implementation Steps

#### Step 6.1: Analyze Config Usage (30 min)
```bash
grep -r "EngineConfig" src/engine/
grep -r "EngineMode" src/engine/
grep -r "engine.config" src/engine/
```

**Expected locations** (~10-15 files):
- `SeidhEngine.hx`
- `domain/entities/BaseEntity.hx`
- `infrastructure/state/GameModelState.hx`
- `presentation/GameLoop.hx`
- Various use cases and services

#### Step 6.2: Create Domain Config Folder (30 min)

**Actions**:
```bash
mkdir src/engine/domain/config
mv src/engine/config/EngineConfig.hx src/engine/domain/config/
mv src/engine/config/EngineMode.hx src/engine/domain/config/
```

**Update package declarations**:
```haxe
// OLD:
package engine.config;

// NEW:
package engine.domain.config;
```

#### Step 6.3: Update All Imports (1.5 hours)

**Pattern**: Replace `engine.config` → `engine.domain.config`

**Can use bulk find/replace** (PowerShell):
```powershell
Get-ChildItem -Path src/engine -Recurse -Filter *.hx | 
    ForEach-Object { 
        (Get-Content $_.FullName) -replace 'import engine\.config\.', 'import engine.domain.config.' | 
        Set-Content $_.FullName 
    }
```

**Files to update** (~10-15 files):
- `SeidhEngine.hx`
- `domain/entities/BaseEntity.hx`
- `infrastructure/state/GameModelState.hx`
- `presentation/GameLoop.hx`
- Various application services
- Test files

#### Step 6.4: Delete Old Config Folder (15 min)

**Verify empty then delete**:
```bash
ls src/engine/config/
rm -r src/engine/config/
```

#### Step 6.5: Update Documentation (30 min)
- Update ENGINE_REVIEW.md
- Update architecture diagrams
- Note config location change

#### Step 6.6: Testing & Verification (1 hour)

**Tests**:
- Project compiles
- No import errors
- Engine initialization works
- Tick rate applied correctly
- Unit pixels used correctly
- AI update interval works
- RNG determinism works
- All engine modes work (SINGLEPLAYER, SERVER, CLIENT_PREDICTION)

---

## Post-Fix Verification (Day 5)

### Comprehensive Testing

**Unit Tests**:
- Run all existing unit tests
- Add tests for new spec types (if needed)
- Test PhysicsCalculationService
- Test config from domain

**Integration Tests**:
- Full game simulation (spawn → move → collide → die)
- Character creation with CharacterSpec
- Consumable creation with ConsumableSpec
- Collider creation with ColliderSpec
- Rollback/replay with new serialization
- Event emission

**Type Safety Tests**:
- Verify CharacterSpec only shows character fields in IDE
- Verify compile errors when mixing spec types

**Performance Tests**:
- Benchmark entity creation
- Verify no memory leaks
- Check serialization performance

### Code Quality Checks

**Static Analysis**:
- No unused imports
- No deprecated warnings
- All Phase 2 TODOs resolved

**Documentation**:
- Update architecture diagrams
- Document spec type system
- Document naming conventions

### Cleanup

**Remove**:
- Old `config/` folder (if exists)
- Temporary debug code
- Old commented code

**Organize**:
- Consistent formatting
- Consistent naming
- Verify file organization

---

## Migration Guide for Team

### Breaking Changes Summary

1. **Spec type imports changed**:
   - Old: Single `EntitySpec` with all fields
   - New: Specific types (`CharacterSpec`, `ConsumableSpec`, `ColliderSpec`)
   - Action: Use specific spec type for your entity

2. **PhysicsService renamed in domain**:
   - Old: `import engine.domain.services.PhysicsService;`
   - New: `import engine.domain.services.PhysicsCalculationService;`
   - Note: Application `PhysicsService` unchanged

3. **Config location moved**:
   - Old: `import engine.config.EngineConfig;`
   - New: `import engine.domain.config.EngineConfig;`
   - Action: Update imports (IDE can auto-fix)

### Update Checklist for Developers
- [ ] Pull latest Phase 2 changes
- [ ] Update spec imports to specific types (CharacterSpec, etc.)
- [ ] Update PhysicsService imports (if using domain service)
- [ ] Update config imports (engine.config → engine.domain.config)
- [ ] Verify your code compiles
- [ ] Run tests
- [ ] Review migration guide

### Code Examples

**Before (Phase 1)**:
```haxe
import engine.domain.specs.EntitySpec;
import engine.domain.services.PhysicsService;  // Collision!
import engine.config.EngineConfig;

final spec: EntitySpec = {
    type: EntityType.RAGNAR,
    pos: new Vec2(0, 0),
    vel: new Vec2(0, 0),
    ownerId: "player1",
    maxHp: 100,  // Mixed with consumable/collider fields
    effectId: "heal"  // Wrong! But compiles...
};
```

**After (Phase 2)**:
```haxe
import engine.domain.specs.CharacterSpec;  // Specific!
import engine.domain.services.PhysicsCalculationService;  // Clear!
import engine.domain.config.EngineConfig;  // Domain!

final spec: CharacterSpec = {
    type: EntityType.RAGNAR,
    pos: new Vec2(0, 0),
    vel: new Vec2(0, 0),
    ownerId: "player1",
    maxHp: 100,
    level: 1,
    stats: myStats
    // effectId not available - compile error! (Good!)
};
```

---

## Success Criteria

### Must Have
- [ ] Project compiles without errors
- [ ] All existing tests pass
- [ ] Spec types provide type safety (compile errors for wrong fields)
- [ ] No PhysicsService naming collisions
- [ ] Config in domain layer with correct imports

### Should Have
- [ ] IDE autocomplete works correctly for spec types
- [ ] Performance same or better than before
- [ ] Code complexity same or reduced
- [ ] Documentation updated

### Nice to Have
- [ ] New tests for type-specific specs
- [ ] Architecture diagram updated
- [ ] Migration guide reviewed by team

---

## Risk Assessment

### Low Risk
- **Config move**: Mechanical package rename
- **PhysicsService rename**: Only 3-4 files affected
- **Most spec changes**: Type extensions are backward compatible

### Medium Risk
- **Spec type changes in factories**: Need careful testing
- **Serialization format**: Must maintain backward compatibility
- **Import updates**: Many files to update

### Mitigation
- Incremental commits after each fix
- Test after each step
- Keep backward compatibility where possible
- Can rollback to Phase 1 if major issues

---

## Estimated Effort

### By Fix
- **Fix 4 (Specs)**: 14 hours (2.5 days)
- **Fix 5 (Naming)**: 3.5 hours (0.5 day)
- **Fix 6 (Config)**: 4.5 hours (1 day)
- **Verification**: 4 hours (0.5 day)

**Total**: ~26 hours (5 working days, or 1 week)

### Buffer
Add 20% buffer: ~5 hours

**Total with buffer**: ~31 hours (6 working days)

---

## Next Steps

1. **Create Phase 2 branch**: `git checkout -b refactor/phase2-architecture-improvements`
2. **Start with Fix 4** (Simplify Specs) - highest value
3. **Commit after each fix** - incremental progress
4. **Test thoroughly** - avoid regressions
5. **Merge to main when complete**

---

## Notes

- Phase 2 is lower risk than Phase 1 (fewer files affected)
- Each fix is relatively independent (can do in any order)
- Spec system fix provides most value (type safety)
- All fixes improve code clarity and maintainability
