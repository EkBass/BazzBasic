/*
 BazzBasic project
 Url: https://github.com/EkBass/BazzBasic

 File: UpdateChecker.cs
 Checks GitHub releases/latest for a newer version.

 Copyright (c):
    - 2025 - 2026
    - Kristian Virtanen
    - krisu.virtanen@gmail.com
    - Licensed under the MIT License. See LICENSE file in the project root for full license information.
*/

namespace BazzBasic;

public static class UpdateChecker
{
    private const string ReleasesLatestUrl = "https://github.com/EkBass/BazzBasic/releases/latest";

    // Get the latest release tag from GitHub and compare it to the running version.
    public static async Task<string> CheckAsync()
    {
        try
        {
            using var client = new System.Net.Http.HttpClient(new System.Net.Http.HttpClientHandler
            {
                AllowAutoRedirect = true
            });
            client.Timeout = TimeSpan.FromSeconds(10);
            client.DefaultRequestHeaders.UserAgent.ParseAdd("BazzBasic-UpdateChecker/1.0");

            // GitHub redirects /releases/latest -> /releases/tag/xxxxx
            var response = await client.GetAsync(ReleasesLatestUrl);
            response.EnsureSuccessStatusCode();

            // Read the final URL after redirect
            var finalUrl = response.RequestMessage?.RequestUri?.AbsolutePath ?? "";
            // e.g. "/EkBass/BazzBasic/releases/tag/v1.2b"
            var tagPrefix = "/releases/tag/";
            int idx = finalUrl.IndexOf(tagPrefix, StringComparison.OrdinalIgnoreCase);
            if (idx < 0)
                return "Could not parse release version from GitHub.";

            string latestTag = finalUrl[(idx + tagPrefix.Length)..].Trim().TrimEnd('/');
            string download = $"Download: {ReleasesLatestUrl}";

            var latest = ParseVersion(latestTag);
            var current = ParseVersion(AppInfo.Version);

            // Unparseable tag: fall back to plain text comparison
            if (latest == null || current == null)
            {
                string latestText = latestTag.TrimStart('v').Replace("BazzBasic_", "", StringComparison.OrdinalIgnoreCase).Trim();
                return string.Equals(latestText, AppInfo.Version, StringComparison.OrdinalIgnoreCase)
                    ? $"You are running the latest version ({AppInfo.Version})."
                    : $"Latest release is {latestText} (you have {AppInfo.Version})\n{download}";
            }

            int cmp = CompareVersions(latest.Value, current.Value);
            string latestStr = FormatVersion(latest.Value);

            if (cmp > 0)
                return $"New version available: {latestStr} (you have {AppInfo.Version})\n{download}";
            if (cmp == 0)
                return $"You are running the latest version ({AppInfo.Version}).";
            return $"You are running {AppInfo.Version}, which is newer than the latest release ({latestStr}).";
        }
        catch (Exception ex)
        {
            return $"Update check failed: {ex.Message}";
        }
    }

    // Parses "1.5b", "v1.2b", "BazzBasic_1.3b" and dotless tags like "BazzBasic_15" / "BazzBasic_14c"
    // (release tags since 1.4 have no dot: BazzBasic_15 = 1.5).
    // Dots are optional: first digit = major, remaining digits = minor,
    // trailing letters = interim release ("" < "b" < "c"). Returns null if no version found.
    internal static (int Major, int Minor, string Suffix)? ParseVersion(string s)
    {
        var m = System.Text.RegularExpressions.Regex.Match(s ?? "", @"(\d)\.?(\d+)([a-z]*)\s*$",
            System.Text.RegularExpressions.RegexOptions.IgnoreCase);
        if (!m.Success) return null;
        return (int.Parse(m.Groups[1].Value), int.Parse(m.Groups[2].Value), m.Groups[3].Value.ToLowerInvariant());
    }

    private static int CompareVersions((int Major, int Minor, string Suffix) a, (int Major, int Minor, string Suffix) b)
    {
        if (a.Major != b.Major) return a.Major.CompareTo(b.Major);
        if (a.Minor != b.Minor) return a.Minor.CompareTo(b.Minor);
        return string.CompareOrdinal(a.Suffix, b.Suffix);
    }

    private static string FormatVersion((int Major, int Minor, string Suffix) v) => $"{v.Major}.{v.Minor}{v.Suffix}";
}
