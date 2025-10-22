<div align = "center">

<h1><a href="https://github.com/2kabhishek/template.nvim">template.nvim</a></h1>

<a href="https://github.com/2KAbhishek/template.nvim/blob/main/LICENSE">
<img alt="License" src="https://img.shields.io/github/license/2kabhishek/template.nvim?style=flat&color=eee&label="> </a>

<a href="https://github.com/2KAbhishek/template.nvim/graphs/contributors">
<img alt="People" src="https://img.shields.io/github/contributors/2kabhishek/template.nvim?style=flat&color=ffaaf2&label=People"> </a>

<a href="https://github.com/2KAbhishek/template.nvim/stargazers">
<img alt="Stars" src="https://img.shields.io/github/stars/2kabhishek/template.nvim?style=flat&color=98c379&label=Stars"></a>

<a href="https://github.com/2KAbhishek/template.nvim/network/members">
<img alt="Forks" src="https://img.shields.io/github/forks/2kabhishek/template.nvim?style=flat&color=66a8e0&label=Forks"> </a>

<a href="https://github.com/2KAbhishek/template.nvim/watchers">
<img alt="Watches" src="https://img.shields.io/github/watchers/2kabhishek/template.nvim?style=flat&color=f5d08b&label=Watches"> </a>

<a href="https://github.com/2KAbhishek/template.nvim/pulse">
<img alt="Last Updated" src="https://img.shields.io/github/last-commit/2kabhishek/template.nvim?style=flat&color=e06c75&label="> </a>

<h3>Ready to go Neovim template 🏗️✈️</h3>

<figure>
  <img src="doc/images/screenshot.png" alt="template.nvim in action">
  <br/>
  <figcaption>template.nvim in action</figcaption>
</figure>

</div>

template.nvim is a neovim plugin that allows neovim users to `<action>`.

## ✨ Features

- **Modern Plugin Architecture**: Ready-to-go Neovim plugin template with best practices
- **Unified Command System**: Modern command interface with tab completion support
- **Type Safety**: Comprehensive type annotations using LSP-compatible `@class` and `@param`
- **DRY Code Patterns**: Reusable helper functions and modular design
- **CI/CD Ready**: Lint and test GitHub Actions included
- **Auto Documentation**: GitHub Action to auto-generate vimdocs
- **Professional README**: Complete template with modern formatting
- **Integration Ready**: Works seamlessly with [mkrepo](https://github.com/2kabhishek/mkrepo)

## ⚡ Setup

### ⚙️ Requirements

- Latest version of `neovim`

### 💻 Installation

```lua
-- Lazy
{
    '2kabhishek/template.nvim',
    cmd = { 'Template' },
    keys = { '<leader>th', '<leader>tH', },
    -- Add your custom configs here, keep it blank for default configs (required)
    opts = {},
    -- Use this for local development
    -- dir = '~/path-to/template.nvim',
},
```

## 🚀 Usage

1. Fork the `template.nvim` repo
2. Update the plugin name, file names etc, change `template` to `your-plugin-name`
3. Add the code required for your plugin:
   - **Code entrypoint**: [template.lua](./lua/template.lua) - Main setup function
   - **User configs**: [config.lua](./lua/template/config.lua) - Configuration with type annotations
   - **Commands**: [commands.lua](./lua/template/commands.lua) - Modern command system with completion
   - **Plugin logic**: [module.lua](./lua/template/module.lua) - Core functionality with type safety
   - **Additional modules**: Add more modules under [modules](./lua/template/) directory as needed
4. **Command System Features**:
   - Unified command interface with subcommands
   - Tab completion support for better UX
   - Reusable helper functions for DRY code
   - Comprehensive type annotations for better development experience
5. Add test code to the [tests](./tests/) directory
6. Update the README with your plugin's functionality
7. Tweak the [docs action](./.github/workflows/docs.yml) file to reflect your plugin name, commit email and username
   - Generating vimdocs needs read and write access to actions (repo settings > actions > general > workflow permissions)

### Configuration

template.nvim can be configured using the following options:

```lua
template.setup({
    name = 'template.nvim', -- Name to be greeted, 'World!' by default
    add_default_keybindings = true, -- Whether to add default keybindings
})
```

### Commands

`template.nvim` provides a unified command interface with tab completion:

- `Template greet [name]` - Shows a hello message with the specified name (with tab completion)
- `Template notify [message]` - Shows a notification with custom message

### Keybindings

Here are the default keybindings:

| Keybinding   | Command                 | Description                 |
| ------------ | ----------------------- | --------------------------- |
| `<leader>th` | `Template greet`        | Template greet default name |
| `<leader>tH` | `Template greet Neovim` | Template greet Neovim       |

> You can disable default keybindings by setting `add_default_keybindings = false` in your config.

### Help

Run `:help template.txt` for more details.

## 🏗️ What's Next

Planning to add `<feature/module>`.

### ✅ To-Do

- [x] Setup repo
- [ ] Think real hard
- [ ] Start typing

## ⛅ Behind The Code

### 🌈 Inspiration

template.nvim was inspired by [nvim-plugin-template](https://github.com/ellisonleao/nvim-plugin-template), I added some changes on top to make setting up a new plugin faster.

### 💡 Challenges/Learnings

- The main challenges were `<issue/difficulty>`
- I learned about `<learning/accomplishment>`

### 🧰 Tooling

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

<a href="https://github.com/2KAbhishek/template.nvim">Source</a>
| <a href="https://2kabhishek.github.io/blog" target="_blank">Blog </a>
| <a href="https://twitter.com/2kabhishek" target="_blank">Twitter </a>
| <a href="https://linkedin.com/in/2kabhishek" target="_blank">LinkedIn </a>
| <a href="https://2kabhishek.github.io/links" target="_blank">More Links </a>
| <a href="https://2kabhishek.github.io/projects" target="_blank">Other Projects </a>

</div>
