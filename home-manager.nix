{ config, pkgs, lib, ... }:

let
  cfg = config.programs.its-clipped;
in {
  options.programs.its-clipped = {
    enable = lib.mkEnableOption "its-clipped clipboard indicator";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.its-clipped or (pkgs.callPackage ./flake.nix {});
      description = "The its-clipped package to use";
    };
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      example = {
        interval = "500ms";
        timeout = "1500ms";
        urgency = "low";
        maxPreview = 50;
      };
      description = "Settings passed to its-clipped";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    
    systemd.user.services.its-clipped = {
      Unit = {
        Description = "Subtle clipboard change indicator";
        After = ["graphical-session-pre.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/its-clipped ${
          lib.concatStringsSep " " (lib.mapAttrsToList (k: v: "-${k}=${toString v}") cfg.settings)
        }";
        Restart = "on-failure";
        Environment = "PATH=${lib.makeBinPath [pkgs.wl-clipboard pkgs.xclip pkgs.libnotify]}";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
