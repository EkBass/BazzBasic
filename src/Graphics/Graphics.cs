/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Graphics\Graphics.cs
 Graphics system for SDL2 endering

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
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
    private const int textRows = 60;     // 480 / 8
    private const int textColumns = 80;  // 640 / 8

    // Character dimensions (for text mode emulation)
    private const int charWidth = 8;
    private const int charHeight = 8;
    
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

        _ = SDL.SDL_SetRenderDrawColor(renderer, bgR, bgG, bgB, bgA);
        _ = SDL.SDL_RenderClear(renderer);
        SDL.SDL_RenderPresent(renderer);
    }
    
    // Set pixel to x, y with current color
    public static void SetPixel(int x, int y)
    {
        if (!initialized) return;
        
        _ = SDL.SDL_SetRenderDrawColor(renderer, currentR, currentG, currentB, currentA);
        _ = SDL.SDL_RenderDrawPoint(renderer, x, y);
    }
    
    // Draw a line from x1, y1 to x2, y2
    public static void DrawLine(int x1, int y1, int x2, int y2)
    {
        if (!initialized) return;

        _ = SDL.SDL_SetRenderDrawColor(renderer, currentR, currentG, currentB, currentA);
        _ = SDL.SDL_RenderDrawLine(renderer, x1, y1, x2, y2);
    }
    
    // Draw  rectangle
    public static void DrawRect(int x, int y, int width, int height, bool filled = false)
    {
        if (!initialized) return;
        
        SDL.SDL_Rect rect = new() { x = x, y = y, w = width, h = height };
        _ = SDL.SDL_SetRenderDrawColor(renderer, currentR, currentG, currentB, currentA);
        
        if (filled)
            _ = SDL.SDL_RenderFillRect(renderer, ref rect);
        else
            _ = SDL.SDL_RenderDrawRect(renderer, ref rect);
    }
    
    // Draw a circle using midpoint circle alg.
    public static void DrawCircle(int centerX, int centerY, int radius, bool filled = false)
    {
        if (!initialized) return;

        _ = SDL.SDL_SetRenderDrawColor(renderer, currentR, currentG, currentB, currentA);
        
        if (filled)
        {
            // filled circle
            for (int y = -radius; y <= radius; y++)
            {
                int x = (int)Math.Sqrt(radius * radius - y * y);
                _ = SDL.SDL_RenderDrawLine(renderer, centerX - x, centerY + y, centerX + x, centerY + y);
            }
        }
        else
        {
            int x = radius;
            int y = 0;
            int err = 0;
            
            while (x >= y)
            {
                _ = SDL.SDL_RenderDrawPoint(renderer, centerX + x, centerY + y);
                _ = SDL.SDL_RenderDrawPoint(renderer, centerX + y, centerY + x);
                _ = SDL.SDL_RenderDrawPoint(renderer, centerX - y, centerY + x);
                _ = SDL.SDL_RenderDrawPoint(renderer, centerX - x, centerY + y);
                _ = SDL.SDL_RenderDrawPoint(renderer, centerX - x, centerY - y);
                _ = SDL.SDL_RenderDrawPoint(renderer, centerX - y, centerY - x);
                _ = SDL.SDL_RenderDrawPoint(renderer, centerX + y, centerY - x);
                _ = SDL.SDL_RenderDrawPoint(renderer, centerX + x, centerY - y);
                
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
            
            BitmapFont.DrawChar(renderer, c, x, y, currentR, currentG, currentB, bgR, bgG, bgB);
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

        _ = SDL.SDL_SetRenderDrawColor(renderer, bgR, bgG, bgB, bgA);
        _ = SDL.SDL_RenderClear(renderer);
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


        uint state = SDL.SDL_GetMouseState(out int x, out int y);
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

    private static readonly Dictionary<int, SDL.SDL_Scancode> _keyMap = new()
    {
        // Alphabets (BazzBasic ASCII -> SDL Scancode)
        [65] = SDL.SDL_Scancode.SDL_SCANCODE_A,
        [66] = SDL.SDL_Scancode.SDL_SCANCODE_B,
        [67] = SDL.SDL_Scancode.SDL_SCANCODE_C,
        [68] = SDL.SDL_Scancode.SDL_SCANCODE_D,
        [69] = SDL.SDL_Scancode.SDL_SCANCODE_E,
        [70] = SDL.SDL_Scancode.SDL_SCANCODE_F,
        [71] = SDL.SDL_Scancode.SDL_SCANCODE_G,
        [72] = SDL.SDL_Scancode.SDL_SCANCODE_H,
        [73] = SDL.SDL_Scancode.SDL_SCANCODE_I,
        [74] = SDL.SDL_Scancode.SDL_SCANCODE_J,
        [75] = SDL.SDL_Scancode.SDL_SCANCODE_K,
        [76] = SDL.SDL_Scancode.SDL_SCANCODE_L,
        [77] = SDL.SDL_Scancode.SDL_SCANCODE_M,
        [78] = SDL.SDL_Scancode.SDL_SCANCODE_N,
        [79] = SDL.SDL_Scancode.SDL_SCANCODE_O,
        [80] = SDL.SDL_Scancode.SDL_SCANCODE_P,
        [81] = SDL.SDL_Scancode.SDL_SCANCODE_Q,
        [82] = SDL.SDL_Scancode.SDL_SCANCODE_R,
        [83] = SDL.SDL_Scancode.SDL_SCANCODE_S,
        [84] = SDL.SDL_Scancode.SDL_SCANCODE_T,
        [85] = SDL.SDL_Scancode.SDL_SCANCODE_U,
        [86] = SDL.SDL_Scancode.SDL_SCANCODE_V,
        [87] = SDL.SDL_Scancode.SDL_SCANCODE_W,
        [88] = SDL.SDL_Scancode.SDL_SCANCODE_X,
        [89] = SDL.SDL_Scancode.SDL_SCANCODE_Y,
        [90] = SDL.SDL_Scancode.SDL_SCANCODE_Z,
        // Numbers
        [48] = SDL.SDL_Scancode.SDL_SCANCODE_0,
        [49] = SDL.SDL_Scancode.SDL_SCANCODE_1,
        [50] = SDL.SDL_Scancode.SDL_SCANCODE_2,
        [51] = SDL.SDL_Scancode.SDL_SCANCODE_3,
        [52] = SDL.SDL_Scancode.SDL_SCANCODE_4,
        [53] = SDL.SDL_Scancode.SDL_SCANCODE_5,
        [54] = SDL.SDL_Scancode.SDL_SCANCODE_6,
        [55] = SDL.SDL_Scancode.SDL_SCANCODE_7,
        [56] = SDL.SDL_Scancode.SDL_SCANCODE_8,
        [57] = SDL.SDL_Scancode.SDL_SCANCODE_9,
        // Special keys
        [8] = SDL.SDL_Scancode.SDL_SCANCODE_BACKSPACE,
        [9] = SDL.SDL_Scancode.SDL_SCANCODE_TAB,
        [13] = SDL.SDL_Scancode.SDL_SCANCODE_RETURN,
        [27] = SDL.SDL_Scancode.SDL_SCANCODE_ESCAPE,
        [32] = SDL.SDL_Scancode.SDL_SCANCODE_SPACE,
        // Arrow keys
        [328] = SDL.SDL_Scancode.SDL_SCANCODE_UP,
        [336] = SDL.SDL_Scancode.SDL_SCANCODE_DOWN,
        [331] = SDL.SDL_Scancode.SDL_SCANCODE_LEFT,
        [333] = SDL.SDL_Scancode.SDL_SCANCODE_RIGHT,
        // Navigation
        [338] = SDL.SDL_Scancode.SDL_SCANCODE_INSERT,
        [339] = SDL.SDL_Scancode.SDL_SCANCODE_DELETE,
        [327] = SDL.SDL_Scancode.SDL_SCANCODE_HOME,
        [335] = SDL.SDL_Scancode.SDL_SCANCODE_END,
        [329] = SDL.SDL_Scancode.SDL_SCANCODE_PAGEUP,
        [337] = SDL.SDL_Scancode.SDL_SCANCODE_PAGEDOWN,
        // Function keys
        [315] = SDL.SDL_Scancode.SDL_SCANCODE_F1,
        [316] = SDL.SDL_Scancode.SDL_SCANCODE_F2,
        [317] = SDL.SDL_Scancode.SDL_SCANCODE_F3,
        [318] = SDL.SDL_Scancode.SDL_SCANCODE_F4,
        [319] = SDL.SDL_Scancode.SDL_SCANCODE_F5,
        [320] = SDL.SDL_Scancode.SDL_SCANCODE_F6,
        [321] = SDL.SDL_Scancode.SDL_SCANCODE_F7,
        [322] = SDL.SDL_Scancode.SDL_SCANCODE_F8,
        [323] = SDL.SDL_Scancode.SDL_SCANCODE_F9,
        [324] = SDL.SDL_Scancode.SDL_SCANCODE_F10,
        [389] = SDL.SDL_Scancode.SDL_SCANCODE_F11,
        [390] = SDL.SDL_Scancode.SDL_SCANCODE_F12,
        // Numpad
        [256] = SDL.SDL_Scancode.SDL_SCANCODE_KP_0,
        [257] = SDL.SDL_Scancode.SDL_SCANCODE_KP_1,
        [258] = SDL.SDL_Scancode.SDL_SCANCODE_KP_2,
        [259] = SDL.SDL_Scancode.SDL_SCANCODE_KP_3,
        [260] = SDL.SDL_Scancode.SDL_SCANCODE_KP_4,
        [261] = SDL.SDL_Scancode.SDL_SCANCODE_KP_5,
        [262] = SDL.SDL_Scancode.SDL_SCANCODE_KP_6,
        [263] = SDL.SDL_Scancode.SDL_SCANCODE_KP_7,
        [264] = SDL.SDL_Scancode.SDL_SCANCODE_KP_8,
        [265] = SDL.SDL_Scancode.SDL_SCANCODE_KP_9,
        // Modifiers
        [340] = SDL.SDL_Scancode.SDL_SCANCODE_LSHIFT,
        [344] = SDL.SDL_Scancode.SDL_SCANCODE_RSHIFT,
        [341] = SDL.SDL_Scancode.SDL_SCANCODE_LCTRL,
        [345] = SDL.SDL_Scancode.SDL_SCANCODE_RCTRL,
        [342] = SDL.SDL_Scancode.SDL_SCANCODE_LALT,
        [346] = SDL.SDL_Scancode.SDL_SCANCODE_RALT,
        [343] = SDL.SDL_Scancode.SDL_SCANCODE_LGUI,
        [347] = SDL.SDL_Scancode.SDL_SCANCODE_RGUI,
        // Punctuation
        [44] = SDL.SDL_Scancode.SDL_SCANCODE_COMMA,
        [46] = SDL.SDL_Scancode.SDL_SCANCODE_PERIOD,
        [45] = SDL.SDL_Scancode.SDL_SCANCODE_MINUS,
        [61] = SDL.SDL_Scancode.SDL_SCANCODE_EQUALS,
        [47] = SDL.SDL_Scancode.SDL_SCANCODE_SLASH,
        [92] = SDL.SDL_Scancode.SDL_SCANCODE_BACKSLASH,
        [96] = SDL.SDL_Scancode.SDL_SCANCODE_GRAVE,
        [91] = SDL.SDL_Scancode.SDL_SCANCODE_LEFTBRACKET,
        [93] = SDL.SDL_Scancode.SDL_SCANCODE_RIGHTBRACKET,
        [59] = SDL.SDL_Scancode.SDL_SCANCODE_SEMICOLON,
    };
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

    // ========================================================================
    // Is key currently down (for non-blocking input) - pass BASIC key code
    // ========================================================================
    public static bool IsKeyDown(int bazzKeyCode)
    {
        if (!_keyMap.TryGetValue(bazzKeyCode, out var scancode))
            return false;

        IntPtr state = SDL.SDL_GetKeyboardState(out _);
        unsafe
        {
            byte* keys = (byte*)state;
            return keys[(int)scancode] != 0;
        }
    }

    // ========================================================================
    // POINT command - Read pixel color at x, y (lazy approach)
    // ========================================================================

    public static int GetPixelColor(int x, int y)
    {
        if (!initialized) return 0;
        
        // Bounds check
        if (x < 0 || x >= screenWidth || y < 0 || y >= screenHeight)
            return 0;
        
        // Allocate buffer for single pixel (4 bytes for ARGB)
        byte[] pixelData = new byte[4];
        
        // Create rect for single pixel
        SDL.SDL_Rect rect = new() { x = x, y = y, w = 1, h = 1 };
        
        // Pin the byte array and get pointer
        System.Runtime.InteropServices.GCHandle handle = 
            System.Runtime.InteropServices.GCHandle.Alloc(pixelData, System.Runtime.InteropServices.GCHandleType.Pinned);
        
        try
        {
            IntPtr pixelPtr = handle.AddrOfPinnedObject();
            IntPtr rectPtr = System.Runtime.InteropServices.Marshal.AllocHGlobal(
                System.Runtime.InteropServices.Marshal.SizeOf<SDL.SDL_Rect>());
            
            try
            {
                System.Runtime.InteropServices.Marshal.StructureToPtr(rect, rectPtr, false);
                
                int result = SDL.SDL_RenderReadPixels(
                    renderer,
                    rectPtr,
                    SDL.SDL_PIXELFORMAT_ARGB8888,
                    pixelPtr,
                    4  // pitch = 4 bytes per pixel
                );
                
                if (result != 0)
                    return 0;
                
                // pixelData is ARGB format: [A, R, G, B] or [B, G, R, A] depending on endianness
                // SDL_PIXELFORMAT_ARGB8888: Alpha at highest byte, then R, G, B
                // On little-endian (Windows): bytes are B, G, R, A
                int r = pixelData[2];
                int g = pixelData[1];
                int b = pixelData[0];
                
                return (r << 16) | (g << 8) | b;
            }
            finally
            {
                System.Runtime.InteropServices.Marshal.FreeHGlobal(rectPtr);
            }
        }
        finally
        {
            handle.Free();
        }
    }

    // ========================================================================
    // Text Input for INPUT / LINE INPUT in graphics mode
    // Uses SDL KEYDOWN events with modifier state detection
    // ========================================================================

    // SDL2 KMOD constants (from SDL_keycode.h)
    private const ushort KMOD_LSHIFT = 0x0001;
    private const ushort KMOD_RSHIFT = 0x0002;
    private const ushort KMOD_SHIFT = KMOD_LSHIFT | KMOD_RSHIFT;

    public static string ReadLine(string prompt = "")
    {
        if (!initialized) return "";

        // Print prompt at current cursor position
        if (!string.IsNullOrEmpty(prompt))
        {
            Print(prompt, false);
        }

        // Remember where user input starts (for redraw on backspace)
        int inputStartCol = cursorColumn;
        int inputStartRow = cursorRow;

        string inputBuffer = "";
        bool inputActive = true;

        // Draw initial cursor
        DrawInputCursor();
        SDL.SDL_RenderPresent(renderer);

        while (inputActive)
        {
            while (SDL.SDL_PollEvent(out SDL.SDL_Event e) != 0)
            {
                if (e.type == SDL.SDL_EventType.SDL_QUIT)
                {
                    inputActive = false;
                    break;
                }
                else if (e.type == SDL.SDL_EventType.SDL_KEYDOWN)
                {
                    int keyVal = (int)e.key.keysym.sym;
                    bool shift = (e.key.keysym.mod & KMOD_SHIFT) != 0;

                    if (keyVal == 13) // RETURN
                    {
                        EraseCursor();
                        cursorColumn = 0;
                        cursorRow++;
                        if (cursorRow >= textRows)
                        {
                            ScrollUp();
                            cursorRow = textRows - 1;
                        }
                        inputActive = false;
                    }
                    else if (keyVal == 8) // BACKSPACE
                    {
                        if (inputBuffer.Length > 0)
                        {
                            inputBuffer = inputBuffer.Substring(0, inputBuffer.Length - 1);
                            RedrawInputArea(inputStartRow, inputStartCol, inputBuffer);
                        }
                    }
                    else if (keyVal == 27) // ESCAPE
                    {
                        inputBuffer = "";
                        RedrawInputArea(inputStartRow, inputStartCol, "");
                    }
                    else
                    {
                        char c = MapKeyToChar(keyVal, shift);
                        if (c != '\0')
                        {
                            inputBuffer += c;
                            EraseCursor();
                            Print(c.ToString(), false);
                            DrawInputCursor();
                            SDL.SDL_RenderPresent(renderer);
                        }
                    }
                }
            }

            SDL.SDL_Delay(10);
        }

        return inputBuffer;
    }

    // Map SDL keycode int value + shift state to a printable character
    // SDL2 keycodes for printable ASCII chars = their ASCII value (lowercase)
    private static char MapKeyToChar(int key, bool shift)
    {
        // Letters (a=97 to z=122)
        if (key >= 97 && key <= 122)
        {
            return shift ? (char)(key - 32) : (char)key;
        }

        // Space
        if (key == 32) return ' ';

        // Numbers (0=48 to 9=57)
        if (key >= 48 && key <= 57)
        {
            if (!shift) return (char)key;

            // Shift + number → symbols (US layout)
            return key switch
            {
                49 => '!', 50 => '@', 51 => '#', 52 => '$', 53 => '%',
                54 => '^', 55 => '&', 56 => '*', 57 => '(', 48 => ')',
                _ => '\0'
            };
        }

        // Punctuation keys (SDL keycodes = ASCII values)
        if (!shift)
        {
            return key switch
            {
                44 => ',',   // comma
                46 => '.',   // period
                45 => '-',   // minus
                61 => '=',   // equals
                47 => '/',   // slash
                92 => '\\',  // backslash
                59 => ';',   // semicolon
                39 => '\'',  // apostrophe/quote
                91 => '[',   // left bracket
                93 => ']',   // right bracket
                96 => '`',   // backtick
                _ => '\0'
            };
        }

        // Shift + punctuation
        return key switch
        {
            44 => '<', 46 => '>', 45 => '_', 61 => '+', 47 => '?',
            92 => '|', 59 => ':', 39 => '"', 91 => '{', 93 => '}', 96 => '~',
            _ => '\0'
        };
    }

    // Redraw the input area (clear old text and cursor, print new text + cursor)
    private static void RedrawInputArea(int startRow, int startCol, string text)
    {
        int clearX = startCol * charWidth;
        int clearY = startRow * charHeight;
        int clearW = (textColumns - startCol + 1) * charWidth;
        int clearH = charHeight;

        _ = SDL.SDL_SetRenderDrawColor(renderer, bgR, bgG, bgB, bgA);
        SDL.SDL_Rect clearRect = new() { x = clearX, y = clearY, w = clearW, h = clearH };
        _ = SDL.SDL_RenderFillRect(renderer, ref clearRect);

        cursorRow = startRow;
        cursorColumn = startCol;

        if (!string.IsNullOrEmpty(text))
        {
            foreach (char c in text)
            {
                if (cursorColumn >= textColumns)
                {
                    cursorColumn = 0;
                    cursorRow++;
                    if (cursorRow >= textRows)
                    {
                        ScrollUp();
                        cursorRow = textRows - 1;
                    }
                }

                int x = cursorColumn * charWidth;
                int y = cursorRow * charHeight;
                BitmapFont.DrawChar(renderer, c, x, y, currentR, currentG, currentB, bgR, bgG, bgB);
                cursorColumn++;
            }
        }

        DrawInputCursor();
        SDL.SDL_RenderPresent(renderer);
    }

    private static void DrawInputCursor()
    {
        int cx = cursorColumn * charWidth;
        int cy = cursorRow * charHeight;
        BitmapFont.DrawChar(renderer, '_', cx, cy, currentR, currentG, currentB, bgR, bgG, bgB);
    }

    private static void EraseCursor()
    {
        int cx = cursorColumn * charWidth;
        int cy = cursorRow * charHeight;
        _ = SDL.SDL_SetRenderDrawColor(renderer, bgR, bgG, bgB, bgA);
        SDL.SDL_Rect rect = new() { x = cx, y = cy, w = charWidth, h = charHeight };
        _ = SDL.SDL_RenderFillRect(renderer, ref rect);
        _ = SDL.SDL_SetRenderDrawColor(renderer, currentR, currentG, currentB, currentA);
    }

    // Enable or disable vertical synchronization (VSync)
    public static void SetVSync(bool enable)
    {
        if (!initialized)
            throw new InvalidOperationException("Graphics not initialized. Call SCREEN first.");

        // Destroy existing renderer
        if (renderer != IntPtr.Zero)
        {
            SDL.SDL_DestroyRenderer(renderer);
        }

        // Create new renderer with or without VSync
        var flags = SDL.SDL_RendererFlags.SDL_RENDERER_ACCELERATED;
        if (enable)
            flags |= SDL.SDL_RendererFlags.SDL_RENDERER_PRESENTVSYNC;

        renderer = SDL.SDL_CreateRenderer(
            window,
            -1,
            flags
        );

        if (renderer == IntPtr.Zero)
        {
            throw new Exception($"Renderer could not be recreated! SDL Error: {SDL.SDL_GetErrorString()}");
        }

        // Restore drawing state
        _= SDL.SDL_SetRenderDrawColor(renderer, currentR, currentG, currentB, currentA);
    }
}
