# tmux-git-cloner

A tool that allows you to clone git repositories from multiple remotes (GitHub, Gitea) using fzf for interactive selection within tmux.

## Features

- **Multiple Remote Support**: Configure multiple GitHub and Gitea instances
- **CLI-Based Authentication**: Uses `gh` (GitHub CLI) and `tea` (Gitea CLI) for authentication - no separate token management required
- **SSH and HTTPS Cloning**: Choose your preferred clone protocol per remote
- **Interactive Selection**: Use fzf with tmux integration to browse and select repositories
- **Tmux Session Management**: Automatically creates a new tmux session for the clone process
- **Organized Storage**: Repositories are cloned into a structured directory (host/owner/repo)

## Prerequisites

### Required Tools

- `bash` (4.0+)
- `tmux`
- `fzf`
- `git`

### Remote CLIs (at least one required)

- `gh` - GitHub CLI (for GitHub and GitHub Enterprise)
- `tea` - Gitea CLI (for Gitea instances)

### Installation on common systems

**Debian/Ubuntu:**
```bash
sudo apt install tmux fzf git

# GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh

# Gitea CLI (tea) - download from https://gitea.com/gitea/tea/releases
```

**Arch Linux:**
```bash
sudo pacman -S tmux fzf git github-cli
# tea available from AUR
```

**macOS (Homebrew):**
```bash
brew install tmux fzf git gh tea
```

## Installation

1. Clone this repository or download the `tmux-git-cloner` script
2. Make it executable: `chmod +x tmux-git-cloner`
3. Move it to a directory in your PATH, e.g., `mv tmux-git-cloner ~/.local/bin/`

## Authentication

This tool uses the authentication from `gh` and `tea` CLIs, so you don't need to manage tokens separately.

### GitHub Authentication

```bash
# For github.com
gh auth login

# For GitHub Enterprise
gh auth login --hostname github.mycompany.com
```

### Gitea Authentication

```bash
# Add a Gitea login
tea login add --name myserver --url https://gitea.example.com --token YOUR_TOKEN
```

## Configuration

On first run, a default configuration file will be created at `~/.config/tmux-git-cloner/config`.

### Configuration Options

```bash
# Directory where repositories will be cloned
CLONE_DIR="${HOME}/repos"

# List of remotes to query (space-separated)
# Format: type:host:protocol
# Protocol can be 'ssh' or 'https'
REMOTES="github:github.com:https"
```

### Example Configurations

**Single GitHub remote:**
```bash
CLONE_DIR="${HOME}/code"
REMOTES="github:github.com:https"
```

**Multiple remotes with different protocols:**
```bash
CLONE_DIR="${HOME}/code"
REMOTES="github:github.com:https github:github.company.com:https gitea:git.mydomain.com:ssh"
```

## Usage

### Interactive Mode (Default)

```bash
tmux-git-cloner
```

This will:
1. Fetch repositories from all configured remotes using `gh` and `tea` CLIs
2. Present an fzf selection interface (in tmux popup if available)
3. On selection, clone the repository to `CLONE_DIR/host/owner/repo`
4. Create a new tmux session named after the repo and attach to it

### List Repositories

```bash
tmux-git-cloner --list
```

Lists all available repositories without cloning.

### Help

```bash
tmux-git-cloner --help
```

## Repository Structure

Repositories are cloned into a structured directory:

```
$CLONE_DIR/
├── github.com/
│   ├── username/
│   │   ├── repo1/
│   │   └── repo2/
│   └── organization/
│       └── repo3/
├── gitea.example.com/
│   └── username/
│       └── repo4/
└── github.company.com/
    └── org/
        └── repo5/
```

## Tmux Integration

The script automatically detects if it's running inside tmux:

- **Inside tmux**: Uses `fzf-tmux` for popup/split selection and `switch-client` to change sessions
- **Outside tmux**: Uses regular fzf and `attach-session` to enter tmux

When cloning, a new tmux session is created that:
1. Runs git clone
2. Automatically changes to the cloned directory
3. Drops you into a shell

## Tips

### Bind to a tmux key

Add to your `~/.tmux.conf`:

```bash
bind-key g display-popup -E -w 80% -h 60% "tmux-git-cloner"
```

Now press `prefix + g` to launch the cloner in a popup.

### Shell alias

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias tgc='tmux-git-cloner'
```

## Troubleshooting

### "No repositories found"

- Check that you're authenticated to your remotes:
  - GitHub: `gh auth status`
  - Gitea: `tea login list`
- Verify your REMOTES configuration matches the authenticated hosts

### Authentication errors

**GitHub:**
```bash
# Check status
gh auth status

# Re-authenticate
gh auth login

# For GitHub Enterprise
gh auth login --hostname github.company.com
```

**Gitea:**
```bash
# List logins
tea login list

# Add new login
tea login add --url https://gitea.example.com
```

### SSH clone failures

- Make sure your SSH key is added to the git host
- Verify SSH agent is running: `ssh-add -l`
- Test SSH connection: `ssh -T git@github.com`

## License

MIT License - feel free to use and modify as needed.
