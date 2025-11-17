package engine.modules.registry;

import engine.modules.abs.IModule;
import engine.modules.ModuleName;

/**
 * Registry for engine modules
 */
class ModuleRegistry {
    private var modules: Map<String, IModule>;
    
    public function new() {
        modules = new Map();
    }
    
    /**
     * Register a module
     * @param name Module name
     * @param module Module instance
     */
    public function register(name: ModuleName, module: IModule): Void {
        modules.set(name, module);
    }
    
    /**
     * Get module by name
     * @param name Module name
     * @return Module or null
     */
    public function get(name: ModuleName): IModule {
        return modules.exists(name) ? modules.get(name) : null;
    }
    
    /**
     * Get all modules
     * @return Array of modules
     */
    public function getAll(): Array<IModule> {
        final result = [];
        for (module in modules) {
            result.push(module);
        }
        return result;
    }
}

