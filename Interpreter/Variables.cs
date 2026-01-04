// ============================================================================
// BazzBasic - Variable Storage
// Handles variables ($), constants (#), and arrays
// ============================================================================

using BazzBasic.Parser;

namespace BazzBasic.Interpreter;

// Exception for undefined variables
public class UndefinedVariableException : Exception
{
    public string VariableName { get; }
    
    public UndefinedVariableException(string variableName) 
        : base($"Undefined variable: {variableName}")
    {
        VariableName = variableName;
    }
}

public class Variables
{
    // Regular variables (name ends with $)
    private readonly Dictionary<string, Value> _variables = new(StringComparer.OrdinalIgnoreCase);
    
    // Constants (name ends with #) - immutable after first assignment
    private readonly Dictionary<string, Value> _constants = new(StringComparer.OrdinalIgnoreCase);
    
    // Arrays - stored as Dictionary<string, Value> per array
    // Key format: "arrayname$" -> Dictionary of (key -> value)
    private readonly Dictionary<string, Dictionary<string, Value>> _arrays = new(StringComparer.OrdinalIgnoreCase);

    // Scope management (for user functions)
    private readonly Stack<Dictionary<string, Value>> _localScopes = new();

    // ========================================================================
    // Variables
    // ========================================================================
    
    public void SetVariable(string name, Value value)
    {
        string key = name.ToUpperInvariant();
        
        // If in local scope, ONLY write to local scope
        if (_localScopes.Count > 0)
        {
            _localScopes.Peek()[key] = value;
            return;
        }
        
        _variables[key] = value;
    }

    public Value GetVariable(string name)
    {
        string key = name.ToUpperInvariant();
        
        // If in local scope, ONLY check local scope (and constants)
        if (_localScopes.Count > 0)
        {
            if (_localScopes.Peek().TryGetValue(key, out Value localValue))
                return localValue;
            
            // Constants are accessible everywhere (they're immutable)
            if (_constants.TryGetValue(key, out Value constValue))
                return constValue;
            
            // Not found in local scope
            throw new UndefinedVariableException(name);
        }
        
        // Global scope
        if (_variables.TryGetValue(key, out Value value))
            return value;
        
        // Check if it's a constant
        if (_constants.TryGetValue(key, out value))
            return value;
        
        // Undefined variable - throw exception
        throw new UndefinedVariableException(name);
    }

    public bool TryGetVariable(string name, out Value value)
    {
        string key = name.ToUpperInvariant();
        
        // Check local scope first
        if (_localScopes.Count > 0 && _localScopes.Peek().TryGetValue(key, out value))
            return true;
        
        if (_variables.TryGetValue(key, out value))
            return true;
        
        // Check if it's a constant
        if (_constants.TryGetValue(key, out value))
            return true;
        
        value = Value.Zero;
        return false;
    }

    public bool VariableExists(string name)
    {
        string key = name.ToUpperInvariant();
        
        // If in local scope, ONLY check local scope (and constants)
        if (_localScopes.Count > 0)
        {
            return _localScopes.Peek().ContainsKey(key) || _constants.ContainsKey(key);
        }
        
        return _variables.ContainsKey(key) || _constants.ContainsKey(key);
    }

    // ========================================================================
    // Constants
    // ========================================================================
    
    public bool SetConstant(string name, Value value)
    {
        string key = name.ToUpperInvariant();
        
        // Constants can only be set once
        if (_constants.ContainsKey(key))
            return false;
        
        _constants[key] = value;
        return true;
    }

    public bool IsConstant(string name)
    {
        return _constants.ContainsKey(name.ToUpperInvariant());
    }

    // ========================================================================
    // Arrays
    // ========================================================================
    
    public void DeclareArray(string name)
    {
        string key = name.ToUpperInvariant();
        if (!_arrays.ContainsKey(key))
        {
            _arrays[key] = new Dictionary<string, Value>(StringComparer.OrdinalIgnoreCase);
        }
    }

    public bool ArrayExists(string name)
    {
        return _arrays.ContainsKey(name.ToUpperInvariant());
    }

    public void SetArrayElement(string arrayName, string index, Value value)
    {
        string key = arrayName.ToUpperInvariant();
        
        // Check if array is declared - do NOT auto-declare
        if (!_arrays.ContainsKey(key))
        {
            throw new InvalidOperationException($"Array not declared, use DIM first: {arrayName}");
        }
        
        _arrays[key][index] = value;
    }

    public Value GetArrayElement(string arrayName, string index)
    {
        string key = arrayName.ToUpperInvariant();
        
        if (!_arrays.TryGetValue(key, out var array))
        {
            throw new InvalidOperationException($"Array not declared, use DIM first: {arrayName}");
        }
        
        if (array.TryGetValue(index, out Value value))
            return value;
        
        throw new InvalidOperationException($"Array element {arrayName}({index}) not initialized");
    }

    public bool HasKey(string arrayName, string index)
    {
        string key = arrayName.ToUpperInvariant();
        
        if (!_arrays.TryGetValue(key, out var array))
            return false;
        
        return array.ContainsKey(index);
    }

    public bool DeleteKey(string arrayName, string index)
    {
        string key = arrayName.ToUpperInvariant();
        
        if (!_arrays.TryGetValue(key, out var array))
            return false;
        
        return array.Remove(index);
    }

    public int GetArrayLength(string arrayName)
    {
        string key = arrayName.ToUpperInvariant();
        
        if (!_arrays.TryGetValue(key, out var array))
            return 0;
        
        return array.Count;
    }

    // ========================================================================
    // Scope management (for user functions)
    // ========================================================================
    
    public void PushScope()
    {
        _localScopes.Push(new Dictionary<string, Value>(StringComparer.OrdinalIgnoreCase));
    }

    public void PopScope()
    {
        if (_localScopes.Count > 0)
            _localScopes.Pop();
    }

    public void SetLocal(string name, Value value)
    {
        if (_localScopes.Count > 0)
        {
            _localScopes.Peek()[name.ToUpperInvariant()] = value;
        }
        else
        {
            SetVariable(name, value);
        }
    }

    public Value GetLocal(string name)
    {
        string key = name.ToUpperInvariant();
        
        // Check local scope first
        if (_localScopes.Count > 0 && _localScopes.Peek().TryGetValue(key, out Value value))
            return value;
        
        // Fall back to global
        return GetVariable(name);
    }

    public bool IsInLocalScope => _localScopes.Count > 0;
}
