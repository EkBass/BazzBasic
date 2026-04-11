/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic

 File: Graphics\FontManager.cs
 SDL2_ttf font management and text rendering

 Copyright (c):
    - 2025 - 2026
    - Kristian Virtanen
    - krisu.virtanen@gmail.com
    - Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

using SDL2;
using System.Runtime.InteropServices;

namespace BazzBasic.Graphics;

public static class FontManager
{
    private static bool _ttfInitialized = false;
    private static IntPtr _currentFont = IntPtr.Zero;
    private static string _defaultFontPath = "";

    // Initialize SDL2_ttf and load the default Arial font.
    // defaultFontPath: full path to arial.ttf (or any fallback TTF).
    public static void Initialize(string defaultFontPath, int defaultSize = 16)
    {
        if (_ttfInitialized) return;

        if (SDL_ttf.TTF_Init() < 0)
            throw new Exception($"SDL2_ttf init failed: {SDL_ttf.TTF_GetError()}");

        _ttfInitialized = true;
        _defaultFontPath = defaultFontPath;

        LoadFont(defaultFontPath, defaultSize);
    }

    // Load a font and make it the current (active) font.
    // Closes any previously loaded font first.
    public static void LoadFont(string path, int size)
    {
        if (!_ttfInitialized)
            throw new InvalidOperationException("FontManager not initialized.");

        IntPtr newFont = SDL_ttf.TTF_OpenFont(path, size);
        if (newFont == IntPtr.Zero)
            throw new Exception($"LOADFONT failed: {SDL_ttf.TTF_GetError()} (file: {path})");

        // Close old font only after new one loaded successfully
        if (_currentFont != IntPtr.Zero)
            SDL_ttf.TTF_CloseFont(_currentFont);

        _currentFont = newFont;
    }

    // Reset to default Arial font at given size (or original size if 0).
    public static void ResetToDefault(int size = 16)
    {
        LoadFont(_defaultFontPath, size);
    }

    // Draw text at (x, y) using the current font and given RGB color.
    // renderer: SDL2 renderer handle from Graphics.Renderer
    public static void DrawString(IntPtr renderer, string text, int x, int y, byte r, byte g, byte b)
    {
        if (!_ttfInitialized || _currentFont == IntPtr.Zero)
            throw new InvalidOperationException("No font loaded. Call LOADFONT or SCREEN first.");

        if (string.IsNullOrEmpty(text)) return;

        var color = new SDL_ttf.SDL_Color { r = r, g = g, b = b, a = 255 };

        // Render text to surface
        IntPtr surface = SDL_ttf.TTF_RenderUTF8_Blended(_currentFont, text, color);
        if (surface == IntPtr.Zero)
            throw new Exception($"DRAWSTRING render failed: {SDL_ttf.TTF_GetError()}");

        try
        {
            // Create texture from surface
            IntPtr texture = SDL.SDL_CreateTextureFromSurface(renderer, surface);
            if (texture == IntPtr.Zero)
                throw new Exception($"DRAWSTRING texture failed: {SDL.SDL_GetErrorString()}");

            try
            {
                // Query texture size
                SDL.SDL_QueryTexture(texture, out _, out _, out int w, out int h);

                // Destination rectangle
                SDL.SDL_Rect dst = new() { x = x, y = y, w = w, h = h };

                SDL.SDL_RenderCopy(renderer, texture, IntPtr.Zero, ref dst);
            }
            finally
            {
                SDL.SDL_DestroyTexture(texture);
            }
        }
        finally
        {
            SDL.SDL_FreeSurface(surface);
        }
    }

    public static bool IsReady => _ttfInitialized && _currentFont != IntPtr.Zero;

    public static void Shutdown()
    {
        if (_currentFont != IntPtr.Zero)
        {
            SDL_ttf.TTF_CloseFont(_currentFont);
            _currentFont = IntPtr.Zero;
        }

        if (_ttfInitialized)
        {
            SDL_ttf.TTF_Quit();
            _ttfInitialized = false;
        }
    }
}
