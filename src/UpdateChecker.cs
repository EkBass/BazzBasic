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
            // Tags may be "v1.2b", "BazzBasic_1.2b" etc. — strip known prefixes
            string latestVersion = latestTag
                .TrimStart('v')
                .Replace("BazzBasic_", "")
                .Replace("bazzbasic_", "")
                .Trim();

            if (string.Equals(latestVersion, AppInfo.Version, StringComparison.OrdinalIgnoreCase))
                return $"You are running the latest version ({AppInfo.Version}).";

            // DEbUG: remove after confirming correct behavior
            return $"New version available: {latestVersion} (you have {AppInfo.Version})\n" +
                   $"Download: https://github.com/EkBass/BazzBasic/releases/latest";
        }
        catch (Exception ex)
        {
            return $"Update check failed: {ex.Message}";
        }
    }
}
