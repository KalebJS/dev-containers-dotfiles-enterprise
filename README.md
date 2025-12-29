# dev-containers-dotfiles-enterprise

Dotfiles for VS Code Dev Containers - manages certificates and pip configuration.

## Structure

```
├── certs/          # Place .crt or .cert files here
├── pip.conf        # pip configuration (customize as needed)
└── install.sh      # Installation script
```

## Usage

1. Add your certificate files (`.crt` or `.cert`) to the `certs/` directory
2. Edit `pip.conf` with your private PyPI index or trusted hosts
3. Configure VS Code to use this repo as your dotfiles repository:
   - Open Settings → search "dotfiles"
   - Set **Dotfiles: Repository** to your repo URL
   - Set **Dotfiles: Install Command** to `./install.sh`

When a dev container starts, VS Code will clone this repo and run `install.sh` automatically.

## Manual Installation

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```
