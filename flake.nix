{
  description = "tmux-git-cloner - clone git repositories from configured remotes via fzf and tmux";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        default = tmux-git-cloner;
        tmux-git-cloner = pkgs.stdenvNoCC.mkDerivation {
          pname = "tmux-git-cloner";
          version = "0-unstable-2026-08-09";
          src = self;

          nativeBuildInputs = [ pkgs.makeWrapper ];

          dontBuild = true;

          installPhase = ''
            runHook preInstall
            install -Dm755 tmux-git-cloner -t $out/bin
            runHook postInstall
          '';

          postFixup =
            let
              runtimeDeps = with pkgs; [
                tmux
                fzf
                git
                gh
                tea
                glab
                gawk
                gnugrep
                gnused
                coreutils
              ];
            in
            ''
              wrapProgram $out/bin/tmux-git-cloner --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}
            '';

          meta = {
            description = "Clone git repositories from configured remotes via fzf and tmux";
            mainProgram = "tmux-git-cloner";
            platforms = systems;
          };
        };
      });

      overlays.default = final: prev: {
        tmux-git-cloner = self.packages.${final.stdenv.hostPlatform.system}.tmux-git-cloner;
      };
    };
}
