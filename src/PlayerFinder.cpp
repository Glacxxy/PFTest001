#include <pl/Mod.hpp>

#include <android/log.h>
#include <atomic>
#include <chrono>
#include <thread>

#define PF_LOGI(...) __android_log_print(ANDROID_LOG_INFO, "PlayerFinder", __VA_ARGS__)
#define PF_LOGW(...) __android_log_print(ANDROID_LOG_WARN, "PlayerFinder", __VA_ARGS__)

namespace player_finder {

class PlayerFinderMod {
public:
    static PlayerFinderMod &instance() {
        static PlayerFinderMod mod;
        return mod;
    }

    PlayerFinderMod() : self(*ll::mod::NativeMod::current()) {}

    bool load() {
        self.getLogger().info("Player Finder loaded (safe bootstrap)");
        PF_LOGI("Player Finder 0.1.0 loaded");
        return true;
    }

    bool enable() {
        enabled.store(true);
        self.getLogger().info("Player Finder enabled; no Bedrock offsets/hooks installed yet");
        PF_LOGI("Enabled safely; waiting for version-specific player bridge");

        // Intentionally do not hook or scan Minecraft memory here.
        // This bootstrap is meant to verify that the .levipack and lifecycle
        // registration work on the user's LeviLauncher installation first.
        return true;
    }

    bool disable() {
        enabled.store(false);
        self.getLogger().info("Player Finder disabled");
        return true;
    }

    bool unload() {
        self.getLogger().info("Player Finder unloaded");
        return true;
    }

private:
    ll::mod::NativeMod &self;
    std::atomic<bool> enabled{false};
};

} // namespace player_finder

PL_REGISTER_MOD(player_finder::PlayerFinderMod, player_finder::PlayerFinderMod::instance());
