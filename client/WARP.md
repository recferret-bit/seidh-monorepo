# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Overview

Seidh is a mobile-focused game built with **Haxe + Heaps.io** (game engine) and **TypeScript** (mobile utilities and JS bridge), bundled with **Vite**. The project uses a deterministic, portable **MVP architecture** with Clean Architecture principles, designed to support singleplayer and multiplayer modes with client-side prediction and reconciliation.

## Build Commands

### Development
```powershell
npm run dev                # Build TS and start Vite dev server (port 3000)
npm run vite:dev           # Start Vite dev server only (no TS build)
haxe compile.hxml          # Compile Haxe to game.js (debug mode)
```

### Production Build
```powershell
npm run vite:build:prod    # Full production build (TS + Haxe + bundle + minify)
npm run vite:preview       # Preview production build
```

### Individual Build Steps
```powershell
npm run build:tsc          # Compile TS and bundle with esbuild
npm run build:tsc:prod     # Compile TS, bundle, and minify with terser
npm run vite:build         # Vite build (development mode)
```

### Haxe Compilation
```powershell
haxe compile.hxml               # Compile client (outputs game.js)
haxe compile-backend.hxml       # Backend engine compilation (currently disabled)
```

## Architecture

### High-Level Structure

This is a **hybrid codebase**:
- **Haxe** (`src/`) - Core game engine with strict Clean Architecture + MVP
- **TypeScript** (`ts/`) - Mobile utilities, Telegram SDK integration, WebGL initialization
- **Vite** - Build orchestration that bundles game.js + TS into a single bundle

### Core Architectural Layers

The engine follows **Clean Architecture** with strict dependency rules:

```
Presentation Layer (presenter/)
    ↓ depends on
Application Layer (application/)
    ↓ depends on
Domain Layer (domain/)
    ↓ depends on
Infrastructure Layer (infrastructure/)
```

#### Layer Responsibilities

**Domain Layer** (`src/engine/domain/`)
- Pure business logic with ZERO dependencies on other layers
- Contains: entities, value objects, domain services, repository interfaces
- Examples: `DeterministicRng`, `PhysicsService`, `CollisionService`, `AIDecisionService`
- All domain entities are immutable data structures

**Application Layer** (`src/engine/application/`)
- Use Cases (application business rules) and DTOs
- Services orchestrate use cases but contain NO business logic
- Use cases execute single business operations using domain layer
- Examples: `SpawnCharacterUseCase`, `ProcessInputUseCase`, `IntegratePhysicsUseCase`

**Infrastructure Layer** (`src/engine/infrastructure/`)
- Implementation details: EventBus, repositories, state management, entity factories
- Contains concrete implementations of domain interfaces
- Examples: `EntityRepository`, `EventPublisher`, `GameModelState`, `ObjectPool`

**Presentation Layer** (`src/engine/presentation/`)
- User interface concerns and orchestration
- `GameLoop` - orchestrates services in deterministic order
- `SnapshotManager` - manages state snapshots for rollback
- `InputBuffer` - buffers and sequences player inputs

### Key Architectural Patterns

**MVP (Model-View-Presenter)**
- **Model**: `SeidhEngine`, `GameModelState`, entity managers - pure simulation, no view dependencies
- **Presenter**: `GameLoop`, Services, Use Case orchestration - coordinates model and view
- **View**: Heaps.io rendering (`game/scene/`), EventBus subscribers - passive consumer of engine events

**Repository Pattern**
- Domain defines interfaces (`IEntityRepository`, `ICharacterRepository`)
- Infrastructure provides implementations (`EntityRepository`, `CharacterRepository`)

**Factory Pattern**
- `EngineEntityFactory` - infrastructure factory using ObjectPool
- `UseCaseFactory` - creates all use cases with proper dependency injection
- Domain factories: `CharacterEntityFactory`, `ConsumableEntityFactory`, `ColliderEntityFactory`

**Event-Driven Architecture**
- `EventBus` - ordered, async-safe event delivery
- Engine emits events: `EntitySpawnEvent`, `EntityDeathEvent`, `TickCompleteEvent`, `SnapshotEvent`
- View subscribes to events without modifying model state

**Memento Pattern**
- `GameModelState.saveMemento()` / `restoreMemento()` for deterministic rollback
- Used for client-side prediction and reconciliation in multiplayer

### Critical Components

