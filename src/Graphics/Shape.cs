/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Graphics\Shape.cs
 Shape/sprite with position, rotation, scale, color

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

namespace BazzBasic.Graphics;

// type enumeration
public enum ShapeType
{
    Rectangle,
    Circle,
    Triangle,
    Image  // For future image loading which may or may not happen
}

// Represents a drawable shape/sprite with transformation properties
public class Shape
{
    public string Id { get; set; }
    public ShapeType Type { get; set; }
    
    // Pos
    public double X { get; set; }
    public double Y { get; set; }
    
    // Size
    public double Width { get; set; }
    public double Height { get; set; }
    
    // Transforman
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

    // actual width after scaling
    public double ScaledWidth => Width * Scale;
    
    // the actual height after scaling
    public double ScaledHeight => Height * Scale;
}
