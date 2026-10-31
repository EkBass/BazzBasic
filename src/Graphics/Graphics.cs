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
using System.Runtime.InteropServices;

namespace BazzBasic.Graphics;

public static class Graphics
{
    // Win32: minimize console window when graphics mode starts
    [DllImport("kernel32.dll")] private static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]   private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")]   private static extern bool SetProcessDPIAware();
    private const int SW_MINIMIZE = 6;
    private const int SW_RESTORE  = 9;
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

    // ------------------------------------------------------------------------
    // Persistent canvas (30.10.2026)
    // All drawing goes to this render-target texture, never straight to the
    // window back buffer. PresentCanvas() copies it to the window. The back
    // buffer is undefined after SDL_RenderPresent, the canvas is not — so
    // POINT and SAVESCREEN always see what the program drew.
    // ------------------------------------------------------------------------
    private static IntPtr canvas = IntPtr.Zero;

    // POINT pixel cache: one SDL_RenderReadPixels of the whole canvas, then
    // POINT reads from memory. SetPixel writes through; every other draw
    // calls InvalidateCache().
    private static int[] pixelCache = Array.Empty<int>();
    private static bool cacheValid = false;

    // Present throttling: automatic presents (PSET, LINE, PRINT...) are shown at
    // most once per PRESENT_INTERVAL_MS. A skipped one is left pending and shown
    // by Tick(), Flush() or the next Present() that is due.
    private const long PRESENT_INTERVAL_MS = 16;
    private static bool presentPending = false;
    private static long lastPresentTicks = 0;

    // Set when the user closes the window (SDL_QUIT). The interpreter ends the
    // program cleanly when it sees this.
    private static bool quitRequested = false;
    public static bool QuitRequested => quitRequested;
    
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
        {
            // Reinitialize with new dimensions: destroy old renderer and window,
            // but keep SDL alive (no SDL_Quit / SDL_Init needed again).
            DestroyCanvas();
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
            initialized = false;
            // Fall through to create new window + renderer below
        }
        else
        {
            if (SDL.SDL_Init(SDL.SDL_INIT_VIDEO | SDL.SDL_INIT_AUDIO) < 0)
            {
                throw new Exception($"SDL could not initialize! SDL Error: {SDL.SDL_GetErrorString()}");
            }
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

        // Logical render size: all drawing maps to a virtual width x height canvas that
        // SDL scales to fit the real output (windowed OR fullscreen), preserving aspect
        // ratio with letterbox bars. Program coordinates stay identical in both modes.
        _ = SDL.SDL_RenderSetLogicalSize(renderer, width, height);

        // Persistent canvas — all drawing targets it from here on
        CreateCanvas();
        quitRequested = false;
        presentPending = false;
        
        initialized = true;

        // Initialize font system (Arial as default)
        string arialPath = FindArialFont();
        if (!string.IsNullOrEmpty(arialPath))
        {
            try { FontManager.Initialize(arialPath, 16); }
            catch { /* TTF optional — DRAWSTRING will error if called */ }
        }

        // Clear screen as black and bring window to front
        // Minimize console so it doesn't cover the SDL window
        ShowWindow(GetConsoleWindow(), SW_MINIMIZE);
        Clear();
        // Pump events a few times so Windows processes WM_PAINT and shows window content
        for (int i = 0; i < 5; i++)
        {
            SDL.SDL_PumpEvents();
            PresentCanvas();
            SDL.SDL_Delay(10);
        }
        SDL.SDL_RaiseWindow(window);
    }
    
    // Close SDL2 shit
    public static void Shutdown()
    {
        if (!initialized)
            return;

        DestroyCanvas();
            
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

        FontManager.Shutdown();

        // Restore console when graphics mode ends
        ShowWindow(GetConsoleWindow(), SW_RESTORE);
    }

    // if graphics are initialized
    public static bool IsInitialized => initialized;

    // (debug methods removed)
    
    // SDL renderer for shitty stuff
    public static IntPtr Renderer => renderer;
    
    // clear screen with background color
    public static void Clear()
    {
        if (!initialized) return;

        _ = SDL.SDL_SetRenderDrawColor(renderer, bgR, bgG, bgB, bgA);
        _ = SDL.SDL_RenderClear(renderer);
        InvalidateCache();
        Present();
    }
    
    // Set pixel to x, y with current color
    public static void SetPixel(int x, int y)
    {
        if (!initialized) return;
        
        _ = SDL.SDL_SetRenderDrawColor(renderer, currentR, currentG, currentB, currentA);
        _ = SDL.SDL_RenderDrawPoint(renderer, x, y);

        // Write-through: keep the POINT cache valid instead of invalidating it,
        // so read-modify-write loops (POINT then PSET) never re-read the canvas.
        if (cacheValid && x >= 0 && x < screenWidth && y >= 0 && y < screenHeight)
            pixelCache[y * screenWidth + x] = (currentR << 16) | (currentG << 8) | currentB;
    }
    
    // Draw a line from x1, y1 to x2, y2
    public static void DrawLine(int x1, int y1, int x2, int y2)
    {
        if (!initialized) return;

        InvalidateCache();
        _ = SDL.SDL_SetRenderDrawColor(renderer, currentR, currentG, currentB, currentA);
        _ = SDL.SDL_RenderDrawLine(renderer, x1, y1, x2, y2);
    }
    
    // Draw  rectangle
    public static void DrawRect(int x, int y, int width, int height, bool filled = false)
    {
        if (!initialized) return;
        
        InvalidateCache();
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

        InvalidateCache();
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
    
    // ========================================================================
    // Color resolution — central place to translate a BazzBasic color int
    // into actual (r, g, b) bytes. A color int is either:
    //   * RGB packed by RGB() with bit 24 (0x01000000) set as a flag, or
    //   * a palette index 0-15 (no flag bit; values outside 0-15 default to white).
    // The flag bit is necessary because raw packed RGB and palette indices
    // would otherwise collide (e.g. RGB(0,0,255) = 255 = palette index 255).
    // ========================================================================

    // Returns the (r, g, b) bytes for the 16-color EGA/VGA palette.
    // Index out of range defaults to white, matching SetColorFromIndex.
    private static (int r, int g, int b) GetPaletteRGB(int colorIndex)
    {
        return colorIndex switch
        {
            0  => (0, 0, 0),         // Black
            1  => (0, 0, 170),       // Blue
            2  => (0, 170, 0),       // Green
            3  => (0, 170, 170),     // Cyan
            4  => (170, 0, 0),       // Red
            5  => (170, 0, 170),     // Magenta
            6  => (170, 85, 0),      // Brown
            7  => (170, 170, 170),   // Light Gray
            8  => (85, 85, 85),      // Dark Gray
            9  => (85, 85, 255),     // Light Blue
            10 => (85, 255, 85),     // Light Green
            11 => (85, 255, 255),    // Light Cyan
            12 => (255, 85, 85),     // Light Red
            13 => (255, 85, 255),    // Light Magenta
            14 => (255, 255, 85),    // Yellow... kind of
            15 => (255, 255, 255),   // White
            _  => (255, 255, 255)    // Default to white
        };
    }

    // Resolve any BazzBasic color int (RGB or palette) to (r, g, b) bytes.
    public static (int r, int g, int b) ResolveColor(int color)
    {
        if ((color & 0x01000000) != 0)
        {
            int r = (color >> 16) & 0xFF;
            int g = (color >> 8) & 0xFF;
            int b = color & 0xFF;
            return (r, g, b);
        }
        return GetPaletteRGB(color);
    }

    // Resolve and apply as the active renderer color in one call.
    // Use this from drawing primitives (LINE, CIRCLE, PAINT, ...).
    public static void ApplyColor(int color)
    {
        var (r, g, b) = ResolveColor(color);
        SetColor(r, g, b);
    }

    // Return packed RGB (no flag bit) for any BazzBasic color int.
    // Use this when handing the color off to APIs that expect raw packed RGB,
    // such as shape storage or DRAWSTRING.
    public static int ResolveColorPacked(int color)
    {
        var (r, g, b) = ResolveColor(color);
        return (r << 16) | (g << 8) | b;
    }

    // color from predefined default color index 0-15
    public static void SetColorFromIndex(int colorIndex)
    {
        var (r, g, b) = GetPaletteRGB(colorIndex);
        SetColor(r, g, b);
    }
    
    // Present the rendered frame to screen (automatic present after a draw command).
    // Throttled: shown at most once per PRESENT_INTERVAL_MS, otherwise left pending.
    public static void Present()
    {
        if (!initialized || screenLocked) return;

        if (Environment.TickCount64 - lastPresentTicks >= PRESENT_INTERVAL_MS)
            PresentCanvas();
        else
            presentPending = true;
    }

    // Show a pending frame right now (before SLEEP, WAITKEY, INPUT...)
    public static void Flush()
    {
        if (!initialized || screenLocked || !presentPending) return;
        PresentCanvas();
    }

    // Periodic housekeeping, called by the interpreter every ~16 ms while a
    // program runs: keeps the window responsive (events, close button) and
    // shows a frame left pending by the throttle.
    public static void Tick()
    {
        if (!initialized) return;
        ProcessEvents();
        if (presentPending && !screenLocked &&
            Environment.TickCount64 - lastPresentTicks >= PRESENT_INTERVAL_MS)
        {
            PresentCanvas();
        }
    }

    // Copy the canvas to the window and present it. Every SDL_RenderPresent in
    // BazzBasic goes through here — never present the canvas target itself.
    private static void PresentCanvas()
    {
        if (renderer == IntPtr.Zero || canvas == IntPtr.Zero) return;

        _ = SDL.SDL_SetRenderTarget(renderer, IntPtr.Zero);
        _ = SDL.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);   // letterbox bars
        _ = SDL.SDL_RenderClear(renderer);
        _ = SDL.SDL_RenderCopy(renderer, canvas, IntPtr.Zero, IntPtr.Zero);
        SDL.SDL_RenderPresent(renderer);
        _ = SDL.SDL_SetRenderTarget(renderer, canvas);
        _ = SDL.SDL_SetRenderDrawColor(renderer, currentR, currentG, currentB, currentA);

        presentPending = false;
        lastPresentTicks = Environment.TickCount64;
    }

    // Create the canvas texture for the current renderer and make it the target.
    private static void CreateCanvas()
    {
        canvas = SDL.SDL_CreateTexture(renderer, SDL.SDL_PIXELFORMAT_ARGB8888,
            SDL.SDL_TEXTUREACCESS_TARGET, screenWidth, screenHeight);
        if (canvas == IntPtr.Zero)
            throw new Exception($"Canvas could not be created! SDL Error: {SDL.SDL_GetErrorString()}");

        // Copy the canvas to the window as-is (no alpha blending)
        _ = SDL.SDL_SetTextureBlendMode(canvas, SDL.SDL_BlendMode.SDL_BLENDMODE_NONE);
        if (SDL.SDL_SetRenderTarget(renderer, canvas) != 0)
            throw new Exception($"Canvas could not be set as render target! SDL Error: {SDL.SDL_GetErrorString()}");

        pixelCache = new int[screenWidth * screenHeight];
        cacheValid = false;
    }

    private static void DestroyCanvas()
    {
        if (canvas != IntPtr.Zero)
        {
            if (renderer != IntPtr.Zero)
                _ = SDL.SDL_SetRenderTarget(renderer, IntPtr.Zero);
            SDL.SDL_DestroyTexture(canvas);
            canvas = IntPtr.Zero;
        }
        cacheValid = false;
    }

    // Run an action with the window (not the canvas) as render target.
    // Needed for anything that depends on the window's logical scaling:
    // SDL_RenderSetLogicalSize and SDL_RenderWindowToLogical.
    private static void WithWindowTarget(Action action)
    {
        if (canvas != IntPtr.Zero)
            _ = SDL.SDL_SetRenderTarget(renderer, IntPtr.Zero);
        try { action(); }
        finally
        {
            if (canvas != IntPtr.Zero)
                _ = SDL.SDL_SetRenderTarget(renderer, canvas);
        }
    }

    // Any draw other than SetPixel must call this (ShapeManager, FontManager too)
    internal static void InvalidateCache() => cacheValid = false;

    // Read the whole canvas into pixelCache (one GPU read instead of one per POINT)
    private static void RefreshCache()
    {
        if (cacheValid) return;

        int count = screenWidth * screenHeight;
        if (pixelCache.Length != count)
            pixelCache = new int[count];

        GCHandle handle = GCHandle.Alloc(pixelCache, GCHandleType.Pinned);
        try
        {
            // Canvas is the current target: reads canvas pixels 1:1 in program coordinates.
            // ARGB8888 on little-endian = one int per pixel as 0xAARRGGBB.
            int result = SDL.SDL_RenderReadPixels(renderer, IntPtr.Zero,
                SDL.SDL_PIXELFORMAT_ARGB8888, handle.AddrOfPinnedObject(), screenWidth * 4);
            if (result != 0)
                throw new Exception($"Reading the screen failed! SDL Error: {SDL.SDL_GetErrorString()}");
        }
        finally
        {
            handle.Free();
        }

        // Strip alpha: cache holds plain 0xRRGGBB, exactly what POINT returns
        for (int i = 0; i < count; i++)
            pixelCache[i] &= 0x00FFFFFF;

        cacheValid = true;
    }

    // ========================================================================
    // SAVESCREEN — save the canvas as a PNG file (30.10.2026)
    // ========================================================================
    public static void SaveScreen(string path)
    {
        if (!initialized)
            throw new InvalidOperationException("Graphics mode not initialized. Use SCREEN first.");

        if (!string.Equals(Path.GetExtension(path), ".png", StringComparison.OrdinalIgnoreCase))
            throw new ArgumentException($"only .png files are supported: '{path}'");

        RefreshCache();

        using var bmp = new System.Drawing.Bitmap(screenWidth, screenHeight,
            System.Drawing.Imaging.PixelFormat.Format32bppArgb);
        var rect = new System.Drawing.Rectangle(0, 0, screenWidth, screenHeight);
        var data = bmp.LockBits(rect, System.Drawing.Imaging.ImageLockMode.WriteOnly,
            System.Drawing.Imaging.PixelFormat.Format32bppArgb);
        try
        {
            int[] row = new int[screenWidth];
            for (int y = 0; y < screenHeight; y++)
            {
                for (int x = 0; x < screenWidth; x++)
                    row[x] = pixelCache[y * screenWidth + x] | unchecked((int)0xFF000000); // opaque
                Marshal.Copy(row, 0, data.Scan0 + y * data.Stride, screenWidth);
            }
        }
        finally
        {
            bmp.UnlockBits(data);
        }

        bmp.Save(path, System.Drawing.Imaging.ImageFormat.Png);
    }
    
    // Set screen lock state (for manual double buffering) When locked, Present() calls are ignored until unlocked
    public static void SetScreenLock(bool locked)
    {
        screenLocked = locked;
        
        // f unlocking, present immediately to show buffered content (never throttled)
        if (!locked && initialized)
        {
            PresentCanvas();
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
                quitRequested = true;
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
        
        InvalidateCache();
        Present();
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

        // Map window pixels -> logical coords so MOUSEX/MOUSEY stay in the same virtual
        // screenWidth x screenHeight space as drawing. In fullscreen the window is bigger
        // than the logical canvas; in windowed mode the two are identical (no-op there).
        // Must use the window target: with the canvas as target SDL reports scale 1:1
        float lx = 0, ly = 0;
        WithWindowTarget(() => SDL.SDL_RenderWindowToLogical(renderer, x, y, out lx, out ly));
        mouseX = (int)lx;
        mouseY = (int)ly;
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
        [266] = SDL.SDL_Scancode.SDL_SCANCODE_KP_PLUS,
        [267] = SDL.SDL_Scancode.SDL_SCANCODE_KP_MINUS,
        [268] = SDL.SDL_Scancode.SDL_SCANCODE_KP_MULTIPLY,
        [269] = SDL.SDL_Scancode.SDL_SCANCODE_KP_DIVIDE,
        [270] = SDL.SDL_Scancode.SDL_SCANCODE_KP_PERIOD,
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
            // Numpad - mapped to the same codes as KEY_NUMPAD*# so INKEY/WAITKEY
            // match the constants (previously raw 0x400000xx values leaked through)
            SDL.SDL_Keycode.SDLK_KP_0 => 256,
            SDL.SDL_Keycode.SDLK_KP_1 => 257,
            SDL.SDL_Keycode.SDLK_KP_2 => 258,
            SDL.SDL_Keycode.SDLK_KP_3 => 259,
            SDL.SDL_Keycode.SDLK_KP_4 => 260,
            SDL.SDL_Keycode.SDLK_KP_5 => 261,
            SDL.SDL_Keycode.SDLK_KP_6 => 262,
            SDL.SDL_Keycode.SDLK_KP_7 => 263,
            SDL.SDL_Keycode.SDLK_KP_8 => 264,
            SDL.SDL_Keycode.SDLK_KP_9 => 265,
            SDL.SDL_Keycode.SDLK_KP_PLUS => 266,
            SDL.SDL_Keycode.SDLK_KP_MINUS => 267,
            SDL.SDL_Keycode.SDLK_KP_MULTIPLY => 268,
            SDL.SDL_Keycode.SDLK_KP_DIVIDE => 269,
            SDL.SDL_Keycode.SDLK_KP_PERIOD => 270,
            SDL.SDL_Keycode.SDLK_KP_ENTER => 13,   // numpad Enter == KEY_ENTER#
            // SDL2 letter keys return lowercase ASCII (97-122); normalize to uppercase (65-90)
            // so KEY_A# (=65) matches regardless of shift state, consistent with console mode
            _ => (int)key is >= 97 and <= 122 ? (int)key - 32 : (int)key
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
        if (!initialized) return false;

        int scancode;
        if (bazzKeyCode is >= 33 and <= 126)
        {
            // Letters, digits and punctuation follow the key LABEL on the current
            // keyboard layout (same meaning as INKEY): KEY_A# is the key that types "a".
            // If no key on the layout produces the character unshifted, the result is false.
            // (_keyMap entries in this range are no longer used for KEYDOWN.)
            int sym = bazzKeyCode is >= 65 and <= 90 ? bazzKeyCode + 32 : bazzKeyCode;
            scancode = SDL.SDL_GetScancodeFromKey((SDL.SDL_Keycode)sym);
            if (scancode <= 0) return false;
        }
        else
        {
            // Special keys, numpad and modifiers: fixed physical keys
            if (!_keyMap.TryGetValue(bazzKeyCode, out var sc))
                return false;
            scancode = (int)sc;
        }

        ProcessEvents();  // Pump event queue so keyboard state is current
        IntPtr state = SDL.SDL_GetKeyboardState(out int numKeys);
        if (scancode >= numKeys) return false;
        unsafe
        {
            byte* keys = (byte*)state;
            return keys[scancode] != 0;
        }
    }

    // ========================================================================
    // POINT command - Read pixel color at x, y (from the canvas pixel cache)
    // ========================================================================

    public static int GetPixelColor(int x, int y)
    {
        if (!initialized) return 0;
        
        // Bounds check
        if (x < 0 || x >= screenWidth || y < 0 || y >= screenHeight)
            return 0;
        
        // One full-canvas read when the cache is stale, then plain array lookups.
        // Returns packed 0xRRGGBB (no RGB() flag bit), as before.
        RefreshCache();
        return pixelCache[y * screenWidth + x];
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
        InvalidateCache();
        PresentCanvas();

        while (inputActive)
        {
            while (SDL.SDL_PollEvent(out SDL.SDL_Event e) != 0)
            {
                if (e.type == SDL.SDL_EventType.SDL_QUIT)
                {
                    quitRequested = true;
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
                            PresentCanvas();
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
        InvalidateCache();
        PresentCanvas();
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

        // Try SDL_RenderSetVSync first (SDL 2.0.18+) — no renderer recreation needed,
        // so keyboard focus and input state are preserved.
        int vsyncResult = SDL.SDL_RenderSetVSync(renderer, enable ? 1 : 0);
        if (vsyncResult == 0)
            return; // Success — done, no focus disruption

        // Fallback: destroy and recreate renderer (older SDL2 or unsupported driver).
        // The canvas dies with the renderer, so save its pixels first and restore them
        // into the new canvas below. (Shape and font textures are still lost here —
        // known limitation of this rarely used path.)
        int[]? savedPixels = null;
        if (canvas != IntPtr.Zero)
        {
            try
            {
                RefreshCache();
                savedPixels = (int[])pixelCache.Clone();
            }
            catch { /* best effort — canvas starts empty if the read fails */ }
        }
        DestroyCanvas();

        if (renderer != IntPtr.Zero)
        {
            SDL.SDL_DestroyRenderer(renderer);
        }

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

        // Renderer was recreated — re-apply the logical render size or it reverts to 1:1.
        // (Window is the target here: the canvas is created after this.)
        _ = SDL.SDL_RenderSetLogicalSize(renderer, screenWidth, screenHeight);

        // New canvas, old content restored via a temporary static texture
        CreateCanvas();
        if (savedPixels != null)
            RestoreCanvas(savedPixels);

        // Renderer recreation can cause the window to briefly lose focus, which
        // makes SDL zero out the keyboard state. Re-raise the window and flush
        // the event queue so input works normally on the very next frame.
        SDL.SDL_RaiseWindow(window);
        ProcessEvents();
        lastKeyPressed = 0; // Discard any stale key from the flush
    }

    // ========================================================================
    // DRAWSTRING — render text via SDL2_ttf
    // ========================================================================

    public static void DrawString(string text, int x, int y, int rgb)
    {
        if (!initialized) return;
        byte r = (byte)((rgb >> 16) & 0xFF);
        byte g = (byte)((rgb >> 8) & 0xFF);
        byte b = (byte)(rgb & 0xFF);
        InvalidateCache();
        FontManager.DrawString(renderer, text, x, y, r, g, b);
    }

    // Copy saved 0xRRGGBB pixels back onto the (current) canvas
    private static void RestoreCanvas(int[] pixels)
    {
        IntPtr tmp = SDL.SDL_CreateTexture(renderer, SDL.SDL_PIXELFORMAT_ARGB8888,
            SDL.SDL_TEXTUREACCESS_STATIC, screenWidth, screenHeight);
        if (tmp == IntPtr.Zero) return;

        int[] opaque = new int[pixels.Length];
        for (int i = 0; i < pixels.Length; i++)
            opaque[i] = pixels[i] | unchecked((int)0xFF000000);

        GCHandle handle = GCHandle.Alloc(opaque, GCHandleType.Pinned);
        try
        {
            _ = SDL.SDL_UpdateTexture(tmp, IntPtr.Zero, handle.AddrOfPinnedObject(), screenWidth * 4);
            _ = SDL.SDL_SetTextureBlendMode(tmp, SDL.SDL_BlendMode.SDL_BLENDMODE_NONE);
            _ = SDL.SDL_RenderCopy(renderer, tmp, IntPtr.Zero, IntPtr.Zero);
        }
        finally
        {
            handle.Free();
            SDL.SDL_DestroyTexture(tmp);
        }
        InvalidateCache();
    }

    // Find arial.ttf on Windows (C:\Windows\Fonts) or next to the exe
    private static string FindArialFont()
    {
        // 1. Next to the exe (user-supplied font wins)
        string exeDir = AppContext.BaseDirectory;
        foreach (string name in new[] { "arial.ttf", "Arial.ttf", "ARIAL.TTF" })
        {
            string local = Path.Combine(exeDir, name);
            if (System.IO.File.Exists(local)) return local;
        }

        // 2. Windows system fonts
        string winFonts = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.Windows), "Fonts");
        string winArial = Path.Combine(winFonts, "arial.ttf");
        if (System.IO.File.Exists(winArial)) return winArial;

        return "";
    }

    // Enable or disable fullscreen mode (borderless desktop fullscreen)
    public static void SetFullscreen(bool enable)
    {
        if (!initialized)
            throw new InvalidOperationException("Graphics not initialized. Call SCREEN first.");

        var flag = enable
            ? SDL.SDL_WindowFlags.SDL_WINDOW_FULLSCREEN_DESKTOP
            : (SDL.SDL_WindowFlags)0;

        if (SDL.SDL_SetWindowFullscreen(window, (uint)flag) < 0)
        {
            throw new Exception($"Failed to set fullscreen: {SDL.SDL_GetErrorString()}");
        }

        // When returning to windowed mode, restore size, re-center and raise to front
        if (!enable)
        {
            SDL.SDL_SetWindowSize(window, screenWidth, screenHeight);
            SDL.SDL_SetWindowPosition(window, SDL.SDL_WINDOWPOS_CENTERED, SDL.SDL_WINDOWPOS_CENTERED);
            SDL.SDL_ShowWindow(window);
            for (int i = 0; i < 5; i++)
            {
                SDL.SDL_PumpEvents();
                PresentCanvas();
                SDL.SDL_Delay(10);
            }
            SDL.SDL_RaiseWindow(window);
        }

        // Re-assert the logical render size so SDL recomputes the scale + letterbox
        // viewport for the new output size. Keeps draw coordinates in the same virtual
        // screenWidth x screenHeight space in both windowed and fullscreen mode.
        // Logical size belongs to the window target, not the canvas.
        SDL.SDL_PumpEvents();
        WithWindowTarget(() => SDL.SDL_RenderSetLogicalSize(renderer, screenWidth, screenHeight));
        PresentCanvas();
    }
}
