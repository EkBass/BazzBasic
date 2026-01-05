/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Graphics\Graphics.cs
 Graphics system for SDL2 endering

 Licence: MIT
*/

using SDL2;

namespace BazzBasic.Graphics;

public static class Graphics
{
    private static IntPtr window = IntPtr.Zero;
    private static IntPtr renderer = IntPtr.Zero;
    private static bool initialized = false;
    
    // Screen dimensions
    private static int screenWidth = 640;
    private static int screenHeight = 480;
    
    // Current drawing color (RGBA)
    private static byte currentR = 255;
    private static byte currentG = 255;
    private static byte currentB = 255;
    private static byte currentA = 255;
    
    // Background color (RGBA)
    private static byte bgR = 0;
    private static byte bgG = 0;
    private static byte bgB = 0;
    private static byte bgA = 255;
    
    // Text cursor position (for LOCATE command)
    private static int cursorRow = 0;
    private static int cursorColumn = 0;
    
    // Mouse state
    private static int mouseX = 0;
    private static int mouseY = 0;
    private static uint mouseButtons = 0;
    
    // Keyboard state
    private static int lastKeyPressed = 0;
    
    // Screen lock (for double buffering)
    private static bool screenLocked = false;
    
    // Screen dimensions in text mode (80x30 for 640x480 with 8x8 font, adjusted for 8x16)
    private static int textRows = 60;     // 480 / 8
    private static int textColumns = 80;  // 640 / 8
    
    // Character dimensions (for text mode emulation)
    private static readonly int charWidth = 8;
    private static readonly int charHeight = 8;
    
    // Initialise SDL2 stuff

    public static void Initialize(int width = 640, int height = 480, string title = "BazzBasic Graphics")
    {
        if (initialized)
            return;
            
        if (SDL.SDL_Init(SDL.SDL_INIT_VIDEO) < 0)
        {
            throw new Exception($"SDL could not initialize! SDL Error: {SDL.SDL_GetErrorString()}");
        }
        
        screenWidth = width;
        screenHeight = height;
        
        window = SDL.SDL_CreateWindow(
            title,
            SDL.SDL_WINDOWPOS_CENTERED,
            SDL.SDL_WINDOWPOS_CENTERED,
            width,
            height,
            SDL.SDL_WindowFlags.SDL_WINDOW_SHOWN
        );
        
        if (window == IntPtr.Zero)
        {
            SDL.SDL_Quit();
            throw new Exception($"Window could not be created! SDL Error: {SDL.SDL_GetErrorString()}");
        }
        
        renderer = SDL.SDL_CreateRenderer(
            window,
            -1,
            SDL.SDL_RendererFlags.SDL_RENDERER_ACCELERATED | SDL.SDL_RendererFlags.SDL_RENDERER_PRESENTVSYNC
        );
        
        if (renderer == IntPtr.Zero)
        {
            SDL.SDL_DestroyWindow(window);
            SDL.SDL_Quit();
            throw new Exception($"Renderer could not be created! SDL Error: {SDL.SDL_GetErrorString()}");
        }
        
        initialized = true;
        
        // Clear screen as black
        Clear();
    }
    
    // Close SDL2 shit
    public static void Shutdown()
    {
        if (!initialized)
            return;
            
        if (renderer != IntPtr.Zero)
        {
            SDL.SDL_DestroyRenderer(renderer);
            renderer = IntPtr.Zero;
        }
        
        if (window != IntPtr.Zero)
        {
            SDL.SDL_DestroyWindow(window);
            window = IntPtr.Zero;
        }
        
        SDL.SDL_Quit();
        initialized = false;
    }
    
    // if graphics are initialized
    public static bool IsInitialized => initialized;
    
    // SDL renderer for shitty stuff
    public static IntPtr Renderer => renderer;
    
    // clear screen with background color
    public static void Clear()
    {
        if (!initialized) return;
        
        SDL.SDL_SetRenderDrawColor(renderer, bgR, bgG, bgB, bgA);
        SDL.SDL_RenderClear(renderer);
        SDL.SDL_RenderPresent(renderer);
    }
    
    // Set pixel to x, y with current color
    public static void SetPixel(int x, int y)
    {
        if (!initialized) return;
        
        SDL.SDL_SetRenderDrawColor(renderer, currentR, currentG, currentB, currentA);
        SDL.SDL_RenderDrawPoint(renderer, x, y);
    }
    
    // Draw a line from x1, y1 to x2, y2
    public static void DrawLine(int x1, int y1, int x2, int y2)
    {
        if (!initialized) return;
        
        SDL.SDL_SetRenderDrawColor(renderer, currentR, currentG, currentB, currentA);
        SDL.SDL_RenderDrawLine(renderer, x1, y1, x2, y2);
    }
    