**SeidhEngine** (`src/engine/SeidhEngine.hx`)
- Main engine facade exposed to JavaScript via `@:expose()`
- Creates and wires all services, use cases, and infrastructure
- Supports three modes: `SINGLEPLAYER`, `SERVER`, `CLIENT_PREDICTION`
- Key methods: `start()`, `step()`, `queueInput()`, `spawnEntity()`, `rollbackAndReplay()`

**GameLoop** (`src/engine/presentation/GameLoop.hx`)
- Fixed timestep game loop (default 60 ticks/second)
- Executes services in deterministic order:
  1. InputService → ProcessInputUseCase
  2. AIService → UpdateAIBehaviorUseCase
  3. PhysicsService → IntegratePhysicsUseCase + ResolveCollisionUseCase
  4. SpawnService → CleanupDeadEntitiesUseCase
- NEVER contains business logic - only orchestration

**GameModelState** (`src/engine/infrastructure/state/GameModelState.hx`)
- Central state container with deterministic RNG
- Manages entity managers registry
- Implements Memento pattern for snapshots
- Allocates entity IDs sequentially

**UseCaseFactory** (`src/engine/infrastructure/config/UseCaseFactory.hx`)
- Factory for creating all use cases with dependency injection
- Initializes domain services (physics, collision, AI, targeting)
- Provides `spawnEntity()` / `despawnEntity()` convenience methods

**EventBus** (`src/engine/infrastructure/eventbus/EventBus.hx`)
- Ordered event delivery per topic
- Safe async dispatch (prevents reentrancy during module updates)
- Type-safe subscriptions with token-based unsubscribe

### Game Client Integration

**SceneManager** (`src/game/scene/SceneManager.hx`)
- Manages Heaps.io scene lifecycle
- Subscribes to GameEventBus for scene transitions
- Scenes: LoadingScene, HomeScene, GameScene, test scenes

**GameEventBus** (`src/game/eventbus/GameEventBus.hx`)
- Game-specific event bus (separate from engine EventBus)
- Handles UI/scene events: `LoadHomeSceneEvent`, `LoadGameSceneEvent`

**Resource System** (`src/game/resource/Res.hx`)
- Manages game asset loading (sprites, sounds, etc.)

## Key Development Patterns

### Adding New Entity Types

1. Add entity type to `engine/domain/types/EntityType.hx`
2. Create domain entity in `engine/domain/entities/[type]/`
3. Create infrastructure entity in `engine/infrastructure/entities/[type]/`
4. Create factory implementing domain interface
5. Register manager in `GameModelState.setupManagers()`
6. Add spawn logic to `UseCaseFactory.spawnEntity()`

### Creating Use Cases

1. Define in `engine/application/usecases/[category]/[Name]UseCase.hx`
2. Inject ONLY domain repositories and services (no infrastructure)
3. Keep focused on single operation (SRP)
4. Register in `UseCaseFactory` constructor
5. Wire to appropriate Service in `engine/application/services/`

### Working with Services

- Services are pure orchestrators with ZERO business logic
- They call use cases and coordinate infrastructure (buffers, tick scheduling)
- Services implement `IService` interface: `update(state, tick, dt)`, `shutdown()`
- Register in `SeidhEngine.setupServices()` and `ServiceRegistry`

### Event Publishing

- Use `EventPublisher` from infrastructure layer
- Define events in `engine/infrastructure/eventbus/events/`
- Events include tick, entityId, and payload data
- View/UI subscribes via `GameEventBus.instance.subscribe()`

### Determinism Requirements

- Use ONLY `state.rng` for all randomness
- Keep execution order deterministic in `GameLoop.executeServices()`
- Avoid floating point operations in gameplay logic
- Test with `saveMemento()` / `restoreMemento()` for reproducibility

## Project Structure

