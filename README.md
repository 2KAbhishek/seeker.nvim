<div align = "center">

<h1><a href="https://github.com/2kabhishek/seeker.nvim">seeker.nvim</a></h1>

<a href="https://github.com/2KAbhishek/seeker.nvim/blob/main/LICENSE">
<img alt="License" src="https://img.shields.io/github/license/2kabhishek/seeker.nvim?style=flat&color=eee&label="> </a>

<a href="https://github.com/2KAbhishek/seeker.nvim/graphs/contributors">
<img alt="People" src="https://img.shields.io/github/contributors/2kabhishek/seeker.nvim?style=flat&color=ffaaf2&label=People"> </a>

<a href="https://github.com/2KAbhishek/seeker.nvim/stargazers">
<img alt="Stars" src="https://img.shields.io/github/stars/2kabhishek/seeker.nvim?style=flat&color=98c379&label=Stars"></a>

<a href="https://github.com/2KAbhishek/seeker.nvim/network/members">
<img alt="Forks" src="https://img.shields.io/github/forks/2kabhishek/seeker.nvim?style=flat&color=66a8e0&label=Forks"> </a>

<a href="https://github.com/2KAbhishek/seeker.nvim/watchers">
<img alt="Watches" src="https://img.shields.io/github/watchers/2kabhishek/seeker.nvim?style=flat&color=f5d08b&label=Watches"> </a>

<a href="https://github.com/2KAbhishek/seeker.nvim/pulse">
<img alt="Last Updated" src="https://img.shields.io/github/last-commit/2kabhishek/seeker.nvim?style=flat&color=e06c75&label="> </a>

<h3>Progressive file seeker for Neovim 🔍🎯</h3>

<figure>
  <img src="doc/images/screenshot.png" alt="seeker.nvim in action">
  <br/>
  <figcaption>seeker.nvim in action</figcaption>
</figure>

</div>

seeker.nvim is a Neovim plugin that enables progressive file investigation by seamlessly switching between file filtering and content searching (grep), with each switch refining your results.

