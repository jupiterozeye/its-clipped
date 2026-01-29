{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    go
    libnotify
    xclip
    wl-clipboard
    clipnotify
  ];
}
