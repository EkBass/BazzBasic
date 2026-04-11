/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic

 File: SDL2\SDL2_ttf.cs
 P/Invoke bindings for SDL2_ttf

 Copyright (c):
    - 2025 - 2026
    - Kristian Virtanen
    - krisu.virtanen@gmail.com
    - Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

using System.Runtime.InteropServices;

namespace SDL2;

public static class SDL_ttf
{
    private const string NativeLib = "SDL2_ttf";

    [StructLayout(LayoutKind.Sequential)]
    public struct SDL_Color
    {
        public byte r, g, b, a;
    }

    [DllImport(NativeLib, CallingConvention = CallingConvention.Cdecl)]
    public static extern int TTF_Init();

    [DllImport(NativeLib, CallingConvention = CallingConvention.Cdecl)]
    public static extern void TTF_Quit();

    [DllImport(NativeLib, CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr TTF_OpenFont(string file, int ptsize);

    [DllImport(NativeLib, CallingConvention = CallingConvention.Cdecl)]
    public static extern void TTF_CloseFont(IntPtr font);

    [DllImport(NativeLib, CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr TTF_RenderUTF8_Blended(IntPtr font, string text, SDL_Color fg);

    [DllImport(NativeLib, CallingConvention = CallingConvention.Cdecl)]
    public static extern string TTF_GetError();
}
