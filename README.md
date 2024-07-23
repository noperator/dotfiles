# ❤️ `~/.*`

Ensuring that Bash uses vi mode wherever I go.

<div align="center">
    <img src="https://i.imgur.com/YilN0MH.png" width="600px" />
</div>

## Description

I use multiple workstations, virtual machines, remote servers, etc. and like for them all to have the same feel. I finally started this repo after I'd repeatedly:
- Use a new workstation and have no idea where any of my windows are
- SSH into a VPS and hit the Escape key expecting Readline to put me in vi's normal mode, as on my laptop—but nothing would happen
- Edit a file with Vim on a remote server, but none of my shortcuts would work, breaking my workflow

### Features

- All of the various Bash config files (e.g., `.bash_profile`, `.bashrc`, etc.) redirect to `.bashrc`, which in turn sources:
  - Scripts in `.bashrc.d/`, which breaks out aliases, functions, etc. into categorically named files
  - A single `.bashrc.extra` file containing machine-specific items that I don't want to publicize or track in version control
- Potentially conflicting OS-specific commands, configurations, etc. are broken out with Bash `case` statements
- A linking script, `link.sh`, symbolically links config files throughout their standard locations, making new installs easy
- Remote terminal windows have a different prompt style than local ones
- Does not include a `.gitconfig` file, so [this](https://twitter.com/TomNomNom/status/1223702654267904000) doesn't happen to you
- No support for Windows
- and much, _much_ more!

### Built with

| Utility           | Agnostic        | macOS       | Linux    |
| ---               | :---:           | :---:       | :---:    |
| Browser           | Chrome w/Vimium |             |          |
| Shell             | Bash            |             |          |
| Status Bar        |                 | Übersicht   | i3blocks |
| Terminal Emulator |                 | kitty       | urxvt    |
| Text Editor       | Neovim          |             |          |
| VPN Client        |                 | Tunnelblick | OpenVPN  |
| Window Manager    |                 | yabai       | i3       |

## Getting started

### Install

```
git -C "$HOME" clone https://github.com/noperator/dotfiles.git && cd "$HOME/dotfiles"
./link.sh
```

### Configure

<details><summary>Blocks</summary>

Create a file at `blocks/.env` containing the names of the Wi-Fi and Ethernet interfaces that you'd like to be displayed in the status bar. For example, on macOS this might look like:

```
WIFI_IFACE='en0'
ETH_IFACE='en4'
```

Note that the name of the VPN interface is determined automatically.

</details>

<details><summary>Browser keys</summary>

Arc keyboard shortcuts.

```
cat Library/Application\ Support/Arc/StorableKeyBindings.json |
    jq '.userOverrides | map({
            mod: .state.valid._0 .deviceIndependentModifierFlags,
            key: .state.valid._0 .keyEquivalent,
            action: .action.name
        }) |
        group_by(.mod) |
        map({
            mod: .[0].mod,
            shortcuts: map(del(.mod) | .key + ": " + .action) | sort
        })'

[
  {
    "mod": null,
    "shortcuts": [
      ": Archive Tab"
    ]
  },
  {
    "mod": 262144,
    "shortcuts": [
      ",: Preferences…",
      "h: Go Back",
      "j: Next Tab",
      "k: Previous Tab",
      "l: Go Forward",
      "o: Open Command Bar",
      "p: Pin/Unpin Tab",
      "s: Reveal/Hide Sidebar",
      "x: Reopen Last Closed Tab",
      "y: Copy Page URL"
    ]
  },
  {
    "mod": 393216,
    "shortcuts": [
      "h: Previous Space",
      "l: Next Space",
      "o: New Tab…",
      "y: Copy URL as Markdown"
    ]
  },
  {
    "mod": 786432,
    "shortcuts": [
      "o: Add Split View"
    ]
  }
]
```

Vimium key mappings ([download backup](blob:chrome-extension://dbepggeogbaibhgnhhndojpepiihcmeb/1f6a297b-2c9a-46fb-9048-2dd9ad180cf6)).

```
map K previousTab
map J nextTab
```

</details>


## Back matter

### See also

My related [guides](https://github.com/noperator/guides) for manual tasks and configurations that aren't automatically covered by this dotfiles repo.
