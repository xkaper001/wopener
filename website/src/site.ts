// Central site config. Edit these in one place.

export const TAGLINE = "The Web Opener Apple Forgot";

// Cloudflare Web Analytics beacon token (public, client-side). Empty = disabled.
// Get it: Cloudflare dash → Analytics & Logs → Web Analytics → Add a site.
export const CF_BEACON_TOKEN = ""; // paste token from CF dashboard

// Direct .dmg download. GitHub keeps /releases/latest/download/<asset>
export const DOWNLOAD_URL = "https://github.com/xkaper001/wopener/releases/latest/download/Wopener.dmg";

export const REPO_URL = "https://github.com/xkaper001/wopener";
export const RELEASES_URL = "https://github.com/xkaper001/wopener/releases";

export const MIN_MACOS = "macOS 26.0";
export const LICENSE = "Apache 2.0";

// --- Notarisation fund ---------------------------------------------------
// The Apple Developer Program costs $99/yr; that's the wall between Wopener
// and notarised, double-click-to-open releases. Edit RAISED as sponsors roll
// in (GitHub Sponsors has no public total API, so this is updated by hand).
export const SPONSOR_URL = "https://github.com/sponsors/xkaper001";
export const NOTARY_GOAL = 99; // USD, one year of notarised releases
export const NOTARY_RAISED = 0; // USD raised so far — bump me
export const KIMCHI_URL = "https://tr.ee/lpzVfB";
export const KIMCHI_LOGO = "/kimchi.png";
