// ============================================================================
// BazzBasic - Sound Manager
// Handles sound loading and playback using NAudio
// ============================================================================

using NAudio.Wave;
using System.Collections.Concurrent;

namespace BazzBasic.Sound;

public class SoundManager
{
    private class SoundData
    {
        public string FilePath { get; set; } = "";
        public WaveStream? Reader { get; set; }
        public WaveOutEvent? Output { get; set; }
        public bool IsRepeating { get; set; }
    }

    private readonly ConcurrentDictionary<string, SoundData> _sounds = new();
    private readonly object _lock = new();

    // ========================================================================
    // Load Sound File
    // ========================================================================
    public string LoadSound(string filePath)
    {
        if (!File.Exists(filePath))
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

            _sounds[soundId] = soundData;
            return soundId;
        }
        catch (Exception ex)
        {
            throw new Exception($"Failed to load sound: {ex.Message}");
        }
    }

    // ========================================================================
    // Play Sound Once in Background
    // ========================================================================
    public void PlayOnce(string soundId)
    {
        if (!_sounds.TryGetValue(soundId, out var soundData))
        {
            throw new Exception($"Sound not found: {soundId}");
        }

        lock (_lock)
        {
            try
            {
                // Stop any existing playback
                StopSound(soundId);

                // Create new reader and output
                soundData.Reader = new AudioFileReader(soundData.FilePath);
                soundData.Output = new WaveOutEvent();
                soundData.IsRepeating = false;

                soundData.Output.Init(soundData.Reader);
                
                // Clean up when playback stops
                soundData.Output.PlaybackStopped += (sender, args) =>
                {
                    lock (_lock)
                    {
                        soundData.Reader?.Dispose();
                        soundData.Output?.Dispose();
                        soundData.Reader = null;
                        soundData.Output = null;
                    }
                };

                soundData.Output.Play();
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to play sound: {ex.Message}");
            }
        }
    }

    // ========================================================================
    // Play Sound Repeatedly in Background
    // ========================================================================
    public void PlayRepeat(string soundId)
    {
        if (!_sounds.TryGetValue(soundId, out var soundData))
        {
            throw new Exception($"Sound not found: {soundId}");
        }

        lock (_lock)
        {
            try
            {
                // Stop any existing playback
                StopSound(soundId);

                // Create new reader and output
                soundData.Reader = new AudioFileReader(soundData.FilePath);
                soundData.Output = new WaveOutEvent();
                soundData.IsRepeating = true;

                soundData.Output.Init(soundData.Reader);

                // Loop the sound
                soundData.Output.PlaybackStopped += (sender, args) =>
                {
                    lock (_lock)
                    {
                        try
                        {
                            if (soundData.IsRepeating && soundData.Reader != null && soundData.Output != null)
                            {
                                soundData.Reader.Position = 0;
                                soundData.Output.Play();
                            }
                            else
                            {
                                soundData.Reader?.Dispose();
                                soundData.Output?.Dispose();
                                soundData.Reader = null;
                                soundData.Output = null;
                            }
                        }
                        catch
                        {
                            // Ignore errors if sound was stopped during playback
                            soundData.Reader?.Dispose();
                            soundData.Output?.Dispose();
                            soundData.Reader = null;
                            soundData.Output = null;
                        }
                    }
                };

                soundData.Output.Play();
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to play repeating sound: {ex.Message}");
            }
        }
    }

    // ========================================================================
    // Play Sound Once and Wait for Completion
    // ========================================================================
    public void PlayOnceWait(string soundId)
    {
        if (!_sounds.TryGetValue(soundId, out var soundData))
        {
            throw new Exception($"Sound not found: {soundId}");
        }

        lock (_lock)
        {
            try
            {
                // Stop any existing playback
                StopSound(soundId);

                using var reader = new AudioFileReader(soundData.FilePath);
                using var output = new WaveOutEvent();

                output.Init(reader);

                var playbackFinished = new ManualResetEvent(false);
                output.PlaybackStopped += (sender, args) => playbackFinished.Set();

                output.Play();
                playbackFinished.WaitOne(); // Wait for playback to finish
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to play sound (wait): {ex.Message}");
            }
        }
    }

    // ========================================================================
    // Stop Specific Sound
    // ========================================================================
    public void StopSound(string soundId)
    {
        if (!_sounds.TryGetValue(soundId, out var soundData))
        {
            return; // Silently ignore if sound not found
        }

        lock (_lock)
        {
            soundData.IsRepeating = false;
            soundData.Output?.Stop();
            soundData.Reader?.Dispose();
            soundData.Output?.Dispose();
            soundData.Reader = null;
            soundData.Output = null;
        }
    }

    // ========================================================================
    // Stop All Sounds
    // ========================================================================
    public void StopAllSounds()
    {
        lock (_lock)
        {
            foreach (var sound in _sounds.Values)
            {
                sound.IsRepeating = false;
                sound.Output?.Stop();
                sound.Reader?.Dispose();
                sound.Output?.Dispose();
                sound.Reader = null;
                sound.Output = null;
            }
        }
    }

    // ========================================================================
    // Cleanup
    // ========================================================================
    public void Dispose()
    {
        StopAllSounds();
        _sounds.Clear();
    }
}
