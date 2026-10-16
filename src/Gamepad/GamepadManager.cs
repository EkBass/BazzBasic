/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic

 File: Gamepad\GamepadManager.cs
 Gamepad / game controller support via SDL2 GameController API.

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

using SDL2;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace BazzBasic.Gamepad;

/*
 * Design notes (16.10.2026):
 * - State is POLLED, never read from events. Graphics.cs drains the SDL event queue in
 *   several places, so any controller events would be eaten there. Joystick/controller
 *   events are set to SDL_IGNORE so they never even enter the queue (also keeps the
 *   queue from filling up in console mode where nobody polls it).
 * - Because events are ignored, SDL no longer auto-updates joysticks in SDL_PumpEvents.
 *   We call SDL_GameControllerUpdate() ourselves (max once per millisecond). That call
 *   also runs device detection, so hot-plugging works in console AND graphics mode.
 * - Lazy init via SDL_InitSubSystem: works without SCREEN.
 * - Graphics.Shutdown() calls SDL_Quit(), which also closes our controllers. EnsureInit()
 *   notices via SDL_WasInit and re-initializes; the old handles are simply forgotten
 *   (SDL already freed them - calling Close on them would be a use-after-free).
 * - Pads get a stable slot number in connection order and keep it while connected,
 *   so player 2 doesn't become player 1 if player 1's pad drops.
 * - First attempt (03/2026) "found 0 joysticks" because the count was queried once right
 *   after init. With polling + update this is a non-issue: DS4 over Bluetooth shows up
 *   immediately on SDL 2.28.5 (verified with padprobe 16.10.2026).
 */
public static class GamepadManager
{
    public const int MaxPads = 8;
    public const int ButtonCount = 21;     // SDL_CONTROLLER_BUTTON_MAX (SDL >= 2.0.14)
    public const int AxisCount = 6;        // SDL_CONTROLLER_AXIS_MAX
    private const double DeadZone = 0.15;  // fraction of full deflection treated as 0
    private const int RescanIntervalMs = 250;

    private static readonly IntPtr[] _pads = new IntPtr[MaxPads];
    private static readonly int[] _ids = new int[MaxPads];
    private static bool _ready;
    private static bool _failed;
    private static readonly Stopwatch _clock = Stopwatch.StartNew();
    private static long _lastUpdate = -1;
    private static long _lastScan = long.MinValue / 2;

    private static bool EnsureInit()
    {
        if (_ready)
        {
            if (SDL.SDL_WasInit(SDL.SDL_INIT_GAMECONTROLLER) != 0)
                return true;
            // SDL_Quit() happened underneath us (graphics window closed). Handles are gone.
            Array.Clear(_pads);
            _ready = false;
        }
        if (_failed) return false;

        try
        {
            // Must be set before the joystick subsystem starts. Without it SDL drops
            // pad input whenever an SDL window exists but doesn't have focus.
            SDL.SDL_SetHint("SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS", "1");
            if (SDL.SDL_InitSubSystem(SDL.SDL_INIT_JOYSTICK | SDL.SDL_INIT_GAMECONTROLLER) != 0)
            {
                _failed = true;
                return false;
            }
            SDL.SDL_JoystickEventState(SDL.SDL_IGNORE);
            SDL.SDL_GameControllerEventState(SDL.SDL_IGNORE);
        }
        catch (Exception)   // SDL2.dll missing / wrong arch -> gamepads simply unavailable
        {
            _failed = true;
            return false;
        }

        _ready = true;
        _lastUpdate = -1;
        _lastScan = long.MinValue / 2;
        return true;
    }

    private static void Update()
    {
        long now = _clock.ElapsedMilliseconds;
        if (now != _lastUpdate)
        {
            SDL.SDL_GameControllerUpdate();
            _lastUpdate = now;
        }
        if (now - _lastScan >= RescanIntervalMs)
        {
            _lastScan = now;
            Rescan();
        }
    }

    private static void Rescan()
    {
        // Drop pads that were unplugged / switched off
        for (int s = 0; s < MaxPads; s++)
        {
            if (_pads[s] != IntPtr.Zero && SDL.SDL_GameControllerGetAttached(_pads[s]) == 0)
            {
                SDL.SDL_GameControllerClose(_pads[s]);
                _pads[s] = IntPtr.Zero;
            }
        }

        // Open newly connected ones into the first free slot
        int n = SDL.SDL_NumJoysticks();
        for (int d = 0; d < n; d++)
        {
            if (SDL.SDL_IsGameController(d) == 0) continue;
            int id = SDL.SDL_JoystickGetDeviceInstanceID(d);
            if (IsOpen(id)) continue;

            int slot = Array.IndexOf(_pads, IntPtr.Zero);
            if (slot < 0) break;

            IntPtr gc = SDL.SDL_GameControllerOpen(d);
            if (gc == IntPtr.Zero) continue;
            _pads[slot] = gc;
            _ids[slot] = id;
        }
    }

    private static bool IsOpen(int instanceId)
    {
        for (int s = 0; s < MaxPads; s++)
            if (_pads[s] != IntPtr.Zero && _ids[s] == instanceId) return true;
        return false;
    }

    private static IntPtr Get(int pad)
    {
        if (pad < 0 || pad >= MaxPads) return IntPtr.Zero;
        if (!EnsureInit()) return IntPtr.Zero;
        Update();
        return _pads[pad];
    }

    // ---------------------------------------------------------------- public API

    /// <summary>Number of connected gamepads.</summary>
    public static int Count()
    {
        if (!EnsureInit()) return 0;
        Update();
        int c = 0;
        foreach (var p in _pads) if (p != IntPtr.Zero) c++;
        return c;
    }

    /// <summary>True while button is held. False if pad not connected.</summary>
    public static bool Button(int pad, int button)
    {
        IntPtr p = Get(pad);
        if (p == IntPtr.Zero) return false;
        return SDL.SDL_GameControllerGetButton(p, button) != 0;
    }

    /// <summary>Sticks -1.0 .. 1.0, triggers 0.0 .. 1.0, with dead zone. 0 if not connected.</summary>
    public static double Axis(int pad, int axis)
    {
        IntPtr p = Get(pad);
        if (p == IntPtr.Zero) return 0.0;

        double v = Math.Clamp(SDL.SDL_GameControllerGetAxis(p, axis) / 32767.0, -1.0, 1.0);
        if (axis >= 4) v = Math.Max(0.0, v);   // triggers never go negative

        double a = Math.Abs(v);
        if (a < DeadZone) return 0.0;
        return Math.Sign(v) * (a - DeadZone) / (1.0 - DeadZone);
    }

    /// <summary>Controller name, "" if not connected.</summary>
    public static string Name(int pad)
    {
        IntPtr p = Get(pad);
        if (p == IntPtr.Zero) return "";
        IntPtr s = SDL.SDL_GameControllerName(p);
        return s == IntPtr.Zero ? "" : Marshal.PtrToStringUTF8(s) ?? "";
    }

    /// <summary>Rumble both motors. strength 0..1, ms = duration. Silently ignored if unsupported.</summary>
    public static void Rumble(int pad, double strength, int ms)
    {
        IntPtr p = Get(pad);
        if (p == IntPtr.Zero) return;
        ushort power = (ushort)Math.Round(Math.Clamp(strength, 0.0, 1.0) * 65535.0);
        SDL.SDL_GameControllerRumble(p, power, power, (uint)Math.Max(0, ms));
    }
}
