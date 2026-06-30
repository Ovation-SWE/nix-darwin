# modules/apps/latex.nix
#
# Full LaTeX/PDF export stack for Doom Emacs.
# Replaces ~/.config/doom/scripts/install-latex.sh declaratively.
#
# Covers:
#   - Org → PDF export (latexmk + pdflatex)
#   - minted code highlighting (Pygments comes from writing.nix)
#   - dvisvgm inline math preview in org buffers
#   - biblatex/biber citations
#   - memoir, tufte-latex document classes
#   - catppuccinpalette theme
#   - texlab LSP server (Doom :lang latex +lsp)
{ ... }: {
  flake.modules.darwin.latex = { pkgs, ... }: {
    environment.systemPackages = [
      # TeX Live: scheme-medium base + all extras required by this config.
      # scheme-medium covers: geometry, hyperref, amsmath, Computer Modern,
      # Latin Modern, graphicx, TikZ/PGF, parskip, etoolbox, and more.
      # catppuccinpalette is in nixpkgs so no tlmgr user-install needed.
      (pkgs.texlive.combine {
        inherit (pkgs.texlive)
          scheme-medium

          # ── Build / automation ──────────────────────────────────────────
          latexmk           # build automation (replaces manual pdflatex runs)

          # ── Bibliography ───────────────────────────────────────────────
          biblatex          # citation management
          biber             # biblatex backend (replaces BibTeX)

          # ── Code highlighting ──────────────────────────────────────────
          minted            # code blocks via Pygments (pygmentize from writing.nix)

          # ── Tables / layout ────────────────────────────────────────────
          booktabs          # professional-quality tables
          titlesec          # section heading formatting

          # ── Document classes ───────────────────────────────────────────
          memoir            # memoir book/report class
          tufte-latex       # Tufte-style handout and book classes

          # ── SVG / image preview ────────────────────────────────────────
          dvisvgm           # converts DVI→SVG for org inline math preview

          # ── Theme ──────────────────────────────────────────────────────
          catppuccinpalette # Catppuccin color palette for LaTeX headings
          ;
      })

      # LaTeX LSP server — provides completion, diagnostics, and hover in
      # .tex buffers when the Doom :lang latex +lsp flag is active.
      pkgs.texlab
    ];
  };
}
