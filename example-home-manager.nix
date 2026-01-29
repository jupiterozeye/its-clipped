{ ... }:

{
  imports = [
    # Import the home-manager module
    ./home-manager.nix
  ];

  programs.its-clipped = {
    enable = true;
    settings = {
      interval = "500ms";
      timeout = "1500ms";
      urgency = "low";
      maxPreview = 50;
    };
  };
}
