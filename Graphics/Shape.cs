// ============================================================================
// BazzBasic - Shape (Sprite/Shape object)
// Individual shape/sprite with position, rotation, scale, color
// ============================================================================

namespace BazzBasic.Graphics;

/// <summary>
/// Shape type enumeration
/// </summary>
public enum ShapeType
{
    Rectangle,
    Circle,
    Triangle,
    Image  // For future image loading
}

/// <summary>
/// Represents a drawable shape/sprite with transformation properties
/// </summary>
public class Shape
{
    public string Id { get; set; }
    public ShapeType Type { get; set; }
    
    // Position
    public double X { get; set; }
    public double Y { get; set; }
    
    // Size
    public double Width { get; set; }
    public double Height { get; set; }
    
    // Transformation
    public double Rotation { get; set; } // Degrees
    public double Scale { get; set; } = 1.0;
    
    // Appearance
    public int Color { get; set; }
    public bool Visible { get; set; } = true;
    public bool Filled { get; set; } = true;
    
    // Image data
    public IntPtr ImageTexture { get; set; } = IntPtr.Zero;
    public string? ImagePath { get; set; }
    
    public Shape(string id, ShapeType type, double width, double height, int color)
    {
        Id = id;
        Type = type;
        Width = width;
        Height = height;
        Color = color;
        X = 0;
        Y = 0;
        Rotation = 0;
        Scale = 1.0;
    }
    
    /// <summary>
    /// Get the actual width after scaling
    /// </summary>
    public double ScaledWidth => Width * Scale;
    
    /// <summary>
    /// Get the actual height after scaling
    /// </summary>
    public double ScaledHeight => Height * Scale;
}
