export default {
  async fetch(_request, env, ctx) {
    const release = await latestRelease(env);
    const asset = findDmgAsset(release, env);
    const version = normalizeVersion(release.tag_name);
    const pubDate = new Date(release.published_at || release.created_at).toUTCString();
    const releaseNotesUrl = release.html_url;
    const downloadUrl = asset.browser_download_url;
    const length = String(asset.size);
    const body = `<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>Clipy2 Updates</title>
    <link>https://github.com/mergd/Clipy2/releases</link>
    <description>Clipy2 release feed</description>
    <item>
      <title>Clipy2 ${escapeXml(version)}</title>
      <sparkle:releaseNotesLink>${escapeXml(releaseNotesUrl)}</sparkle:releaseNotesLink>
      <pubDate>${escapeXml(pubDate)}</pubDate>
      <enclosure
        url="${escapeXml(downloadUrl)}"
        sparkle:version="${escapeXml(version)}"
        sparkle:shortVersionString="${escapeXml(version)}"
        length="${escapeXml(length)}"
        type="application/octet-stream" />
    </item>
  </channel>
</rss>
`;

    ctx.waitUntil(cacheRelease(env, release, asset));

    return new Response(body, {
      headers: {
        "Content-Type": "application/rss+xml; charset=utf-8",
        "Cache-Control": "public, max-age=300"
      }
    });
  }
};

async function latestRelease(env) {
  const owner = env.GITHUB_OWNER || "mergd";
  const repo = env.GITHUB_REPO || "Clipy2";
  const response = await fetch(`https://api.github.com/repos/${owner}/${repo}/releases/latest`, {
    headers: {
      "Accept": "application/vnd.github+json",
      "User-Agent": "clipy2-appcast-worker"
    }
  });

  if (!response.ok) {
    throw new Error(`GitHub release lookup failed: ${response.status}`);
  }

  return response.json();
}

function findDmgAsset(release, env) {
  const assetPattern = new RegExp(env.ASSET_REGEX || "^Clipy2-.*\\.dmg$");
  const asset = release.assets?.find((candidate) => assetPattern.test(candidate.name));

  if (!asset) {
    throw new Error(`No DMG asset found for ${release.tag_name}`);
  }

  return asset;
}

function normalizeVersion(tagName = "") {
  return tagName.replace(/^v/i, "");
}

async function cacheRelease(env, release, asset) {
  if (!env.CLIPY2_APPCAST_CACHE) { return; }

  await env.CLIPY2_APPCAST_CACHE.put("latest", JSON.stringify({
    release,
    asset,
    cachedAt: new Date().toISOString()
  }), { expirationTtl: 3600 });
}

function escapeXml(value = "") {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}
