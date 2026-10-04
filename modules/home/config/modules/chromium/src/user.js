// Chromium performance / RAM tuning, applied at every startup.
//
// user.js wins over the profile's stored Preferences, so treat this file as the
// source of truth for these keys and change them here instead of in
// chrome://settings. Units are documented per entry; KB/seconds unless noted.

// --- Memory ---------------------------------------------------------------
// 64 MB in-memory page cache. Negative means "no RAM cache at all", which
// starves back/forward navigation, so cap it instead.
pref("browser.cache.memory.size", 65536);

// Keep the disk cache bounded (256 MB) and let it age out on its own.
pref("browser.cache.disk_cache.size", 268435456);
pref("browser.cache.disk_cache.ttl", 604800);

// Trim what crash/session restore keeps alive per window.
pref("browser.session_history.max_entries", 5000);
pref("browser.sessionstore.max_tabs_undo_memory", 2048);
pref("browser.sessionstore.max_windows_undo", 1);

// --- Background work ------------------------------------------------------
// Nothing here runs an "app" that needs to stay resident.
pref("background_mode.enabled", false);
pref("background_networking_enabled", false);

// No push/background-sync chatter from the browser itself.
pref("push_messaging_enabled", false);

// Speculative prefetch costs RAM and bandwidth for links that are often never
// visited.
pref("prefetch.enabled", false);
pref("prefetch_next.enabled", false);
pref("network.dns_prefetch_enabled", false);

// Offer/accept translation prompts waste a process and a network round trip.
pref("translate.enabled", false);

// --- Networking -----------------------------------------------------------
// Fewer idle keep-alive sockets held open per host.
pref("network.http.max_persistent_connections_per_server", 4);
pref("network.http.max_connections_per_server", 20);
pref("network.http.max_connections", 100);

pref("tcp_fast_open", true);

// --- Tabs / crash restore -------------------------------------------------
// Tab discarding keeps memory flat when many tabs are open.
pref("tab_disscarding_on_idle_enabled", true);
pref("tab_disscarding_on_low_memory_mode_enabled", true);
pref("tab_disscarding_delay_ms", 30000);

// --- Rendering ------------------------------------------------------------
// Smooth scrolling is GPU work on every frame; keep it off for scrollers that
// animate anyway.
pref("enable_smooth_scrolling", false);

// Avoid the extra compositor frames from overscroll glow.
pref("overscroll_history_navigation", 2);

// --- Privacy / extras -----------------------------------------------------
// Ungated because the build is ungoogled anyway; keeps surprise prompts away.
pref("browser.enable_privacy_sandbox", false);
pref("enable_do_not_track", true);