Built on top of [snacks.nvim](https://github.com/folke/snacks.nvim) picker, seeker provides a powerful workflow for narrowing down files by name, then searching within those files, then further refining the file list based on grep results - all without losing context.

## ✨ Features

- **Progressive Refinement**: Each mode switch narrows down results (File → Grep → File progressively filters)
- **Seamless Mode Switching**: Toggle between file and grep modes with a single keybinding
- **Smart File Selection**: Supports both Tab-selection and automatic filtering of visible results
- **Git Integration**: Auto-detects git repositories and uses `git_files` for faster, gitignore-aware searches
- **Configurable**: Customize toggle keys, notifications, picker options, and more
- **Zero External Dependencies**: Only requires snacks.nvim

## ⚡ Setup

### ⚙️ Requirements

- Latest version of `neovim` (0.9.0+)
- [snacks.nvim](https://github.com/folke/snacks.nvim)

### 💻 Installation

```lua
-- Lazy.nvim
{
    '2kabhishek/seeker.nvim',
    dependencies = { 'folke/snacks.nvim' },
    cmd = { 'Seeker' },
    keys = {
        { '<leader>sf', '<cmd>Seeker<cr>', desc = 'Seeker: Start file investigation' },
    },
    opts = {
        -- Add your custom configs here (optional)
    },
}
```

## 🚀 Usage

### Basic Workflow

1. **Start Seeker**: Run `:Seeker` or press `<leader>sf`
2. **Filter Files**: Type to filter files by name (standard file picker behavior)
3. **Switch to Grep**: Press `<C-,>` to search within the filtered files
4. **Search Content**: Type to search for content within those files
5. **Refine Files**: Press `<C-,>` again to see only files with matches
6. **Continue Refining**: Keep switching between modes to progressively narrow results

### Multi-Selection

- Press `<Tab>` to select specific files before switching modes
- If no files are selected, all visible filtered results are used
- Works in both file and grep modes

### Configuration

seeker.nvim can be configured using the following options:

```lua
require('seeker').setup({
    picker_type = 'git_files',  -- 'git_files' or 'files' (auto-detect if nil)
    toggle_key = '<C-,>',        -- Key to toggle between modes
    use_git_files = nil,         -- Auto-detect git repo (true/false to override)
    picker_opts = {              -- Options passed to snacks.picker
        layout = {
            preset = 'ivy',      -- or 'default', 'vertical', etc.
        },
    },
    notifications = true,        -- Show mode switch notifications
    add_default_keybindings = true,  -- Add <leader>sf keybinding
})
```

### Commands

- `:Seeker` - Start seeker file investigation

### Keybindings

| Keybinding   | Mode              | Description                  |
| ------------ | ----------------- | ---------------------------- |
| `<leader>sf` | Normal            | Start Seeker                 |
| `<C-,>`      | File Picker (n/i) | Toggle to Grep mode          |
| `<C-,>`      | Grep Picker (n/i) | Toggle to File mode          |
| `<Tab>`      | Picker (n/i)      | Select/deselect current item |

> You can customize the toggle key and disable default keybindings in the config.

### API

```lua
-- Start seeker programmatically
require('seeker').seek()

-- Start with custom options (merged with setup config)
require('seeker').seek({
    picker_opts = {
        layout = { preset = 'vertical' }
    }
})
```

## 🏗️ How It Works

### Progressive Refinement

Seeker uses a stateful approach to maintain context across mode switches:

1. **File → Grep**: Extracts filtered/selected files and searches only within those
2. **Grep → File**: Extracts unique files from grep results and shows only those files
3. **Repeat**: Each cycle progressively narrows down the result set

### State Management

- `state.file_list`: Files to search in grep mode
- `state.grep_files`: Files with matches (shown in file mode)
- `state.mode`: Current mode ('file' | 'grep')

### Smart Path Handling

- Auto-detects git repositories
- Handles both absolute and relative paths
- Validates file existence
- Supports multiple path formats from snacks.picker

## 🧪 Testing

```bash
# Run all tests
nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/init.lua'}"
# or
make

# Run specific test file
nvim --headless -c "PlenaryBustedFile tests/seeker/state_spec.lua {minimal_init = 'tests/init.lua'}"
```

## ⛅ Behind The Code

### 🌈 Inspiration

I frequently needed to investigate codebases by filtering files, then searching within those files, then further refining based on content - but existing tools required starting over each time. Seeker solves this by maintaining context across mode switches.

### 💡 Challenges/Learnings

- Understanding snacks.picker's API and item formats
- Managing state across picker instances
- Handling multiple path formats (string vs table items)
- Progressive refinement without losing context

### 🔍 Related Projects

- [snacks.nvim](https://github.com/folke/snacks.nvim) - The picker foundation
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Alternative fuzzy finder
- [fzf-lua](https://github.com/ibhagwan/fzf-lua) - Lua fzf implementation

## 🧰 Tooling

- [dots2k](https://github.com/2kabhishek/dots2k) — Dev Environment
- [nvim2k](https://github.com/2kabhishek/nvim2k) — Personalized Editor
- [sway2k](https://github.com/2kabhishek/sway2k) — Desktop Environment
- [qute2k](https://github.com/2kabhishek/qute2k) — Personalized Browser

### 🔍 More Info

- [nerdy.nvim](https://github.com/2kabhishek/nerdy.nvim) — Find nerd glyphs easily
- [tdo.nvim](https://github.com/2KAbhishek/tdo.nvim) — Fast and simple notes in Neovim
- [termim.nvim](https://github.com/2kabhishek/termim.nvim) — Neovim terminal improved
- [octohub.nvim](https://github.com/2kabhishek/octohub.nvim) — Github repos in Neovim
- [exercism.nvim](https://github.com/2kabhishek/exercism.nvim) — Exercism exercises in Neovim

<hr>

<div align="center">

<strong>⭐ hit the star button if you found this useful ⭐</strong><br>

<a href="https://github.com/2KAbhishek/seeker.nvim">Source</a>
| <a href="https://2kabhishek.github.io/blog" target="_blank">Blog </a>
| <a href="https://twitter.com/2kabhishek" target="_blank">Twitter </a>
| <a href="https://linkedin.com/in/2kabhishek" target="_blank">LinkedIn </a>
| <a href="https://2kabhishek.github.io/links" target="_blank">More Links </a>
| <a href="https://2kabhishek.github.io/projects" target="_blank">Other Projects </a>

</div>
