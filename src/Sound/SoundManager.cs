/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Sound\SoundManager.cs
 Rocks like a hurricane using SDL2_mixer

Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

using System.Collections.Concurrent;

namespace BazzBasic.Sound;

public class SoundManager : IDisposable
{
    private class SoundData
    {
        public string FilePath { get; set; } = "";
        public IntPtr Chunk { get; set; } = IntPtr.Zero;  // Mix_Chunk* — all sounds loaded as chunks
        public int Channel { get; set; } = -1;            // Channel number (-1 = not playing)
        public bool IsRepeating { get; set; }
    }

    private readonly ConcurrentDictionary<string, SoundData> _sounds = new();
    private static bool _initialized = false;
    private static bool _audioAvailable = false;
    private static readonly object _initLock = new();

    // ========================================================================
    // Initialize SDL2_mixer (call once)
    // ========================================================================
    public SoundManager()
    {
        lock (_initLock)
        {
            if (!_initialized)
            {
                // SDL_Init + SDL_InitSubSystem ensure audio subsystem is running
                // regardless of whether Graphics has already called SDL_Init(VIDEO).
                // SDL_AUDIODRIVER=directsound is set in Program.cs to bypass WASAPI,
                // which fails on systems with Nahimic audio middleware installed.
                SDL_mixer.SDL_Init(SDL_mixer.SDL_INIT_AUDIO);
                SDL_mixer.SDL_InitSubSystem(SDL_mixer.SDL_INIT_AUDIO);

                // Initialize SDL_mixer format support
                var flags = SDL_mixer.MIX_InitFlags.MIX_INIT_MP3 |
                            SDL_mixer.MIX_InitFlags.MIX_INIT_OGG |
                            SDL_mixer.MIX_InitFlags.MIX_INIT_FLAC;
                SDL_mixer.Mix_Init(flags);

                // Open audio device
                if (SDL_mixer.Mix_OpenAudio(44100, SDL_mixer.MIX_DEFAULT_FORMAT, 2, 4096) < 0)
                {
                    Console.Error.WriteLine($"Warning: Audio not available ({SDL_mixer.SDL_GetErrorString()}). Sound commands will be ignored.");
                    _initialized = true;
                    _audioAvailable = false;
                    return;
                }

                // Allocate 16 mixing channels and set max volume
                SDL_mixer.Mix_AllocateChannels(16);
                SDL_mixer.Mix_Volume(-1, 128);

                _initialized = true;
                _audioAvailable = true;
            }
        }
    }

    // ========================================================================
    // Load sound from file
    // ========================================================================
    public string LoadSound(string filePath)
    {
        if (!_audioAvailable) return "no_audio";

        if (!System.IO.File.Exists(filePath))
            throw new Exception($"Sound file not found: {filePath}");

        string soundId = Guid.NewGuid().ToString();

        try
        {
            var soundData = new SoundData { FilePath = filePath };

            // All files loaded as Mix_Chunk (WAV, MP3, OGG, FLAC).
            // This allows multiple sounds to play simultaneously on separate channels.
            // Mix_Music only supports one stream at a time, so we avoid it entirely.
            soundData.Chunk = SDL_mixer.Mix_LoadWAV(filePath);
            if (soundData.Chunk == IntPtr.Zero)
                throw new Exception($"Mix_LoadWAV failed: {SDL_mixer.SDL_GetErrorString()}");

            _sounds[soundId] = soundData;
            return soundId;
        }
        catch (Exception ex)
        {
            throw new Exception($"Failed to load sound: {ex.Message}");
        }
    }

    // ========================================================================
    // Play once
    // ========================================================================
    public void PlayOnce(string soundId)
    {
        if (!_audioAvailable) return;
        if (!_sounds.TryGetValue(soundId, out var soundData))
            throw new Exception($"Sound not found: {soundId}");

        try
        {
            StopSound(soundId);
            soundData.IsRepeating = false;
            int channel = SDL_mixer.Mix_PlayChannel(-1, soundData.Chunk, 0);
            if (channel < 0)
                throw new Exception($"Mix_PlayChannel failed: {SDL_mixer.SDL_GetErrorString()}");
            soundData.Channel = channel;
        }
        catch (Exception ex)
        {
            throw new Exception($"Failed to play sound: {ex.Message}");
        }
    }

    // ========================================================================
    // Play with repeat
    // ========================================================================
    public void PlayRepeat(string soundId)
    {
        if (!_audioAvailable) return;
        if (!_sounds.TryGetValue(soundId, out var soundData))
            throw new Exception($"Sound not found: {soundId}");

        try
        {
            StopSound(soundId);
            soundData.IsRepeating = true;
            int channel = SDL_mixer.Mix_PlayChannel(-1, soundData.Chunk, -1);
            if (channel < 0)
                throw new Exception($"Mix_PlayChannel failed: {SDL_mixer.SDL_GetErrorString()}");
            soundData.Channel = channel;
        }
        catch (Exception ex)
        {
            throw new Exception($"Failed to play repeating sound: {ex.Message}");
        }
    }

    // ========================================================================
    // Play once and wait until done
    // ========================================================================
    public void PlayOnceWait(string soundId)
    {
        if (!_audioAvailable) return;
        if (!_sounds.TryGetValue(soundId, out var soundData))
            throw new Exception($"Sound not found: {soundId}");

        try
        {
            StopSound(soundId);
            soundData.IsRepeating = false;
            int channel = SDL_mixer.Mix_PlayChannel(-1, soundData.Chunk, 0);
            if (channel < 0)
                throw new Exception($"Mix_PlayChannel failed: {SDL_mixer.SDL_GetErrorString()}");
            soundData.Channel = channel;

            // Brief delay before polling — DirectSound needs a moment to start the stream
            Thread.Sleep(50);
            while (SDL_mixer.Mix_Playing(channel) != 0)
                Thread.Sleep(100);
        }
        catch (Exception ex)
        {
            throw new Exception($"Failed to play sound (wait): {ex.Message}");
        }
    }

    // ========================================================================
    // Stop certain sound
    // ========================================================================
    public void StopSound(string soundId)
    {
        if (!_audioAvailable) return;
        if (!_sounds.TryGetValue(soundId, out var soundData)) return;

        soundData.IsRepeating = false;
        if (soundData.Channel >= 0)
        {
            SDL_mixer.Mix_HaltChannel(soundData.Channel);
            soundData.Channel = -1;
        }
    }

    // ========================================================================
    // Stop all sounds
    // ========================================================================
    public void StopAllSounds()
    {
        if (!_audioAvailable) return;
        foreach (var sound in _sounds.Values)
        {
            sound.IsRepeating = false;
            if (sound.Channel >= 0)
            {
                SDL_mixer.Mix_HaltChannel(sound.Channel);
                sound.Channel = -1;
            }
        }
    }

    // ========================================================================
    // Clean up resources
    // ========================================================================
    public void Dispose()
    {
        StopAllSounds();
        foreach (var sound in _sounds.Values)
        {
            if (sound.Chunk != IntPtr.Zero)
            {
                SDL_mixer.Mix_FreeChunk(sound.Chunk);
                sound.Chunk = IntPtr.Zero;
            }
        }
        _sounds.Clear();
    }
}
