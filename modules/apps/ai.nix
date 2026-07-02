{ inputs, ... }:
{
  flake.modules.darwin.ai = { pkgs, ... }: {
    # Keeps the unfree scope limited/explicitly declared next to the tool itself
    nixpkgs.config.allowUnfree = true;

    # ComfyUI-nix's overlay exposes pkgs.comfy-ui (CPU + Metal on Apple Silicon)
    nixpkgs.overlays = [ inputs.comfyui-nix.overlays.default ];

    environment.systemPackages = [
      pkgs.claude-code
      pkgs.rtk

      # Model Runner: pull and run local LLMs (also serves an OpenAI-compatible API)
      pkgs.ollama

      # High-performance Apple runtime: Apple's Metal-accelerated MLX array framework,
      # the same runtime LM Studio and mlx-audio (TTS, below) build on
      pkgs.python3Packages.mlx

      # Image Generation, fine-grained control: node-based ComfyUI, Metal-accelerated
      pkgs.comfy-ui

      # Handy for any audio post-processing on TTS output (mp3 encode, joining chapters)
      pkgs.ffmpeg
    ];

    # Enable homebrew support inside nix-darwin
    homebrew.enable = true;

    # Third-party tap providing the mlx-audio TTS/STT server + CLI tools
    homebrew.taps = [ "guoqiao/tap" ];

    homebrew.casks = [
      "claude"
      "lm-studio"
      "anythingllm"
    ];

    homebrew.brews = [
      {
        name = "guoqiao/tap/mlx-audio-server";
        trusted = true;
        start_service = false;   # installed, not running
      }
    ];

    launchd.user.agents.comfyui = {
      command = "${pkgs.comfy-ui}/bin/comfy-ui --listen 127.0.0.1 --port 8188 --enable-manager";
      serviceConfig = {
        RunAtLoad = false;       # not run at login
        KeepAlive = false;       # not relaunched if it exits
        StandardOutPath = "/tmp/comfyui.log";
        StandardErrorPath = "/tmp/comfyui.error.log";
      };
    };

    environment.shellAliases = {
      comfyui-start = "launchctl kickstart -k gui/$(id -u)/org.nixos.comfyui && open http://127.0.0.1:8188";
      comfyui-stop = "launchctl kill SIGTERM gui/$(id -u)/org.nixos.comfyui";
      tts-start = "brew services run guoqiao/tap/mlx-audio-server";
      tts-stop = "brew services stop guoqiao/tap/mlx-audio-server";
    };
  };
}
