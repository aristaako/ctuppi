# Ctuppi

Script for setting up my personal dev environment.

## Setup info

* Konsole
* Git
* Curl
* Ripgrep
* Pip
* Python 3 & Pip3
* SQLite3
* Ruby
* Mailcatcher
* Gedit
* Atom
* Tree
* SDKMAN!
* Silver Searcher
* OpenSSH Server
* Solaar
* Tmux
* Nvm
* Node
* Java (current default jdk)
* Docker
* Maven
* Gradle
* AWS Command Line Interface
* Clojure
* Emacs
* Visual Studio Code
* Brave
* mpv

## Todo

* Install everything silently
* Improve emacs cheatsheet
* Install mpv for debian
* Ensure Clojure has compatible Java version (8 or 11)
* List failed installations after ctuppi

## Thanks

First of all, I would like to thank all those who have made my dev environment possible. I thank you all Tmux-plugin creating gurus and Flowa for the great emacs live pack.

## Cheatsheet

Because sometimes I forget some of the rarely used commands

### Tmux

#### Common

```
prefix = Ctrl-b
```

```
Reload tmux conf: prefix + r
```

```
Refresh tmux client: prefix + R
```

```
Split window horizontally: prefix + Shift-2
  Split window vertically: prefix + Shift-5
```

```
         Move cursor to pane above: Alt-↑
         Move cursor to pane below: Alt-↓
   Move cursor to pane on the left: Alt-←
  Move cursor to pane on the right: Alt-→
```

```
Open tmux window 10: prefix + F1
Open tmux window 11: prefix + F2
Open tmux window 12: prefix + F3
Open tmux window 13: prefix + F4
Open tmux window 14: prefix + F5
Open tmux window 15: prefix + F6
Open tmux window 16: prefix + F7
Open tmux window 17: prefix + F8
Open tmux window 18: prefix + F9
Open tmux window 19: prefix + F10
Open tmux window 20: prefix + F11
Open tmux window 21: prefix + F12
```

```
Close pane: prefix + x
```

#### Splitter
```
Split top left pane into 4 panes: prefix + j
```

#### TPM - Tmux plugin manager
```
  Install plugins: prefix + I
   Update plugins: prefix + u
Uninstall plugins: prefix + Alt-u (Uninstalls plugins not in the list of plugins in .tmux.conf)
```

#### Tmux resurrect
```
   Save session: prefix + Ctrl-s
Restore session: prefix + Ctrl-r
```

#### Tmux yank aka copy to clipboard

Normal mode
```
          Copy text from command line: prefix + y
Copy current pane's working directory: prefix + Y
```

Copy mode
```
                            Copy selection: y 
Copy selection and paste into command line: Y
```

#### Tmux sidebar
```
          Open sidebar: prefix + Tab
Open sidebar and focus: prefix + Backspace
```


#### Tmux open
Copy mode
```
                    Open selection with default program: o
                            Open selection with $EDITOR: Ctrl-o
Search selection from a search engine (default= Google): Shift-s
```

Change default search engine
```
Add line to .tmux.conf:
   set -g @open-S 'https://www.duckduckgo.com/'
```

### Emacs

```
  Split window vertically: Ctrl-x 2
Split window horizontally: Ctrl-x 3
```

```
Revert buffer: Ctrl-c x
```

```
Cancel command: Ctrl-g
```

```
Find and open file into current window: Ctrl-x Ctrl-f
```

```
Find and open file into another window: Ctrl-x 4 f
 Find and open file into another frame: Ctrl-x 5 f
```

```
 Search text forwards: Ctrl-s
Search text backwards: Ctrl-r
```

```
Kill whitespace: Alt-\ (Alt-AltGr-+)
```

```
     Undo: Ctrl-_ (Ctrl-Shift--)
Undo tree: Ctrl-x u
```

```
Close window: Ctrl-x 0
```

```
Arrange windows evenly: Ctrl-x +
```

## Author

Ari Rauhala - [aristaako](https://github.com/aristaako)