export default {
  async fetch(_request, env) {
    const version = env.VERSION || "1.0.0";
    const body = `<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>Clipy2 Updates</title>
    <link>https://github.com/mergd/Clipy2/releases</link>
    <description>Clipy2 release feed</description>
    <item>
      <title>Clipy2 ${escapeXml(version)}</title>
      <sparkle:releaseNotesLink>${escapeXml(env.RELEASE_NOTES_URL)}</sparkle:releaseNotesLink>
      <pubDate>Fri, 08 May 2026 06:51:03 +0000</pubDate>
      <enclosure
        url="${escapeXml(env.DOWNLOAD_URL)}"
        sparkle:version="${escapeXml(version)}"
        sparkle:shortVersionString="${escapeXml(version)}"
        length="${escapeXml(env.DMG_LENGTH)}"
        type="application/octet-stream" />
    </item>
  </channel>
</rss>
`;

    return new Response(body, {
      headers: {
        "Content-Type": "application/rss+xml; charset=utf-8",
        "Cache-Control": "public, max-age=300"
      }
    });
  }
};

function escapeXml(value = "") {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}
