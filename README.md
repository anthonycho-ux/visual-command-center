# Visual Command Center

Your agents should not live only in a terminal.

Visual Command Center turns agent output into a small Mac window you can keep on screen.

It starts simple.

One browser board.

One Mac widget style window.

One shared feed at `~/.gjc/visual-feed/messages.jsonl`.

## Why it exists

Reading terminal text all day is tiring.

A builder needs a cockpit.

This is the start of that cockpit.

## Try it

Start the browser board.

```sh
gjc-display
```

Send a message into it.

```sh
echo "Ship one thing today." | gjc-display show
```

Start the Mac window.

```sh
bin/visual-command-center
```

The window reads the same feed and shows the latest agent message.

## Direction

This should become a real command center for agent answers, memory, tasks, launches, and marketing work.

UAC is the memory.

Visual Command Center is the cockpit.