```
client/
├── src/
│   ├── Main.hx                         # Heaps.io app entry point
│   ├── engine/                         # Portable game engine
│   │   ├── SeidhEngine.hx             # Main engine facade
│   │   ├── config/                    # Engine configuration
│   │   ├── domain/                    # Business logic (pure)
│   │   │   ├── entities/              # Domain entities
│   │   │   ├── services/              # Domain services
│   │   │   ├── repositories/          # Repository interfaces
│   │   │   └── types/                 # Value objects, enums
│   │   ├── application/               # Use cases and app services
│   │   │   ├── usecases/              # Single-operation business rules
│   │   │   ├── services/              # Orchestration services
│   │   │   ├── dto/                   # Data transfer objects
│   │   │   └── ports/                 # Interface adapters
│   │   ├── infrastructure/            # Implementation details
│   │   │   ├── entities/              # Infrastructure entity implementations
│   │   │   ├── eventbus/              # Event system
│   │   │   ├── state/                 # State management
│   │   │   ├── persistence/           # Repositories
│   │   │   └── config/                # Factories and registries
│   │   └── presentation/              # Game loop and orchestration
│   └── game/                          # Game-specific client code
│       ├── config/                    # Client configuration
│       ├── eventbus/                  # Client event bus
│       ├── resource/                  # Asset management
│       └── scene/                     # Heaps.io scenes
├── ts/                                # TypeScript mobile utilities
│   ├── main.ts                        # TS entry point
│   └── mobileUtils.ts                 # Mobile helpers (touch, device info)
├── res/                               # Game assets (sprites, audio, etc.)
├── dist/                              # Build output
├── docs/                              # Architecture documentation
├── index.html                         # Mobile-optimized HTML
├── compile.hxml                       # Haxe build config (client)
├── vite.config.js                     # Vite bundler config
├── package.json                       # NPM dependencies and scripts
└── tsconfig.build.json                # TypeScript build config
```

## Vite Build Process

Vite orchestrates a multi-stage build:

1. **TypeScript Compilation** (`tsc --project tsconfig.build.json`)
   - Compiles `ts/` → `dist/main.js` with source maps
2. **Bundle** (`esbuild dist/main.js → dist/bundle.js`)
   - Bundles TS output to ESM format
3. **Haxe Compilation** (manual: `haxe compile.hxml`)
   - Compiles `src/` → `game.js`
4. **Vite Bundle Plugin** (`vite.config.js`)
   - Reads `game.js` and prepends it to the main bundle
   - Minifies game.js with terser in production
   - Generates production `index.html` with correct script tags
5. **Production Output** (`dist/bundle.min.js` + `dist/index.html`)

## Important Notes

### Dependency Rules

- **Domain layer** depends on NOTHING
- **Application layer** depends on domain only
- **Infrastructure layer** depends on domain and application
- **Presentation layer** depends on all layers but contains no business logic

### Never Put Business Logic In

- Services (orchestration only)
- GameLoop (deterministic scheduling only)
- Factories (object creation only)
- EventBus handlers (reactive only)

### Always Put Business Logic In

- Domain entities and value objects
- Domain services
- Use Cases

### Testing Strategy

- Domain layer: pure unit tests (no mocks needed)
- Use Cases: test with mock repositories
- Services: integration tests with real use cases
- Full engine: deterministic replay tests with snapshots

### Multiplayer Architecture

Engine supports three modes:
- **SINGLEPLAYER**: Local engine, no networking
- **SERVER**: Authoritative server, emits snapshots every N ticks
- **CLIENT_PREDICTION**: Client-side prediction with rollback/reconciliation

Client prediction workflow:
1. Client applies input locally (optimistic)
2. Sends input to server
3. Receives authoritative snapshot from server
4. Calls `rollbackAndReplay(anchorTick, pendingInputs)`
5. Emits `EntityCorrectionEvent` for view smoothing

## Mobile Considerations

- Touch event handling in `ts/mobileUtils.ts`
- Wake lock support for screen always-on
- High DPI display support in CSS
- Viewport configuration in `index.html`
- Battery monitoring via Telegram SDK (`@telegram-apps/sdk`)

## Common Workflows

### Running Development Server
```powershell
# Compile Haxe first (required)
haxe compile.hxml

# Then start dev server
npm run dev
```

### Making Engine Changes
1. Edit Haxe files in `src/engine/`
2. Recompile: `haxe compile.hxml`
3. Refresh browser (Vite hot-reloads)

### Making UI Changes
1. Edit scene files in `src/game/scene/`
2. Recompile Haxe: `haxe compile.hxml`
3. Refresh browser

### Making TypeScript Changes
1. Edit files in `ts/`
2. Vite auto-recompiles on save (in dev mode)

### Production Build
```powershell
# Full production build
npm run vite:build:prod

# Output: dist/bundle.min.js, dist/index.html
```

## Documentation

Detailed architecture docs in `docs/`:
- `docs/engine/1-engine-basics.md` - MVP architecture, contracts, module structure
- `docs/game/1-game-architecture.md` - Heaps.io client integration patterns
- `docs/map-and-units/` - Game-specific entity details
- `docs/networking/` - Multiplayer and reconciliation

Read these docs before making architectural changes to understand the strict layering and dependency rules.
