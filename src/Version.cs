/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic
 
 File: Version.cs
 Global version constants - edit before releasing new version

 Copyright (c):
	- 2025 - 2026
	- Kristian Virtanen
	- krisu.virtanen@gmail.com

	- Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

namespace BazzBasic;

public static partial class AppInfo
{
	// Currently under development
    public const string Version = "1.7"; // IDE & "BBVER#" reads this too
    public const string Url = "https://ekbass.github.io/BazzBasic/";
    public const string Name = "BazzBasic";

    /*
	 * See: ..\BazzBasic.csproj
	 * It places automatically the following information into the assembly:
	 * 
	 * <WriteLinesToFile
	 *		File="$(GeneratedVersionFile)"
	 *		Lines="namespace BazzBasic; public static partial class AppInfo { public static readonly string Build = &quot;$(BuildTimestamp)&quot;; }"
	 */      
}
