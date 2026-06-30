# modules/apps/writing.nix
#
# org-roam, ox-hugo, and Python writing-stack dependencies for Doom Emacs.
# Replaces ~/.config/doom/scripts/setup.sh declaratively.
#
# Covers:
#   - hugo (ox-hugo digital garden publishing)
#   - Python environment with pygments, scikit-learn, nltk (org-similarity)
#   - ~/org-roam directory and empty references.bib on first activation
#   - NLTK corpus data (stopwords, punkt) on first activation
#   - ~/blog Hugo site scaffold on first activation
{ ... }: {

  # ── System packages ──────────────────────────────────────────────────────────
  flake.modules.darwin.writing = { pkgs, ... }: {
    environment.systemPackages = [
      # Hugo — used by ox-hugo to publish org notes as a static site
      pkgs.hugo

      # Single wrapped Python that has all three packages importable.
      # Using withPackages rather than individual python3Packages.* entries
      # so that `python3 -c "import nltk, sklearn, pygments"` works from
      # any shell without setting PYTHONPATH manually.
      # pygmentize binary (needed by minted in latex.nix) comes from here.
      (pkgs.python3.withPackages (ps: with ps; [
        pygments    # minted code highlighting — pygmentize binary
        scikit-learn # org-similarity semantic search
        nltk         # org-similarity NLP tokenisation
      ]))
    ];
  };

  # ── User-level one-time setup ─────────────────────────────────────────────
  flake.modules.homeManager.writing = { pkgs, lib, ... }: {
    home.activation.setupWritingEnv = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # ── org-roam directory ──────────────────────────────────────────────
      $DRY_RUN_CMD mkdir -p "$HOME/org-roam"

      # Empty bibliography file — citar/org-cite look for this path.
      # Guard prevents overwriting an existing bibliography.
      if [ ! -f "$HOME/org-roam/references.bib" ]; then
        $DRY_RUN_CMD touch "$HOME/org-roam/references.bib"
        $VERBOSE_ECHO "writing: created empty ~/org-roam/references.bib"
      fi

      # ── NLTK corpus data ────────────────────────────────────────────────
      # Downloads stopwords, punkt, and punkt_tab to ~/nltk_data.
      # Guard on the directory so this only runs once per machine.
      if [ ! -d "$HOME/nltk_data" ]; then
        $VERBOSE_ECHO "writing: downloading NLTK corpora"
        $DRY_RUN_CMD ${pkgs.python3.withPackages (ps: [ ps.nltk ])}/bin/python3 -c "
import nltk
nltk.download('stopwords', quiet=True)
nltk.download('punkt', quiet=True)
nltk.download('punkt_tab', quiet=True)
" || true
      fi

      # ── Hugo blog scaffold ──────────────────────────────────────────────
      # Creates ~/blog with PaperMod theme only if the directory is absent.
      # Leaves an existing blog completely untouched.
      if [ ! -d "$HOME/blog" ]; then
        $VERBOSE_ECHO "writing: scaffolding Hugo site at ~/blog"
        $DRY_RUN_CMD ${pkgs.hugo}/bin/hugo new site "$HOME/blog"
        $DRY_RUN_CMD mkdir -p "$HOME/blog/content/notes"
        $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$HOME/blog" init
        $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$HOME/blog" submodule add \
          https://github.com/adityatelange/hugo-PaperMod.git \
          themes/PaperMod || true
        $VERBOSE_ECHO "writing: Hugo site ready at ~/blog"
      fi
    '';
  };
}
