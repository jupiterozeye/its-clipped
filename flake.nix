{
  description = "Subtle clipboard change indicator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    home-manager,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.x86_64-linux.default = pkgs.buildGoModule {
      pname = "its-clipped";
      version = "0.1.0";

      src = self;

      vendorHash = null;

      nativeBuildInputs = with pkgs; [
        makeWrapper
      ];

      buildInputs = with pkgs; [
        libnotify
      ];

      postInstall = ''
        wrapProgram $out/bin/its-clipped \
          --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [wl-clipboard xclip libnotify])}
      '';

      meta = {
        description = "Subtle clipboard change indicator with visual notifications";
        longDescription = ''
          A minimal clipboard monitor that shows subtle notifications when content
          is copied to the clipboard. Designed to be unobtrusive while confirming
          that Ctrl+C/X worked.

          Features:
          - Works with both Wayland (wl-paste) and X11 (xclip)
          - Subtle notifications that auto-dismiss
          - Content preview in notification
          - Duplicate change detection (ignores repeated copies)
        '';
        homepage = "https://github.com/jupiterozeye/its-clipped";
        license = pkgs.lib.licenses.mit;
        mainProgram = "its-clipped";
      };
    };

    # Home Manager module
    homeManagerModules.default = import ./home-manager.nix;
    
    # NixOS system module
    nixosModules.default = import ./nixos-module.nix;

    devShells.x86_64-linux.default = pkgs.mkShell {
      packages = with pkgs; [
        go
        wl-clipboard
        xclip
        libnotify
      ];
    };
  };
}
