# Inject
Inject is a little shell redirection utility that allows you to substitute piped
input anywhere into a string, then run it as a command or print it to the
console. Here's what I mean:

```bash
$ echo -n "hot dogs" | inject echo "[!], [!]! Get your [!]!"
```

will output:

```text
hot dogs, hot dogs! Get your hot dogs!
```

Sure, that's a silly example, but I've found it pretty handy. This is
functionality I need a lot, but usually it requires a large amount of command
substitution (which seems to be different in every shell), xargs magic, and
other unix tricks.

## Installation
It's pretty simple! Just install Crystal, clone the repo, and run sudo make
install.
```bash
sudo pacman -Syu crystal
git clone https://github.com/shinzlet/inject.git
cd inject
sudo make install
```

## Usage
Inject has a very simple syntax. The basic form is:

```bash
inject [--shell /usr/bin/sh] [--delimiter [!]] [--text] command to be run here
```

Let's break that down quickly. You can specify the shell that inject will run
your command in with the --shell (or -s) argument. By default, this is the
bourne shell (sh).

You can also specify what delimiter/marker you want to use in your injection
with --delimiter or -d. By
default, inject replaces all instances of [!] in your command with whatever you
piped into it.

If you don't want the command to be run at all, that's also fine! You can force
inject to simply print the edited output to STDOUT with the --text or -t flag.
This one doesn't take a parameter.

## Examples
This command will run in the fish shell.

```bash
echo "key" | inject --shell /usr/bin/fish "set -U [!] value"
```

This command will use the delimiter INSERT-HERE.

```bash
echo "now" | inject --delimiter INSERT-HERE "shutdown INSERT-HERE"
```

This command will simply perform a find-and-replace on the command string, then
print it.

```bash
echo "like" | inject --text "I [!] fish."
```

This final command will find-replace-print on the command string, but using a
different delimiter.

```bash
echo "Susan" | inject -td <NAME> "Hi, <NAME>. I've always liked that name - <NAME>."
```
