/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: SDL2\SDL2.cs
 Simplified SDL2 wrapper for BazzBasic

 Licence: MIT

 NOTE:Had some help from flibitijibibo's SDL2-CS project
 

**************************************************************
       Bases on SDL2-CS by Ethan Lee (flibitijibibo)
       License: zlib
**************************************************************
*/


/*
 * There is tons of places to improve this one. I will, eventually
*/

using System.Runtime.InteropServices;

namespace SDL2;

public static class SDL
{
    private const string nativeLibName = "SDL2";

    // SDL_Init flags
    public const uint SDL_INIT_VIDEO = 0x00000020;

    // Window positioning
    public const int SDL_WINDOWPOS_CENTERED = 0x2FFF0000;

    // Return codes
    public const int SDL_SUCCESS = 0;


    // Thanks to Claude. With out it, this would have been a nightmare to do
    [Flags]
    public enum SDL_WindowFlags : uint
    {
        SDL_WINDOW_SHOWN = 0x00000004,
        SDL_WINDOW_RESIZABLE = 0x00000020,
    }

    [Flags]
    public enum SDL_RendererFlags : uint
    {
        SDL_RENDERER_ACCELERATED = 0x00000002,
        SDL_RENDERER_PRESENTVSYNC = 0x00000004,
    }

    public enum SDL_EventType : uint
    {
        SDL_QUIT = 0x100,
        SDL_KEYDOWN = 0x300,
        SDL_KEYUP = 0x301,
    }

