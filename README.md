# Visual Command Center

Your agents should not live only in a terminal.

Visual Command Center turns agent output into a small Mac window you can keep on screen.

It starts simple.

One standalone Mac app.

One optional browser board.

One shared feed at `~/.gjc/visual-feed/messages.jsonl`.

## Why it exists

Reading terminal text all day is tiring.

A builder needs a cockpit.

This is the start of that cockpit.
## See the design

Open `design.html` for the visual map.

## Try it

Build and install the standalone app.

```sh
bin/install-app
```

Open it from your Applications folder.

```sh
open "$HOME/Applications/Visual Command Center.app"
```

Send a message into it.

```sh
echo "Ship one thing today." | gjc-display show
```

The app reads the same feed and shows the latest agent message.

The browser board is optional.
With Stage Manager, macOS may place it in the left strip. Click the Visual Command Center card there.

## Direction

This should become a real command center for agent answers, memory, tasks, launches, and marketing work.

UAC is the memory.

Visual Command Center is the cockpit.
