/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Graphics\ShapeManager.cs
 Manages all shapes/sprites in the scene

 Licence: MIT
*/
using SDL2;

namespace BazzBasic.Graphics;

// Manages collection of shapes and theyr things
public static class ShapeManager
{
    private static Dictionary<string, Shape> shapes = new();
    private static int nextId = 1;
    
    // Create a new shape and return its ID
    public static string CreateShape(ShapeType type, double width, double height, int color)
    {
        string id = $"SHAPE{nextId++}";
        var shape = new Shape(id, type, width, height, color);
        shapes[id] = shape;
        return id;
    }
    
    // Load an image from file/create shape out of it
    public static string LoadImageShape(string filepath, IntPtr renderer)
    {
        // Load .BMP file
        IntPtr surface = SDL.SDL_LoadBMP(filepath);
        if (surface == IntPtr.Zero)
        {
            throw new Exception($"Failed to load image: {filepath}");
        }
        
        // create texture
        IntPtr texture = SDL.SDL_CreateTextureFromSurface(renderer, surface);
        SDL.SDL_FreeSurface(surface); // free surface after
        
        if (texture == IntPtr.Zero)
        {
            throw new Exception($"Failed to create texture from: {filepath}");
        }
        
        // QueryTexture dimensions
        SDL.SDL_QueryTexture(texture, out _, out _, out int w, out int h);
        
        // Create shape
        string id = $"SHAPE{nextId++}";
        var shape = new Shape(id, ShapeType.Image, w, h, 0)
        {
            ImageTexture = texture,
            ImagePath = filepath
        };
        shapes[id] = shape;
        return id;
    }
    
    // Shape by ID
    public static Shape? GetShape(string id)
    {
        return shapes.TryGetValue(id, out Shape? shape) ? shape : null;
    }
    
    // Move shape
    public static void MoveShape(string id, double x, double y)
    {
        if (shapes.TryGetValue(id, out Shape? shape))
        {
            shape.X = x;
            shape.Y = y;
        }
    }
    
    // Rotate shape to angle (deg)
    public static void RotateShape(string id, double angle)
    {
        if (shapes.TryGetValue(id, out Shape? shape))
        {
            shape.Rotation = angle;
        }
    }
    
    // Scale shape
    public static void ScaleShape(string id, double scale)
    {
        if (shapes.TryGetValue(id, out Shape? shape))
        {
            shape.Scale = Math.Max(0.01, scale); // Prevent zero/negative scale
        }
    }
    
    // Show shape
    public static void ShowShape(string id)
    {
        if (shapes.TryGetValue(id, out Shape? shape))
        {
            shape.Visible = true;
        }
    }
    
    // Hide 
    public static void HideShape(string id)
    {
        if (shapes.TryGetValue(id, out Shape? shape))
        {
            shape.Visible = false;
        }
    }
    
    // Remove
    public static void RemoveShape(string id)
    {
        if (shapes.TryGetValue(id, out Shape? shape))
        {
            // clean up if its an image
            if (shape.ImageTexture != IntPtr.Zero)
            {
                SDL.SDL_DestroyTexture(shape.ImageTexture);
            }
        }
        shapes.Remove(id);
    }
    
    // Clear em all
    public static void ClearAll()
    {
        // Imagetextures
        foreach (var shape in shapes.Values)
        {
            if (shape.ImageTexture != IntPtr.Zero)
            {
                SDL.SDL_DestroyTexture(shape.ImageTexture);
            }
        }
        shapes.Clear();
        nextId = 1;
    }
    
    // Draw shape
    public static void DrawShape(string id, IntPtr renderer)
    {
        if (!shapes.TryGetValue(id, out Shape? shape) || !shape.Visible)
            return;
        
        RenderShape(shape, renderer);
    }
    
    // Draw all shapes
    public static void DrawAllShapes(IntPtr renderer)
    {
        foreach (var shape in shapes.Values)
        {
            if (shape.Visible)
                RenderShape(shape, renderer);
        }
    }
    
    // Render a shape with transformations
    private static void RenderShape(Shape shape, IntPtr renderer)
    {
        int centerX = (int)shape.X;
        int centerY = (int)shape.Y;
        int w = (int)shape.ScaledWidth;
        int h = (int)shape.ScaledHeight;
        
        // IF image shapes
        if (shape.Type == ShapeType.Image && shape.ImageTexture != IntPtr.Zero)
        {
            SDL.SDL_Rect dstrect = new SDL.SDL_Rect
            {
                x = centerX - w / 2,
                y = centerY - h / 2,
                w = w,
                h = h
            };

            // This prolly is not most elegant way but whatever
            SDL.SDL_RenderCopyEx(
                renderer,
                shape.ImageTexture,
                IntPtr.Zero,        // srcrect (null = whole texture)
                ref dstrect,        // dstrect
                shape.Rotation,     // angle
                IntPtr.Zero,        // center (null = center of dstrect)
                0                   // flip (0 = none)
            );
            return;
        }
        
        // Volor for primitive shapes
        int r = (shape.Color >> 16) & 0xFF;
        int g = (shape.Color >> 8) & 0xFF;
        int b = shape.Color & 0xFF;
        SDL.SDL_SetRenderDrawColor(renderer, (byte)r, (byte)g, (byte)b, 255);
        
        switch (shape.Type)
        {
            case ShapeType.Rectangle:
                DrawRotatedRectangle(renderer, centerX, centerY, w, h, shape.Rotation, shape.Filled);
                break;
                
            case ShapeType.Circle:
                DrawCircle(renderer, centerX, centerY, (int)(w / 2.0), shape.Filled);
                break;
                
            case ShapeType.Triangle:
                DrawRotatedTriangle(renderer, centerX, centerY, w, h, shape.Rotation, shape.Filled);
                break;
        }
    }
    
