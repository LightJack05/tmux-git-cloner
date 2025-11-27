# tmux-git-cloner

A tool that allows you to clone git repositories from multiple remotes (GitHub, Gitea) using fzf for interactive selection within tmux.

## Features

- **Multiple Remote Support**: Configure multiple GitHub and Gitea instances
- **SSH and HTTPS Cloning**: Choose your preferred clone protocol
- **Interactive Selection**: Use fzf with tmux integration to browse and select repositories
- **Tmux Session Management**: Automatically creates a new tmux session for the clone process
- **Organized Storage**: Repositories are cloned into a structured directory (host/owner/repo)

## Prerequisites

The following tools must be installed:

- `bash` (4.0+)
- `tmux`
- `fzf`
- `git`
- `curl`
- `jq`

### Installation on common systems

**Debian/Ubuntu:**
```bash
sudo apt install tmux fzf git curl jq
```

**Arch Linux:**
```bash
sudo pacman -S tmux fzf git curl jq
```

**macOS (Homebrew):**
```bash
brew install tmux fzf git curl jq
```

## Installation

1. Clone this repository or download the `tmux-git-cloner` script
2. Make it executable: `chmod +x tmux-git-cloner`
3. Move it to a directory in your PATH, e.g., `mv tmux-git-cloner ~/.local/bin/`

## Configuration

On first run, a default configuration file will be created at `~/.config/tmux-git-cloner/config`.

### Configuration Options

```bash
# Directory where repositories will be cloned
CLONE_DIR="${HOME}/repos"

# Clone protocol: ssh or https
CLONE_PROTOCOL="ssh"
```

### Adding Remotes

#### GitHub

```bash
REMOTE_github_TYPE=github
REMOTE_github_HOST=github.com
REMOTE_github_USER=yourusername    # Optional: filter to specific user's repos
REMOTE_github_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
```

To create a GitHub personal access token:
1. Go to GitHub → Settings → Developer settings → Personal access tokens
2. Generate a new token with `repo` scope (for private repos) or `public_repo` (for public only)

#### GitHub Enterprise

```bash
REMOTE_github_enterprise_TYPE=github
REMOTE_github_enterprise_HOST=github.mycompany.com
REMOTE_github_enterprise_API_URL=https://github.mycompany.com/api/v3
REMOTE_github_enterprise_TOKEN=your_token
```

#### Gitea

```bash
REMOTE_gitea_TYPE=gitea
REMOTE_gitea_HOST=gitea.example.com
REMOTE_gitea_API_URL=https://gitea.example.com/api/v1
REMOTE_gitea_TOKEN=your_gitea_token
```

To create a Gitea token:
1. Go to Gitea → Settings → Applications → Generate New Token
2. Give it a name and appropriate permissions

### Multiple Remotes Example

```bash
CLONE_DIR="${HOME}/code"
CLONE_PROTOCOL="ssh"

# Personal GitHub
REMOTE_github_TYPE=github
REMOTE_github_HOST=github.com
REMOTE_github_TOKEN=ghp_personal_token

# Work GitHub Enterprise
REMOTE_work_TYPE=github
REMOTE_work_HOST=github.company.com
REMOTE_work_API_URL=https://github.company.com/api/v3
REMOTE_work_TOKEN=ghp_work_token

# Personal Gitea
REMOTE_gitea_TYPE=gitea
REMOTE_gitea_HOST=git.mydomain.com
REMOTE_gitea_API_URL=https://git.mydomain.com/api/v1
REMOTE_gitea_TOKEN=gitea_token
```

## Usage

### Interactive Mode (Default)

```bash
tmux-git-cloner
```

This will:
1. Fetch repositories from all configured remotes
2. Present an fzf selection interface (in tmux popup if available)
3. On selection, clone the repository to `CLONE_DIR/host/owner/repo`
4. Create a new tmux session named after the repo and attach to it

### List Repositories

```bash
tmux-git-cloner --list
```

Lists all available repositories without cloning.

### Edit Configuration

```bash
tmux-git-cloner --config
```

Opens the configuration file in your default editor.

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
1. Shows the clone progress
2. Automatically changes to the cloned directory
3. Drops you into a shell when complete

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

- Check that your tokens are valid and have the correct permissions
- Verify the API URLs are correct for enterprise instances
- Run with `--list` to see if repositories are being fetched

### Authentication errors

- GitHub tokens should have `repo` or `public_repo` scope
- Gitea tokens should have appropriate read permissions
- Ensure tokens haven't expired

### SSH clone failures

- Make sure your SSH key is added to the git host
- Verify SSH agent is running: `ssh-add -l`
- Test SSH connection: `ssh -T git@github.com`

## License

MIT License - feel free to use and modify as needed.
