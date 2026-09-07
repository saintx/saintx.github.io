{
  description = "saintx.github.io — Chirpy Jekyll blog";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # Matches .github/workflows/pages-deploy.yml (ruby-version: 3.4).
        # Chirpy 7.6 requires Ruby ~> 3.1. Do not use pkgs.bundler: ruby_3_4
        # already ships `bundle`, and a second Bundler fights it.
        ruby = pkgs.ruby_3_4;
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            ruby
            pkgs.pkg-config
            pkgs.git
            pkgs.libyaml
            pkgs.openssl
            pkgs.zlib
            pkgs.libxml2
            pkgs.libxslt
            pkgs.libffi
          ] ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            pkgs.libiconv
          ];

          shellHook = ''
            PS1='[blog] '"$PS1"

            # Gems stay in the repo (gitignored). Nothing is installed on the host.
            export BUNDLE_USER_HOME="$PWD/.bundle"
            export BUNDLE_PATH="$PWD/vendor/bundle"
            export BUNDLE_BIN="$PWD/vendor/bundle/bin"
            export BUNDLE_DISABLE_SHARED_GEMS=1

            # macOS login shells run path_helper, which puts /usr/bin (Ruby 2.6)
            # ahead of Nix. Keep the flake's Ruby first.
            export _BLOG_RUBY_BIN="${ruby}/bin"
            _blog_fix_path() {
              case "$PATH" in
                "$_BLOG_RUBY_BIN"*) ;;
                *) PATH="$_BLOG_RUBY_BIN:$BUNDLE_BIN:$PATH" ;;
              esac
            }
            _blog_fix_path

            if [ -n "''${ZSH_VERSION-}" ]; then
              autoload -U add-zsh-hook 2>/dev/null || true
              add-zsh-hook precmd _blog_fix_path 2>/dev/null || true
            fi

            mkdir -p "$BUNDLE_USER_HOME"

            if ! bundle check >/dev/null 2>&1; then
              echo "→ Installing gems into vendor/bundle..."
              bundle install
            fi

            echo "→ $(ruby -v)"
            echo "→ $(bundle -v)"
            echo "→ bundle exec jekyll serve"
          '';
        };
      });
}
