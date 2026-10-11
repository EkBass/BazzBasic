/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Interpreter\Variables.cs
 Handles variables ($), constants (#), and arrays
 With fonts, I did need some guiding from Claude AI on this one :)
 
Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

using BazzBasic.Parser;
using System.Diagnostics.CodeAnalysis;

namespace BazzBasic.Interpreter;

// Exception for undefined variables
public class UndefinedVariableException(string variableName) : Exception($"Undefined variable: {variableName}")
{
    public string VariableName { get; } = variableName;
}

public class Variables
{
    // Regular variables (name ends with $)
    private readonly Dictionary<string, Value> _variables = new(StringComparer.OrdinalIgnoreCase);
    
    // Constants (name ends with #) - immutable after first assignment
    private readonly Dictionary<string, Value> _constants = new(StringComparer.OrdinalIgnoreCase);
    
    // Arrays - stored as OrderedDictionary<string, Value> per array.
    // OrderedDictionary (System.Collections.Generic, .NET 9+) guarantees insertion order
    // and gives O(1) indexed access via GetAt() - a plain Dictionary only preserves
    // insertion order as an implementation detail, not a documented guarantee, which
    // matters once arrays are enumerated by index (see ARRKEY).
    // Key format: "arrayname$" -> OrderedDictionary of (key -> value)
    private readonly Dictionary<string, OrderedDictionary<string, Value>> _arrays = new(StringComparer.OrdinalIgnoreCase);

    // Scope management (for user functions)
    private readonly Stack<Dictionary<string, Value>> _localScopes = new();

    // Function-local arrays, one table per call frame (pushed/popped together
    // with _localScopes). Without this, arrays DIM'd inside DEF FN lived in the
    // global table and kept their contents between calls.
    private readonly Stack<Dictionary<string, OrderedDictionary<string, Value>>> _localArrayScopes = new();

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
    
    // Find an array: current function's local arrays first, then globals.
    // The global fallback keeps the existing behavior of functions being able
    // to read/write global arrays they did not DIM themselves.
    private bool TryResolveArray(string key, [NotNullWhen(true)] out OrderedDictionary<string, Value>? array)
    {
        if (_localArrayScopes.Count > 0 && _localArrayScopes.Peek().TryGetValue(key, out array))
            return true;
        return _arrays.TryGetValue(key, out array);
    }

    private static OrderedDictionary<string, Value> NewArray() =>
        new(StringComparer.OrdinalIgnoreCase);

    // Implicit declaration (SPLIT, JOIN, network helpers...): no-op if the
    // name already resolves to an array. Otherwise create it in the current
    // scope - inside a function that means a local array.
    public void DeclareArray(string name)
    {
        string key = name.ToUpperInvariant();
        if (TryResolveArray(key, out _))
            return;

        if (_localArrayScopes.Count > 0)
            _localArrayScopes.Peek()[key] = NewArray();
        else
            _arrays[key] = NewArray();
    }

    // Explicit DIM. Inside a function it ALWAYS creates a fresh, empty local
    // array (shadowing any global of the same name), so every call - and every
    // recursion level - gets its own array. At global level it keeps the old
    // behavior: re-DIM of an existing array is a no-op.
    public void DimArray(string name)
    {
        string key = name.ToUpperInvariant();
        if (_localArrayScopes.Count > 0)
        {
            _localArrayScopes.Peek()[key] = NewArray();
            return;
        }

        if (!_arrays.ContainsKey(key))
            _arrays[key] = NewArray();
    }

    public bool ArrayExists(string name)
    {
        return TryResolveArray(name.ToUpperInvariant(), out _);
    }

    public void SetArrayElement(string arrayName, string index, Value value)
    {
        string key = arrayName.ToUpperInvariant();
        
        // Check if array is declared - do NOT auto-declare
        if (!TryResolveArray(key, out var value1))
        {
            throw new InvalidOperationException($"Array not declared, use DIM first: {arrayName}");
        }

        value1[index] = value;
    }

    public Value GetArrayElement(string arrayName, string index)
    {
        string key = arrayName.ToUpperInvariant();
        
        if (!TryResolveArray(key, out var array))
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
        
        if (!TryResolveArray(key, out var array))
            return false;
        
        return array.ContainsKey(index);
    }

    public bool DeleteKey(string arrayName, string index)
    {
        string key = arrayName.ToUpperInvariant();
        
        if (!TryResolveArray(key, out var array))
            return false;
        
        return array.Remove(index);
    }

    public bool DeleteArray(string arrayName)
    {
        string key = arrayName.ToUpperInvariant();
        if (_localArrayScopes.Count > 0 && _localArrayScopes.Peek().Remove(key))
            return true;
        return _arrays.Remove(key);
    }

    public int GetArrayLength(string arrayName)
    {
        string key = arrayName.ToUpperInvariant();
        
        if (!TryResolveArray(key, out var array))
            return 0;
        
        return array.Count;
    }

    public OrderedDictionary<string, Value>? GetAllArrayElements(string arrayName)
    {
        string key = arrayName.ToUpperInvariant();
        return TryResolveArray(key, out var array) ? array : null;
    }

    // Count unique first-dimension values (for ROWCOUNT)
    // e.g. keys "0,name", "0,gravity", "1,name" → 2 unique rows
    public int GetArrayRowCount(string arrayName)
    {
        var elements = GetAllArrayElements(arrayName);
        if (elements == null) return 0;

        var uniqueFirst = new HashSet<string>();
        foreach (var k in elements.Keys)
        {
            int comma = k.IndexOf(',');
            uniqueFirst.Add(comma >= 0 ? k[..comma] : k);
        }
        return uniqueFirst.Count;
    }

    // Return the key at a given 0-based index, in insertion order.
    // Used by ARRKEY() to loop over associative arrays with FOR/NEXT or WHILE/WEND.
    // Returns null if the array doesn't exist or the index is out of range.
    public string? GetArrayKeyAt(string arrayName, int index)
    {
        string key = arrayName.ToUpperInvariant();

        if (!TryResolveArray(key, out var array))
            return null;

        if (index < 0 || index >= array.Count)
            return null;

        return array.GetAt(index).Key;
    }

    // ========================================================================
    // Scope management (for user functions)
    // ========================================================================
    
    public void PushScope()
    {
        _localScopes.Push(new Dictionary<string, Value>(StringComparer.OrdinalIgnoreCase));
        _localArrayScopes.Push(new Dictionary<string, OrderedDictionary<string, Value>>(StringComparer.OrdinalIgnoreCase));
    }

    public void PopScope()
    {
        if (_localScopes.Count > 0)
            _localScopes.Pop();
        if (_localArrayScopes.Count > 0)
            _localArrayScopes.Pop();
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