    // Draw  rectangle
    public static void DrawRect(int x, int y, int width, int height, bool filled = false)
    {
        if (!initialized) return;
        
        SDL.SDL_Rect rect = new SDL.SDL_Rect { x = x, y = y, w = width, h = height };
        SDL.SDL_SetRenderDrawColor(renderer, currentR, currentG, currentB, currentA);
        
        if (filled)
            SDL.SDL_RenderFillRect(renderer, ref rect);
        else
            SDL.SDL_RenderDrawRect(renderer, ref rect);
    }
    
    // Draw a circle using midpoint circle alg.
    public static void DrawCircle(int centerX, int centerY, int radius, bool filled = false)
    {
        if (!initialized) return;
        
        SDL.SDL_SetRenderDrawColor(renderer, currentR, currentG, currentB, currentA);
        
        if (filled)
        {
            // filled circle
            for (int y = -radius; y <= radius; y++)
            {
                int x = (int)Math.Sqrt(radius * radius - y * y);
                SDL.SDL_RenderDrawLine(renderer, centerX - x, centerY + y, centerX + x, centerY + y);
            }
        }
        else
        {
            int x = radius;
            int y = 0;
            int err = 0;
            
            while (x >= y)
            {
                SDL.SDL_RenderDrawPoint(renderer, centerX + x, centerY + y);
                SDL.SDL_RenderDrawPoint(renderer, centerX + y, centerY + x);
                SDL.SDL_RenderDrawPoint(renderer, centerX - y, centerY + x);
                SDL.SDL_RenderDrawPoint(renderer, centerX - x, centerY + y);
                SDL.SDL_RenderDrawPoint(renderer, centerX - x, centerY - y);
                SDL.SDL_RenderDrawPoint(renderer, centerX - y, centerY - x);
                SDL.SDL_RenderDrawPoint(renderer, centerX + y, centerY - x);
                SDL.SDL_RenderDrawPoint(renderer, centerX + x, centerY - y);
                
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
    
    // Set draw color from RGB
    public static void SetColor(int r, int g, int b, int a = 255)
    {
        currentR = (byte)Math.Clamp(r, 0, 255);
        currentG = (byte)Math.Clamp(g, 0, 255);
        currentB = (byte)Math.Clamp(b, 0, 255);
        currentA = (byte)Math.Clamp(a, 0, 255);
    }
    
    // background color from RGB
    public static void SetBackgroundColor(int r, int g, int b, int a = 255)
    {
        bgR = (byte)Math.Clamp(r, 0, 255);
        bgG = (byte)Math.Clamp(g, 0, 255);
        bgB = (byte)Math.Clamp(b, 0, 255);
        bgA = (byte)Math.Clamp(a, 0, 255);
    }
    
    // color from predefined default color index 0-15
    public static void SetColorFromIndex(int colorIndex)
    {
        // Classic BASIC 16-color palette (EGA/VGA colors)
        // This almost made me mad, those colors are weird as hell
        var (r, g, b) = colorIndex switch
        {
            0 => (0, 0, 0),         // Black
            1 => (0, 0, 170),       // Blue
            2 => (0, 170, 0),       // Green
            3 => (0, 170, 170),     // Cyan
            4 => (170, 0, 0),       // Red
            5 => (170, 0, 170),     // Magenta
            6 => (170, 85, 0),      // Brown
            7 => (170, 170, 170),   // Light Gray
            8 => (85, 85, 85),      // Dark Gray
            9 => (85, 85, 255),     // Light Blue
            10 => (85, 255, 85),    // Light Green
            11 => (85, 255, 255),   // Light Cyan
            12 => (255, 85, 85),    // Light Red
            13 => (255, 85, 255),   // Light Magenta
            14 => (255, 255, 85),   // Yellow... kind of
            15 => (255, 255, 255),  // White
            _ => (255, 255, 255)    // Default to white
        };
        
        SetColor(r, g, b);
    }
    
    // Present the rendered frame to screen
    public static void Present()
    {
        if (!initialized || screenLocked) return;
        SDL.SDL_RenderPresent(renderer);
    }
    
    // Set screen lock state (for manual double buffering) When locked, Present() calls are ignored until unlocked
    public static void SetScreenLock(bool locked)
    {
        screenLocked = locked;
        
        // f unlocking, present immediately to show buffered content
        if (!locked && initialized)
        {
            SDL.SDL_RenderPresent(renderer);
        }
    }
    
    // Process SDL events (call this in main loop) // Returns false if quit event is received
    public static bool ProcessEvents()
    {
        if (!initialized) return true;
        
        while (SDL.SDL_PollEvent(out SDL.SDL_Event e) != 0)
        {
            if (e.type == SDL.SDL_EventType.SDL_QUIT)
            {
                return false;
            }
            else if (e.type == SDL.SDL_EventType.SDL_KEYDOWN)
            {
                // Store the last key press
                lastKeyPressed = MapSDLKeyToBasic(e.key.keysym.sym);
            }
        }
        
        return true;
    }
    
    // Set text cursor position (for LOCATE command)
    public static void SetCursorPosition(int row, int column)
    {
        cursorRow = Math.Clamp(row, 0, textRows - 1);
        cursorColumn = Math.Clamp(column, 0, textColumns - 1);
    }
    
    // Print text at current cursor position
    public static void Print(string text, bool newline = true)
    {
        if (!initialized) return;
        
        foreach (char c in text)
        {
            if (c == '\n' || cursorColumn >= textColumns)
            {
                cursorColumn = 0;
                cursorRow++;
                
                // scroll if ahve to
                if (cursorRow >= textRows)
                {
                    ScrollUp();
                    cursorRow = textRows - 1;
                }
                
                if (c == '\n') continue;
            }
            
            int x = cursorColumn * charWidth;
            int y = cursorRow * charHeight;
            
            BitmapFont.DrawChar(renderer, c, x, y, currentR, currentG, currentB);
            cursorColumn++;
        }
        
        if (newline)
        {
            cursorColumn = 0;
            cursorRow++;
            
            if (cursorRow >= textRows)
            {
                ScrollUp();
                cursorRow = textRows - 1;
            }
        }
        
        SDL.SDL_RenderPresent(renderer);
    }
    
    // Stupid simple scroll screen up by one line
    private static void ScrollUp()
    {
        // For now, just clear the screen when scrolling
        // A proper implementation would copy pixels upward, just as I am not doing it

        SDL.SDL_SetRenderDrawColor(renderer, bgR, bgG, bgB, bgA);
        SDL.SDL_RenderClear(renderer);
        cursorRow = 0;
    }
    
    // current screen width
    public static int GetWidth() => screenWidth;
    
    // current screen heihgt
    public static int GetHeight() => screenHeight;
    
    // ========================================================================
    // Mouse stuff
    // ========================================================================
    
    //current mouse X position
    public static int MouseX => mouseX;
    
    // current mouse Y position
    public static int MouseY => mouseY;
    
    // current mouse button state (bit flags: 1=left, 2=middle, 4=right)
    public static int MouseButtons => (int)mouseButtons;
    
    // Update mouse state from dsl2
    // Call this before reading mouse position/buttons
    public static void UpdateMouse()
    {
        if (!initialized)
        {
            mouseX = 0;
            mouseY = 0;
            mouseButtons = 0;
            return;
        }
        
        // Process SDL first to get latest mouse state
        ProcessEvents();
        
        int x = 0, y = 0;
        uint state = SDL.SDL_GetMouseState(out x, out y);
        mouseX = x;
        mouseY = y;
        mouseButtons = state;
    }
    
    // ========================================================================
    // Keyboard shit
    // ========================================================================
    
    // get last key pressed (and clear it) or return 0
    public static int GetLastKey()
    {
        if (!initialized) return 0;
        
        ProcessEvents();
        
        int key = lastKeyPressed;
        lastKeyPressed = 0; // Clear after reading
        return key;
    }
    
    // Map SDL key code to BASIC key code
    private static int MapSDLKeyToBasic(SDL.SDL_Keycode key)
    {
        return key switch
        {
            SDL.SDL_Keycode.SDLK_ESCAPE => 27,  // Almost as meaningfull as 42
            SDL.SDL_Keycode.SDLK_RETURN => 13,
            SDL.SDL_Keycode.SDLK_TAB => 9,
            SDL.SDL_Keycode.SDLK_BACKSPACE => 8,
            SDL.SDL_Keycode.SDLK_SPACE => 32,
            SDL.SDL_Keycode.SDLK_UP => 328,
            SDL.SDL_Keycode.SDLK_DOWN => 336,
            SDL.SDL_Keycode.SDLK_LEFT => 331,
            SDL.SDL_Keycode.SDLK_RIGHT => 333,
            SDL.SDL_Keycode.SDLK_INSERT => 338,
            SDL.SDL_Keycode.SDLK_DELETE => 339,
            SDL.SDL_Keycode.SDLK_HOME => 327,
            SDL.SDL_Keycode.SDLK_END => 335,
            SDL.SDL_Keycode.SDLK_PAGEUP => 329,
            SDL.SDL_Keycode.SDLK_PAGEDOWN => 337,
            SDL.SDL_Keycode.SDLK_F1 => 315,
            SDL.SDL_Keycode.SDLK_F2 => 316,
            SDL.SDL_Keycode.SDLK_F3 => 317,
            SDL.SDL_Keycode.SDLK_F4 => 318,
            SDL.SDL_Keycode.SDLK_F5 => 319,
            SDL.SDL_Keycode.SDLK_F6 => 320,
            SDL.SDL_Keycode.SDLK_F7 => 321,
            SDL.SDL_Keycode.SDLK_F8 => 322,
            SDL.SDL_Keycode.SDLK_F9 => 323,
            SDL.SDL_Keycode.SDLK_F10 => 324,
            SDL.SDL_Keycode.SDLK_F11 => 389,
            SDL.SDL_Keycode.SDLK_F12 => 390,
            _ => (int)key // For regular ASCII keys SDL2 matches,,, I think
        };
    }
    
    // Delay for specified milliseconds
    public static void Delay(int milliseconds)
    {
        SDL.SDL_Delay((uint)milliseconds);
    }
}
