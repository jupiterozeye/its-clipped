# its-clipped

A subtle clipboard indicator that confirms when Ctrl+C/X actually worked.

## Quick Start

```bash
# Run directly
nix run github:jupiterozeye/its-clipped

# Install to user profile
nix profile install github:jupiterozeye/its-clipped

# Development shell with all dependencies
nix develop github:jupiterozeye/its-clipped
```

## Installation & Auto-start

### Option 1: Home Manager (Recommended)

Add to your home-manager configuration (usually `~/.config/home-manager/home.nix` or part of your NixOS config):

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    its-clipped.url = "github:jupiterozeye/its-clipped";
  };

  outputs = { nixpkgs, home-manager, its-clipped, ... }: {
    homeConfigurations.yourname = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        its-clipped.homeManagerModules.default
        {
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
      ];
    };
  };
}
```

Then run `home-manager switch`.

### Option 2: NixOS Configuration (Home Manager as NixOS module)

If you're using home-manager as a NixOS module:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    its-clipped.url = "github:jupiterozeye/its-clipped";
  };

  outputs = { nixpkgs, home-manager, its-clipped, ... }: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        {
          home-manager.users.yourname = {
            imports = [ its-clipped.homeManagerModules.default ];
            programs.its-clipped.enable = true;
          };
        }
      ];
    };
  };
}
```

Then run `sudo nixos-rebuild switch`.

### Option 3: Standalone (Without Home Manager)

If you don't use home-manager or NixOS and just want to run it manually:

```bash
# Add to your shell profile (.bashrc, .zshrc, etc.)
its-clipped &
```

Or create a systemd user service manually:

```bash
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/its-clipped.service <<EOF
[Unit]
Description=Subtle clipboard change indicator
After=graphical-session-pre.target
PartOf=graphical-session.target

[Service]
ExecStart=$(which its-clipped)
Restart=on-failure

[Install]
WantedBy=graphical-session.target
EOF

systemctl --user enable --now its-clipped.service
```

## Configuration Options

| Setting      | Default | Description                                  |
| ------------ | ------- | -------------------------------------------- |
| `interval`   | 500ms   | How often to check clipboard                |
| `timeout`    | 1500ms  | Notification display duration                |
| `urgency`    | low     | Notification urgency (low, normal, critical) |
| `maxPreview` | 50      | Max characters in preview                    |
| `icon`       | ""      | Notification icon name                       |

When using the home-manager module, configure these in the `settings` attribute. When running manually, use flags like `-interval=500ms`.

## Requirements

- `wl-clipboard` (Wayland) or `xclip` (X11)
- `libnotify` for notifications

All dependencies are automatically included when installed via Nix.

## Notes

- **Cut detection**: Works automatically (Ctrl+X puts content in clipboard)
- **Paste detection**: Not supported - there's no reliable way to detect paste events system-wide (paste reads from clipboard, doesn't modify it)
- **Background process**: Runs as a systemd user service when using home-manager, starts automatically on login
