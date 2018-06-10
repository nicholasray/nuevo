# Nuevo

After receiving a new computer, I went through a lot of pain getting my development environment setup. So I
tried to write an idempotent bash script to automate it for next time. Thank you [Thoughtbot](https://github.com/thoughtbot/laptop) for the inspiration.

This script installs brew packages (neovim, zsh, tmux, postgres, etc), apps (Chrome, Spectacle, Sourcetree), and npm packages (tern, prettier, etc), ruby gems (neovim, etc) that I find myself using on a regular basis. It also clones my [dotfiles](https://github.com/nicholasray/dotfiles) and symlinks them in your $HOME directory.

**Warning:** This script has not been thoroughly tested i.e. I haven't used it on a
brand new laptop yet. It still probably contains some bugs and is very much a
work in progress. _Use at your own risk._

### Installing

Run the script within your command line:

```
./setup.sh
```

That's it!

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
