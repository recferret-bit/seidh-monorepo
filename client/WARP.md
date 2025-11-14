# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Build Commands

### Client (Heaps.io + TypeScript)

**Development Build:**
```powershell
# Compile Haxe game code (debug mode)
haxe compile.hxml

# Compile TypeScript and run dev server
npm run dev
```

**Production Build:**
```powershell
# Compile Haxe (same for prod)
haxe compile.hxml

# Build production bundle with minification
npm run vite:build:prod
```

**Alternative Build Scripts:**
- `npm run build:tsc` - Compile TypeScript and bundle with esbuild
- `npm run build:tsc:prod` - Compile and minify TypeScript
- `npm run vite:build` - Development Vite build
- `npm run vite:preview` - Preview production build

### Backend (Necroton Engine)

```powershell
# Compile engine for Node.js backend
haxe compile-backend.hxml

# Backend integration (from backend-integration directory)
cd backend-integration
npm install
npm run build   # Compile TypeScript
npm start       # Run server
```

### Running Tests

No specific test framework is configured. Check README or search for test scripts before attempting to run tests.

## Project Architecture

### High-Level Structure

This is a **mobile-focused game project** built with:
- **Haxe + Heaps.io** for game client rendering
- **TypeScript** for client-side utilities and Telegram integration
- **Necroton Engine** - a deterministic, portable game engine following MVP architecture

The project supports both **client-side gameplay** (browser/mobile) and **backend integration** (Node.js server running at 20 TPS).

### Key Directories

- **`src/`** - Haxe source code (game client + engine)
  - `engine/` - Necroton Engine implementation (Model-View-Presenter)
  - `game/` - Game-specific code (scenes, MVP layers, UI)
- **`ts/`** - TypeScript source (mobile utilities, Telegram SDK integration)
- **`dist/`** - Compiled output
- **`res/`** - Game assets (images, sounds)
- **`backend-integration/`** - Node.js backend server with TypeScript bindings
- **`docs/`** - Architecture documentation (engine, game patterns)

### MVP Architecture (Necroton Engine)

The engine follows strict **Model-View-Presenter** separation:

**Model** (Pure simulation, deterministic):
- `engine/model/` - Core entities, state, RNG
- `GameModelState` - Holds tick, entities, RNG state
- Entity types: CHARACTER, COLLIDER, CONSUMABLE, PROJECTILE
- No Heaps or rendering dependencies

**Presenter** (Orchestration):
- `engine/presenter/` - Game loop, input handling, snapshots
- `NecrotonEngine` - Main engine API
- `GameLoop` - Fixed-timestep simulation at configurable TPS
- `InputModule`, `PhysicsModule`, `AIModule`, `SpawnModule`

**View** (Event-driven surface):
- `engine/view/EventBus` - Exposes events to clients
- Events: `ENTITY_SPAWN`, `ENTITY_DEATH`, `ENTITY_MOVE`, `TICK_COMPLETE`, etc.
- View layer (Heaps rendering) subscribes to EventBus, never modifies Model

### Client Architecture (Heaps.io)

**Scene Management:**
- `game/scene/SceneManager` - Manages scene transitions via event system
- Scenes: `LoadingScene`, `HomeScene`, `GameScene`
- Scene lifecycle: `start()`, `destroy()`, `customUpdate(dt, fps)`, `onResize()`

**Event System:**
- `game/event/EventManager` - Global event bus for scene transitions
- Events: `EVENT_LOAD_HOME_SCENE`, `EVENT_LOAD_GAME_SCENE`
- Components implement `EventListener` interface with `notify(event, message)`

**TypeScript Integration:**
- Mobile utilities compiled via `tsconfig.build.json`
- Output: `dist/main.js` and `dist/bundle.js`
- Vite bundles TypeScript + Haxe output together
- Production build combines `game.js` (Haxe) + `bundle.min.js` (TS) into single file

### Backend Integration

