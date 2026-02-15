/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Sound\SDL_mixer.cs
 Minimal P/Invoke bindings for SDL_mixer.dll

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.

Tons of places to improve this and I will. Some day.
*/

using System.Runtime.InteropServices;

namespace BazzBasic.Sound;

// Min P-Invoke bindsfor SDL2_mixer.dll

public static class SDL_mixer
{
    private const string DllName = "SDL2_mixer.dll";

    // Initialization flags
    [Flags]
    public enum MIX_InitFlags
    {
        MIX_INIT_FLAC = 0x00000001,
        MIX_INIT_MOD = 0x00000002,
        MIX_INIT_MP3 = 0x00000008,
        MIX_INIT_OGG = 0x00000010,
        MIX_INIT_MID = 0x00000020,
        MIX_INIT_OPUS = 0x00000040
    }

    // Default audio format (signed 16-bit samples, in little-endian byte order)
    public const ushort MIX_DEFAULT_FORMAT = 0x8010; // AUDIO_S16LSB
    public const int MIX_DEFAULT_CHANNELS = 2;
    public const int MIX_DEFAULT_FREQUENCY = 44100;

    // Initialize SDL_mixer
    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int Mix_Init(MIX_InitFlags flags);

    // Shutdown and cleanup SDL_mixer
    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern void Mix_Quit();

    // Open audio device
    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int Mix_OpenAudio(int frequency, ushort format, int channels, int chunksize);

    // Close audio device
    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern void Mix_CloseAudio();

    // Allocate mixing channels
    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int Mix_AllocateChannels(int numchans);

    // Load WAV file
    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
    public static extern IntPtr Mix_LoadWAV(string file);

    // Free chunk memory
    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern void Mix_FreeChunk(IntPtr chunk);

    // Load music file
    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
    public static extern IntPtr Mix_LoadMUS(string file);

    // Free music memory
    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern void Mix_FreeMusic(IntPtr music);

    // Play chunk on channel (loops: 0 = once, -1 = infinite)
    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int Mix_PlayChannel(int channel, IntPtr chunk, int loops);

    // Play music (loops: 0 = once, -1 = infinite)
    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int Mix_PlayMusic(IntPtr music, int loops);

    // Check if channel is playing
    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int Mix_Playing(int channel);

    // Check if music is playing
    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int Mix_PlayingMusic();

    // Halt playback on channel
    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int Mix_HaltChannel(int channel);

    // Halt music playback
    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int Mix_HaltMusic();

    // Get SDL error string (from SDL2.dll)
    [DllImport("SDL2.dll", CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr SDL_GetError();

    public static string SDL_GetErrorString()
    {
        IntPtr ptr = SDL_GetError();
        return Marshal.PtrToStringAnsi(ptr) ?? "Unknown error";
    }
}
