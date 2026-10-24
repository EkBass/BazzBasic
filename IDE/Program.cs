/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic

 File: IDE/Program.cs
 BazzBasic IDE entry point. The IDE runs programs through BazzBasic.exe
 (see ResolveInterpreterPath in MainForm.cs); it contains no interpreter code.

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

namespace BazzBasic.IDE;

internal static class Program
{
    [STAThread] // Required for file dialogs
    private static void Main()
    {
        ApplicationConfiguration.Initialize();
        try
        {
            Application.Run(new MainForm());
        }
        catch (Exception ex)
        {
            MessageBox.Show($"IDE Error: {ex.Message}\n\n{ex.StackTrace}", "BazzBasic Error",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
