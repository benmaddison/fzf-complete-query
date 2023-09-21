# fzf-complete-query

A set of `bash` scripts to build an address cache using `notmuch` and look
them up from `mutt`/`neomutt`

## description

These scripts work together as follows:
- `scripts/notmuch/post-new`:
  Runs is called by `notmuch` in the `post-new` hook to build a complete cache
  of addresses appearing in the mail database.
- `scripts/mutt/address-query.sh`:
  Reads the address cache, formats each entry with `jq` and `sed`, and then
  runs `fzf` for address selection.
- `scripts/mutt/address-query-wrapper.sh`:
  Creates a named pipe for receiving results from `address-query.sh` and then
  launches a new terminal running `address-query.sh` for user input.

The reason for the wrapper design and the separate terminal is that anything
which writes to STDERR (like `fzf`) messes up the `(neo)mutt` terminal.
Because the "editor" mode lacks a `<refresh>/<redraw-screen>` command, there is
no way (that I can find) to recover from this without user intervention.

The expectation is that the window manager/terminal are configured such that
`fzf` terminal is launched as a floating window over `(neo)mutt` terminal window.
With a bit of effort, a similar effect could probably be achieved with `tmux` (etc.)

## dependencies

The scripts themselves require:
- `notmuch`: to build the address cache
- `jq`: to read and write the cache (which is serialised as `json`)
- `tput` and `sed`: to color the address list given to `fzf`
- `fzf`: obviously

Additionally, the scripts make certain assumptions about the desktop environment:

I use `alacritty` as my terminal emulator and `i3wm` as my window manager, and
this is the only combination that I have tested, or plan to test.
However, I'm happy to accept pull-requests that add generality for the purposes
of making things easier in other environments.

The `fzf` terminal is launched with `--class fzf_xfloating` to set the `WM_CLASS`
of the window. In my `i3wm` configuration, I have:
```
for_window [instance=^.+_xfloating$] floating enable
```
to make the resulting window float.

A similar effect is probably achievable in many other terminal/WM combinations,
but I have attempted none.

## setup

The scripts need to be moved/symlinked to specific locations in order to be usable.

My layout is as follows:
- Maildir is in `$XDG_DATA_HOME/mail`
- `muttrc` is in `$XDG_CONFIG_HOME/mutt`

Therefore, to link things into place (from my local clone of this repo):
```bash
SCRIPTS_DIR="$(git rev-parse --show-toplevel)/scripts"
ln -s "$SCRIPTS_DIR/notmuch/post-new" "$XDG_DATA_HOME/mail/.notmuch/hooks/"
mkdir -p "$XDG_CONFIG_HOME/mutt/scripts"
ln -s "$SCRIPTS_DIR/mutt/*.sh" "$XDG_CONFIG_HOME/mutt/scripts/"
```

Then, in `muttrc`:
```muttrc
set   my_confdir          = "~/.config/mutt"            # base config directory
set   my_scriptsdir       = "$my_confdir/scripts"
bind  editor              <tab> complete-query
set   query_command       = "$my_scriptsdir/address-query-wrapper.sh %s"
```

Adjust as necessary for your directory layout.

## running

Make sure that `notmuch new` is being called somehow (I use a `systemd` unit to
call `mbsync` followed by `notmuch new` every two minutes).
Once the cache is built, hitting `<tab>` in "editor" mode should launch the `fzf`
terminal.

Please feel free to open issues if you run into issues. I'll try and help if I can!
