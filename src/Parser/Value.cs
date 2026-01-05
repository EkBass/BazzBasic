/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Parser\Value.cs
 Tagged union style, holds either number or string

 Licence: MIT
*/
namespace BazzBasic.Parser;

public enum BazzValueType
{
    Number,
    String
}

public struct Value
{
    public BazzValueType Type;
    public double NumValue;
    public string StringValue;

    // ========================================================================
    // Constructosr
    // ========================================================================
    
    public static Value FromNumber(double n) => new() 
    { 
        Type = BazzValueType.Number, 
        NumValue = n, 
        StringValue = "" 
    };
    
    public static Value FromString(string s) => new() 
    { 
        Type = BazzValueType.String, 
        NumValue = 0, 
        StringValue = s ?? "" 
    };

    public static Value Zero => FromNumber(0);
    public static Value Empty => FromString("");

    // ========================================================================
    // Type conversion
    // ========================================================================
    
    public readonly double AsNumber()
    {
        if (Type == BazzValueType.Number)
            return NumValue;
        
        // Try to parse string as number
        if (double.TryParse(StringValue, System.Globalization.NumberStyles.Any, 
            System.Globalization.CultureInfo.InvariantCulture, out double result))
            return result;
        
        return 0;
    }

    public readonly string AsString()
    {
        if (Type == BazzValueType.String)
            return StringValue;
        
        // Format number without trailing zeros
        return NumValue.ToString(System.Globalization.CultureInfo.InvariantCulture);
    }

    // ========================================================================
    // Boolean evaluation for IF...THEN...something else
    // ========================================================================
    
    public readonly bool IsTrue()
    {
        return Type == BazzValueType.Number 
            ? NumValue != 0 
            : !string.IsNullOrEmpty(StringValue);
    }

    // ========================================================================
    // Debug da output
    // ========================================================================
    
    public override readonly string ToString()
    {
        return Type == BazzValueType.Number 
            ? NumValue.ToString(System.Globalization.CultureInfo.InvariantCulture)
            : $"\"{StringValue}\"";
    }
}