The engine compiles to JavaScript for backend use:
- `compile-backend.hxml` generates `dist/engine.js`
- TypeScript bindings in `backend-integration/engine.d.ts`
- Server example runs at 20 TPS using `setImmediate` (non-blocking)
- Supports: entity spawning, input queuing, event subscriptions, snapshot emission

## Development Workflow

### Typical Development Cycle

1. **Edit Haxe code** in `src/`
2. **Run `haxe compile.hxml`** to compile game logic
3. **Run `npm run dev`** to start Vite dev server (compiles TS automatically)
4. **Access `http://localhost:3000`** in browser
5. Engine changes require recompiling Haxe and refreshing browser

### Mobile Testing

Serve locally and access from mobile device:
```powershell
# Get local IP
ipconfig

# Visit http://<YOUR_IP>:3000 on mobile device
```

### File Compilation Flow

**Client Build:**
1. `haxe compile.hxml` → `game.js` (Heaps game code)
2. `tsc --project tsconfig.build.json` → `dist/main.js` (TS utilities)
3. `esbuild dist/main.js` → `dist/bundle.js` (bundled TS)
4. Vite dev server serves both at `localhost:3000`

**Production Build:**
1. Haxe compiles to `game.js`
2. TS compiles and minifies to `dist/bundle.min.js` (via terser)
3. Vite plugin combines `game.js` + `bundle.min.js` → single `bundle.min.js`
4. Output in `dist/` with production `index.html`

## Important Patterns

### Engine Determinism

The Necroton Engine is **deterministic** and designed for client prediction + server reconciliation:
- Fixed timestep simulation
- Deterministic RNG (`engine/model/DeterministicRng`)
- Snapshot system for rollback/replay
- Client prediction workflow: capture input → local predict → send to server → reconcile snapshot

When working with engine code:
- **Never** add non-deterministic operations (Date.now, Math.random)
- **Never** reference Heaps types in `engine/` code
- Use `EventBus` for all View communication
- Test determinism: same inputs + RNG seed = identical state

### Scene Transitions

Use `EventManager` for scene changes:
```haxe
EventManager.instance.publish(EventManager.EVENT_LOAD_GAME_SCENE, null);
```

### Entity Management

Entities are managed through type-specific managers:
- Each entity type has a dedicated manager (e.g., `CharacterEntityManager`)
- Spawn via: `engine.spawnEntity(spec)` where spec includes `type`, `pos`, `ownerId`, etc.
- Managers handle pooling, lifecycle, and per-tick updates

### Vite Custom Plugins

The Vite config includes custom plugins that:
- Bundle `game.js` (Haxe output) with TypeScript bundle
- Minify game.js for production using terser
- Generate production `index.html` with correct script tags
- Clean up unnecessary intermediate files

## Common Pitfalls

- **Don't commit without explicit request** - The codebase uses version control; only commit when user explicitly asks
- **Build order matters** - Haxe must compile before running Vite dev server
- **TypeScript paths** - Use `@/*` alias for `ts/*` directory
- **Engine mode** - Engine supports `SINGLEPLAYER`, `SERVER`, and `CLIENT_PREDICTION` modes
- **Event bus timing** - Events are emitted during simulation tick; View handlers should not block

## Technology Stack

- **Haxe 4.0+** - Compiles to JavaScript for both client and backend
- **Heaps.io** - 2D game framework for rendering (client only)
- **TypeScript 5.0** - Client utilities and type safety
- **Vite 7** - Dev server and build tool
- **esbuild** - Fast TypeScript bundler
- **Telegram Apps SDK** - Mobile integration (`@telegram-apps/sdk`)

## Configuration Files

- `compile.hxml` - Client Heaps.io build (debug mode)
- `compile-backend.hxml` - Backend engine build with source maps
- `tsconfig.json` - TypeScript config for IDE/type checking (noEmit: true)
- `tsconfig.build.json` - TypeScript build config (outputs to dist/)
- `vite.config.js` - Dev server and production build configuration
- `package.json` - Scripts, dependencies, and project metadata
