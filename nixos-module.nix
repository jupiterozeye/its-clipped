{ config, pkgs, lib, ... }:

let
  cfg = config.services.its-clipped;
in {
  options.services.its-clipped = {
    enable = lib.mkEnableOption "its-clipped clipboard indicator system-wide";
    
    package = lib.mkOption {
      type = lib.types.package;
      description = "The its-clipped package to use (required)";
    };
    
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = [ "alice" "bob" ];
      description = "Users for which to enable the clipboard indicator";
    };
    
    defaultSettings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        interval = "500ms";
        timeout = "1500ms";
        urgency = "low";
        maxPreview = 50;
      };
      example = {
        interval = "500ms";
        timeout = "1500ms";
        urgency = "low";
        maxPreview = 50;
      };
      description = "Default settings for all users";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    
    systemd.user.services = lib.mkMerge (map (user: {
      "its-clipped-${user}" = {
        description = "Subtle clipboard change indicator for ${user}";
        after = [ "graphical-session-pre.target" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        
        serviceConfig = {
          ExecStart = "${cfg.package}/bin/its-clipped ${
            lib.concatStringsSep " " (lib.mapAttrsToList (k: v: "-${k}=${toString v}") cfg.defaultSettings)
          }";
          Restart = "on-failure";
          Environment = "PATH=${lib.makeBinPath [pkgs.wl-clipboard pkgs.xclip pkgs.libnotify]}";
        };
      };
    }) cfg.users);
  };
}
