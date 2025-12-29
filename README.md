# dev-containers-dotfiles-enterprise

Dotfiles for VS Code Dev Containers - manages certificates and pip configuration.

## Structure

```
├── certs.txt       # List of certificate URLs to download
├── pip.conf        # pip configuration (customize as needed)
├── uv.toml         # uv configuration (customize as needed)
└── install.sh      # Installation script
```

## Usage

1. Add certificate URLs to `certs.txt` (one URL per line)
2. Edit `pip.conf` with your private PyPI index or trusted hosts
3. Edit `uv.toml` with your uv settings
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
