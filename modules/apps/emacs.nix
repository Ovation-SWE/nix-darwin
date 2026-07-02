# modules/apps/emacs.nix
#
# Installs a macOS-optimised Emacs build and all Doom Emacs runtime
# dependencies. Clones Doom on first activation; never touches an existing
# installation or any Doom configuration (init.el, config.el, packages.el,
# ~/.config/doom, ~/.doom.d).
{ ... }: {

  # ── System packages (darwin level) ─────────────────────────────────────────
  # Placed here so they land on the system PATH before home-manager activates
  # and are available to all users / login shells.
  flake.modules.darwin.emacs = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      emacs-macport

      # ── Doom hard requirements ──────────────────────────────────────────
      git      # Doom's updater clones / pulls via git directly
      ripgrep  # required: Doom's default grep / search backend
      fd       # required: used for file finding across the project

      # ── TLS / crypto ───────────────────────────────────────────────────
      gnutls   # package.el and straight.el need TLS for HTTPS package sources

      # ── Data storage ───────────────────────────────────────────────────
      sqlite   # org-roam, forge, and other database-backed Doom modules

      # ── Syntax / tree-sitter ───────────────────────────────────────────
      tree-sitter  # CLI + shared library for Doom's treesitter grammar support

      # ── Image rendering ────────────────────────────────────────────────
      imagemagick  # inline images in org buffers, image-dired, org-download

      # ── Markup / XML parsing ───────────────────────────────────────────
      libxml2  # elfeed, html-tidy, and XML-mode parsing

      # ── Archive / compression ──────────────────────────────────────────
      unzip    # extracting package archives
      gzip     # straight.el tarball handling

      # ── GNU core utilities ─────────────────────────────────────────────
      # macOS ships BSD variants whose flags differ from GNU.
      # Doom (and many Emacs packages) assume GNU semantics.
      coreutils
      findutils
      gnused
      gawk

      # ── Build / compilation helpers ────────────────────────────────────
      cmake    # required to compile vterm and other native packages
      libtool  # GNU libtool — required by vterm (distinct from macOS libtool)

      # ── Emacs-specific runtime tools ───────────────────────────────────
      # fontconfig is required by doom doctor's font checker — without it
      # Doom cannot verify installed fonts at startup.
      fontconfig

      # Speeds up LSP by acting as a JSON proxy between Emacs and language
      # servers, reducing garbage collection pressure in Emacs.
      emacs-lsp-booster

      # ── Language servers ───────────────────────────────────────────────
      # Nix LSP — satisfies Eglot's 'nil' / 'nixd' lookup for .nix buffers.
      nil
      # JSON LSP — satisfies Eglot's 'vscode-json-language-server' lookup.
      vscode-langservers-extracted

      # org-download uses pngpaste to paste images from the clipboard
      # directly into org buffers (org-download-clipboard).
      pngpaste
      ispell
      # macOS coreutils does not include gls (GNU ls). coreutils-prefixed
      # provides all GNU coreutils under their g-prefixed names so dired
      # can find gls without shadowing the system ls.
      coreutils-prefixed
    ];

    # Fonts required by this Doom config.
    # nerd-icons (+icons flag on vertico/dired/ibuffer/treemacs) renders from
    # the Symbols font; doom-font/doom-variable-pitch-font/doom-big-font are
    # all set to "FiraCode Nerd Font" in config.el.
    # Declared here rather than relying on kitty.nix so emacs.nix is
    # self-contained — Nix deduplicates identical store paths at build time.
    fonts.packages = with pkgs; [
      nerd-fonts.fira-code     # doom-font (all three font slots in config.el)
      nerd-fonts.symbols-only  # nerd-icons glyph rendering
    ];

    # programs.zsh here is nix-darwin's zsh (not home-manager's), so this lands
    # in /etc/zshrc — read for every interactive zsh session regardless of
    # ZDOTDIR. home.sessionPath is not used because home-manager's session var
    # sourcing chain is only active when home-manager manages the shell itself.
    programs.zsh.interactiveShellInit = ''
      export PATH="$HOME/.config/emacs/bin:$PATH"

      # emacs-macport's raw binary crashes (NSImageCacheException, size-zero
      # icon) when launched directly as a Mach-O rather than through
      # LaunchServices/`open`. Route plain `emacs` invocations through the
      # linked .app bundle instead; pass -nw/--batch/daemon calls through
      # untouched so terminal and scripted usage are unaffected.
      emacs() {
        case "$*" in
          *-nw*|*--batch*|*--daemon*|*-Q*)
            command emacs "$@"
            ;;
          *)
            emacsclient -c -n --alternate-editor="" "$@"
            ;;
        esac
      }
    '';
  };

  # ── User environment (home-manager level) ──────────────────────────────────
  flake.modules.homeManager.emacs = { pkgs, lib, ... }: {

    # Start the Emacs daemon at login via a LaunchAgent so emacsclient can
    # connect immediately. KeepAlive restarts it if it crashes.
    launchd.agents.emacs-daemon = {
      enable = true;
      config = {
        ProgramArguments = [ "${pkgs.emacs-macport}/bin/emacs" "--daemon" ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/emacs-daemon.log";
        StandardErrorPath = "/tmp/emacs-daemon.log";
      };
    };

    # Clone Doom Emacs on first activation.
    # • Runs as the home-manager user (not root).
    # • $DRY_RUN_CMD is set to `echo` by home-manager in --dry-run mode.
    # • $VERBOSE_ECHO prints only when --verbose is passed.
    # • The nix store path for git is used directly to avoid PATH ordering issues.
    home.activation.installDoomEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      doom_dir="$HOME/.config/emacs"
      doom_bin="$doom_dir/bin/doom"

      if [ ! -d "$doom_dir" ]; then
        $VERBOSE_ECHO "doom-emacs: cloning doomemacs/doomemacs"
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone --depth 1 \
          https://github.com/doomemacs/doomemacs \
          "$doom_dir"

        # Initial sync: generates the profile, installs packages, builds
        # autoloads. Only runs once — on subsequent rebuilds doom_dir exists
        # so this block is skipped entirely.
        $VERBOSE_ECHO "doom-emacs: running initial doom sync"
        $DRY_RUN_CMD "$doom_bin" sync -e
      fi
    '';
  };
}
