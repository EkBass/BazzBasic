/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Sound\SoundManager.cs
 Rocks like a hurricane using SDL2_mixer
 Licence: MIT

Lot's of to improve. Will do eventually
*/

using System.Collections.Concurrent;

namespace BazzBasic.Sound;

public class SoundManager : IDisposable
{
    private class SoundData
    {
        public string FilePath { get; set; } = "";
        public IntPtr Chunk { get; set; } = IntPtr.Zero;  // Mix_Chunk* for short sounds
        public IntPtr Music { get; set; } = IntPtr.Zero;  // Mix_Music* for music/long files
        public int Channel { get; set; } = -1;            // Channel number for chunks
        public bool IsMusic { get; set; }                 // true = Music, false = Chunk
        public bool IsRepeating { get; set; }
    }

    private readonly ConcurrentDictionary<string, SoundData> _sounds = new();
    private static bool _initialized = false;
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
                // Note: SDL2 is already initialized by Graphics.Graphics
                // We only need to initialize SDL_mixer

                // Initialize SDL_mixer
                var flags = SDL_mixer.MIX_InitFlags.MIX_INIT_MP3 | 
                           SDL_mixer.MIX_InitFlags.MIX_INIT_OGG |
                           SDL_mixer.MIX_InitFlags.MIX_INIT_FLAC;
                
                if (SDL_mixer.Mix_Init(flags) != (int)flags)
                {
                    // Not all formats supported, but continue anyway
                }

                // Open audio device
                // 44.1kHz, 16-bit stereo, 2048 byte chunks
                if (SDL_mixer.Mix_OpenAudio(44100, SDL_mixer.MIX_DEFAULT_FORMAT, 2, 2048) < 0)
                {
                    throw new Exception($"Mix_OpenAudio failed: {SDL_mixer.SDL_GetErrorString()}");
                }

                // Allocate 16 mixing channels
                SDL_mixer.Mix_AllocateChannels(16);

                _initialized = true;
            }
        }
    }

    // ========================================================================
    // Load sound from file
    // ========================================================================
    public string LoadSound(string filePath)
    {
        if (!System.IO.File.Exists(filePath))
        {
            throw new Exception($"Sound file not found: {filePath}");
        }

        // Create unique ID for this sound
        string soundId = Guid.NewGuid().ToString();

        try
        {
            var soundData = new SoundData
            {
                FilePath = filePath
            };

            // Detect if this should be loaded as music (long files: MP3, OGG) or chunk (short: WAV)
            string ext = Path.GetExtension(filePath).ToLowerInvariant();
            soundData.IsMusic = ext == ".mp3" || ext == ".ogg" || ext == ".flac";

            if (soundData.IsMusic)
            {
                // Load as music (streamed from disk)
                soundData.Music = SDL_mixer.Mix_LoadMUS(filePath);
                if (soundData.Music == IntPtr.Zero)
                {
                    throw new Exception($"Mix_LoadMUS failed: {SDL_mixer.SDL_GetErrorString()}");
                }
            }
            else
            {
                // Load as chunk (fully loaded into memory)
                soundData.Chunk = SDL_mixer.Mix_LoadWAV(filePath);
                if (soundData.Chunk == IntPtr.Zero)
                {
                    throw new Exception($"Mix_LoadWAV failed: {SDL_mixer.SDL_GetErrorString()}");
                }
            }

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
        if (!_sounds.TryGetValue(soundId, out var soundData))
        {
            throw new Exception($"Sound not found: {soundId}");
        }

        try
        {
            // Stop any existing playback
            StopSound(soundId);

            soundData.IsRepeating = false;

            if (soundData.IsMusic)
            {
                // Play music once (0 = play once)
                if (SDL_mixer.Mix_PlayMusic(soundData.Music, 0) < 0)
                {
                    throw new Exception($"Mix_PlayMusic failed: {SDL_mixer.SDL_GetErrorString()}");
                }
            }
            else
            {
                // Play chunk on first available channel (0 = play once)
                int channel = SDL_mixer.Mix_PlayChannel(-1, soundData.Chunk, 0);
                if (channel < 0)
                {
                    throw new Exception($"Mix_PlayChannel failed: {SDL_mixer.SDL_GetErrorString()}");
                }
                soundData.Channel = channel;
            }
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
        if (!_sounds.TryGetValue(soundId, out var soundData))
        {
            throw new Exception($"Sound not found: {soundId}");
        }

        try
        {
            // Stop any existing playback
            StopSound(soundId);

            soundData.IsRepeating = true;

            if (soundData.IsMusic)
            {
                // Play music in loop (-1 = infinite loop)
                if (SDL_mixer.Mix_PlayMusic(soundData.Music, -1) < 0)
                {
                    throw new Exception($"Mix_PlayMusic failed: {SDL_mixer.SDL_GetErrorString()}");
                }
            }
            else
            {
                // Play chunk in loop (-1 = infinite loop)
                int channel = SDL_mixer.Mix_PlayChannel(-1, soundData.Chunk, -1);
                if (channel < 0)
                {
                    throw new Exception($"Mix_PlayChannel failed: {SDL_mixer.SDL_GetErrorString()}");
                }
                soundData.Channel = channel;
            }
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
        if (!_sounds.TryGetValue(soundId, out var soundData))
        {
            throw new Exception($"Sound not found: {soundId}");
        }

        try
        {
            // Stop any existing playback
            StopSound(soundId);

            soundData.IsRepeating = false;

            if (soundData.IsMusic)
            {
                // Play music once
                if (SDL_mixer.Mix_PlayMusic(soundData.Music, 0) < 0)
                {
                    throw new Exception($"Mix_PlayMusic failed: {SDL_mixer.SDL_GetErrorString()}");
                }

                // Wait for music to finish
                while (SDL_mixer.Mix_PlayingMusic() != 0)
                {
                    Thread.Sleep(100);
                }
            }
            else
            {
                // Play chunk once
                int channel = SDL_mixer.Mix_PlayChannel(-1, soundData.Chunk, 0);
                if (channel < 0)
                {
                    throw new Exception($"Mix_PlayChannel failed: {SDL_mixer.SDL_GetErrorString()}");
                }
                soundData.Channel = channel;

                // Wait for chunk to finish
                while (SDL_mixer.Mix_Playing(channel) != 0)
                {
                    Thread.Sleep(100);
                }
            }
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
        if (!_sounds.TryGetValue(soundId, out var soundData))
        {
            return; // Silently ignore if sound not found
        }

        soundData.IsRepeating = false;

        if (soundData.IsMusic)
        {
            SDL_mixer.Mix_HaltMusic();
        }
        else if (soundData.Channel >= 0)
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
        foreach (var sound in _sounds.Values)
        {
            sound.IsRepeating = false;
            
            if (sound.IsMusic)
            {
                SDL_mixer.Mix_HaltMusic();
            }
            else if (sound.Channel >= 0)
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

        // Free all loaded sounds
        foreach (var sound in _sounds.Values)
        {
            if (sound.IsMusic && sound.Music != IntPtr.Zero)
            {
                SDL_mixer.Mix_FreeMusic(sound.Music);
                sound.Music = IntPtr.Zero;
            }
            else if (sound.Chunk != IntPtr.Zero)
            {
                SDL_mixer.Mix_FreeChunk(sound.Chunk);
                sound.Chunk = IntPtr.Zero;
            }
        }

        _sounds.Clear();

        // Note: We don't close Mix_CloseAudio() here because other instances might be using it
        // It will be closed when the application exits
    }
}