    public enum SDL_Keycode : int
    {
        SDLK_ESCAPE = 27,
        SDLK_RETURN = 13,
        SDLK_TAB = 9,
        SDLK_BACKSPACE = 8,
        SDLK_SPACE = 32,
        SDLK_UP = 1073741906,
        SDLK_DOWN = 1073741905,
        SDLK_LEFT = 1073741904,
        SDLK_RIGHT = 1073741903,
        SDLK_INSERT = 1073741897,
        SDLK_DELETE = 127,
        SDLK_HOME = 1073741898,
        SDLK_END = 1073741901,
        SDLK_PAGEUP = 1073741899,
        SDLK_PAGEDOWN = 1073741902,
        SDLK_F1 = 1073741882,
        SDLK_F2 = 1073741883,
        SDLK_F3 = 1073741884,
        SDLK_F4 = 1073741885,
        SDLK_F5 = 1073741886,
        SDLK_F6 = 1073741887,
        SDLK_F7 = 1073741888,
        SDLK_F8 = 1073741889,
        SDLK_F9 = 1073741890,
        SDLK_F10 = 1073741891,
        SDLK_F11 = 1073741892,
        SDLK_F12 = 1073741893,
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct SDL_Keysym
    {
        public uint scancode;
        public SDL_Keycode sym;
        public ushort mod;
        public uint unused;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct SDL_KeyboardEvent
    {
        public SDL_EventType type;
        public uint timestamp;
        public uint windowID;
        public byte state;
        public byte repeat;
        private byte padding2;
        private byte padding3;
        public SDL_Keysym keysym;
    }

    [StructLayout(LayoutKind.Explicit)]
    public struct SDL_Event
    {
        [FieldOffset(0)]
        public SDL_EventType type;
        [FieldOffset(0)]
        public SDL_KeyboardEvent key;
        [FieldOffset(0)]
        private unsafe fixed byte padding[56];
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct SDL_Rect
    {
        public int x;
        public int y;
        public int w;
        public int h;
    }

    // Surface and Texture support
    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
    public static extern IntPtr SDL_RWFromFile(string file, string mode);

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr SDL_LoadBMP_RW(IntPtr src, int freesrc);
    
    // Helper function to mimic SDL_LoadBMP macro
    public static IntPtr SDL_LoadBMP(string file)
    {
        IntPtr rwops = SDL_RWFromFile(file, "rb");
        if (rwops == IntPtr.Zero)
            return IntPtr.Zero;
        return SDL_LoadBMP_RW(rwops, 1); // 1 = automatically close rwops
    }

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr SDL_CreateTextureFromSurface(IntPtr renderer, IntPtr surface);

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern void SDL_FreeSurface(IntPtr surface);

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern void SDL_DestroyTexture(IntPtr texture);

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SDL_QueryTexture(
        IntPtr texture,
        out uint format,
        out int access,
        out int w,
        out int h
    );

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SDL_RenderCopyEx(
        IntPtr renderer,
        IntPtr texture,
        IntPtr srcrect,
        ref SDL_Rect dstrect,
        double angle,
        IntPtr center,
        int flip
    );

    // Core functions
    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SDL_Init(uint flags);

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern void SDL_Quit();

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
    public static extern IntPtr SDL_GetError();

    public static string? SDL_GetErrorString()
    {
        IntPtr ptr = SDL_GetError();
        return Marshal.PtrToStringAnsi(ptr);
    }

    // Window functions
    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
    public static extern IntPtr SDL_CreateWindow(
        string title,
        int x,
        int y,
        int w,
        int h,
        SDL_WindowFlags flags
    );

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern void SDL_DestroyWindow(IntPtr window);

    // Renderer functions
    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr SDL_CreateRenderer(
        IntPtr window,
        int index,
        SDL_RendererFlags flags
    );

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern void SDL_DestroyRenderer(IntPtr renderer);

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SDL_SetRenderDrawColor(
        IntPtr renderer,
        byte r,
        byte g,
        byte b,
        byte a
    );

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SDL_RenderClear(IntPtr renderer);

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern void SDL_RenderPresent(IntPtr renderer);

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SDL_RenderDrawPoint(
        IntPtr renderer,
        int x,
        int y
    );

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SDL_RenderDrawLine(
        IntPtr renderer,
        int x1,
        int y1,
        int x2,
        int y2
    );

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SDL_RenderDrawRect(
        IntPtr renderer,
        ref SDL_Rect rect
    );

    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SDL_RenderFillRect(
        IntPtr renderer,
        ref SDL_Rect rect
    );

    // Events stuff
    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SDL_PollEvent(out SDL_Event evt);

    // Mouse stuff
    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern uint SDL_GetMouseState(out int x, out int y);

    // Timer stuff
    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern void SDL_Delay(uint ms);

    // ========================================================================
    // PNG/Alpha support - Create textures from pixel data
    // ========================================================================
    
    // Pixel format constants
    public const uint SDL_PIXELFORMAT_ARGB8888 = 0x16362004;
    public const uint SDL_PIXELFORMAT_RGBA8888 = 0x16462004;
    public const uint SDL_PIXELFORMAT_ABGR8888 = 0x16762004;
    
    // Texture access modes
    public const int SDL_TEXTUREACCESS_STATIC = 0;
    public const int SDL_TEXTUREACCESS_STREAMING = 1;
    public const int SDL_TEXTUREACCESS_TARGET = 2;
    
    // Blend modes
    public enum SDL_BlendMode : int
    {
        SDL_BLENDMODE_NONE = 0x00000000,
        SDL_BLENDMODE_BLEND = 0x00000001,
        SDL_BLENDMODE_ADD = 0x00000002,
        SDL_BLENDMODE_MOD = 0x00000004
    }
    
    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr SDL_CreateTexture(
        IntPtr renderer,
        uint format,
        int access,
        int w,
        int h
    );
    
    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SDL_UpdateTexture(
        IntPtr texture,
        IntPtr rect,  // null for entire texture
        IntPtr pixels,
        int pitch
    );
    
    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SDL_SetTextureBlendMode(
        IntPtr texture,
        SDL_BlendMode blendMode
    );
    
    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SDL_SetRenderDrawBlendMode(
        IntPtr renderer,
        SDL_BlendMode blendMode
    );
    
    // For POINT command - read pixels from renderer
    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SDL_RenderReadPixels(
        IntPtr renderer,
        IntPtr rect,  // null for entire renderer
        uint format,
        IntPtr pixels,
        int pitch
    );
    
    [DllImport(nativeLibName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SDL_RenderCopy(
        IntPtr renderer,
        IntPtr texture,
        IntPtr srcrect,
        ref SDL_Rect dstrect
    );
}