    // Draw a rotated rectangle
    private static void DrawRotatedRectangle(IntPtr renderer, int cx, int cy, int w, int h, double angle, bool filled)
    {
        if (angle == 0)
        {
            // No rotation - peace of cake
            SDL.SDL_Rect rect = new SDL.SDL_Rect { 
                x = cx - w / 2, 
                y = cy - h / 2, 
                w = w, 
                h = h 
            };
            
            if (filled)
                SDL.SDL_RenderFillRect(renderer, ref rect);
            else
                SDL.SDL_RenderDrawRect(renderer, ref rect);
            return;
        }
        
        // Rotated rectangle
        double rad = angle * Math.PI / 180.0;
        double cos = Math.Cos(rad);
        double sin = Math.Sin(rad);
        
        // corner points. 
        int hw = w / 2;
        int hh = h / 2;
        
        var corners = new (int x, int y)[4];
        corners[0] = (cx + (int)(-hw * cos - (-hh) * sin), cy + (int)(-hw * sin + (-hh) * cos)); // Top-left
        corners[1] = (cx + (int)(hw * cos - (-hh) * sin), cy + (int)(hw * sin + (-hh) * cos));   // Top-right
        corners[2] = (cx + (int)(hw * cos - hh * sin), cy + (int)(hw * sin + hh * cos));         // Bottom-right
        corners[3] = (cx + (int)(-hw * cos - hh * sin), cy + (int)(-hw * sin + hh * cos));       // Bottom-left
        
        if (filled)
        {
            // Fill with scanlines, very simplified
            for (int i = 0; i < 4; i++)
            {
                int next = (i + 1) % 4;
                SDL.SDL_RenderDrawLine(renderer, corners[i].x, corners[i].y, corners[next].x, corners[next].y);
            }
        }
        else
        {
            // outline
            for (int i = 0; i < 4; i++)
            {
                int next = (i + 1) % 4;
                SDL.SDL_RenderDrawLine(renderer, corners[i].x, corners[i].y, corners[next].x, corners[next].y);
            }
        }
    }
    
    // circle
    private static void DrawCircle(IntPtr renderer, int cx, int cy, int radius, bool filled)
    {
        if (filled)
        {
            // Filled circle
            for (int y = -radius; y <= radius; y++)
            {
                int x = (int)Math.Sqrt(radius * radius - y * y);
                SDL.SDL_RenderDrawLine(renderer, cx - x, cy + y, cx + x, cy + y);
            }
        }
        else
        {
            // Circle outline using midpoint circle algorythm
            int x = radius;
            int y = 0;
            int err = 0;
            
            while (x >= y)
            {
                SDL.SDL_RenderDrawPoint(renderer, cx + x, cy + y);
                SDL.SDL_RenderDrawPoint(renderer, cx + y, cy + x);
                SDL.SDL_RenderDrawPoint(renderer, cx - y, cy + x);
                SDL.SDL_RenderDrawPoint(renderer, cx - x, cy + y);
                SDL.SDL_RenderDrawPoint(renderer, cx - x, cy - y);
                SDL.SDL_RenderDrawPoint(renderer, cx - y, cy - x);
                SDL.SDL_RenderDrawPoint(renderer, cx + y, cy - x);
                SDL.SDL_RenderDrawPoint(renderer, cx + x, cy - y);
                
                y += 1;
                err += 1 + 2 * y;
                if (2 * (err - x) + 1 > 0)
                {
                    x -= 1;
                    err += 1 - 2 * x;
                }
            }
        }
    }
    
    // Draw a rotated triangle
    private static void DrawRotatedTriangle(IntPtr renderer, int cx, int cy, int w, int h, double angle, bool filled)
    {
        double rad = angle * Math.PI / 180.0;
        double cos = Math.Cos(rad);
        double sin = Math.Sin(rad);
        
        // triangle points (pointing up)
        var points = new (double x, double y)[3];
        points[0] = (0, -h / 2.0);           // Top
        points[1] = (-w / 2.0, h / 2.0);     // Bottom-left
        points[2] = (w / 2.0, h / 2.0);      // Bottom-right
        
        // rotate and translate
        var rotated = new (int x, int y)[3];
        for (int i = 0; i < 3; i++)
        {
            double rx = points[i].x * cos - points[i].y * sin;
            double ry = points[i].x * sin + points[i].y * cos;
            rotated[i] = (cx + (int)rx, cy + (int)ry);
        }
        
        // draw triangle
        SDL.SDL_RenderDrawLine(renderer, rotated[0].x, rotated[0].y, rotated[1].x, rotated[1].y);
        SDL.SDL_RenderDrawLine(renderer, rotated[1].x, rotated[1].y, rotated[2].x, rotated[2].y);
        SDL.SDL_RenderDrawLine(renderer, rotated[2].x, rotated[2].y, rotated[0].x, rotated[0].y);
        
        if (filled)
        {
            // Simple fill, could be improved but Im tirred now
            // For now just draw multiple lines from center
            for (int i = 0; i < 3; i++)
            {
                SDL.SDL_RenderDrawLine(renderer, cx, cy, rotated[i].x, rotated[i].y);
            }
        }
    }
}
