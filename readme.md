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
### Using the AUR
Run
```bash
yay inject-git
```
or an equivalent (such as yaourt) to install [inject-git](https://aur.archlinux.org/packages/inject-git/) from the arch user repository.
### Compile & Install manually
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
inject [--shell /usr/bin/sh] [--delimiter [!]] [--text] [--block] command to be run here
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

The block toggle specifies how inject handles multiline content. By default, inject
runs on a per-line basis. This is convenient for running a single command multiple
times with different arguments, for example. Specifying --block forces inject
to treat the multiline text as a block, not splitting it at all.

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

This command will find-replace-print on the command string, but using a
different delimiter.

```bash
echo "Susan" | inject -td <NAME> "Hi, <NAME>. I've always liked that name - <NAME>."
```

For the next two examples, I'll refer to the following files:
#### *`haiku.txt`*
```text
I spent quite some time
Thinking of funny haikus
None of them panned out
```

#### *`keywords.txt`*
```text
apple
orange
peach
```

This command uses block mode to treat a whole haiku as one text object.

```bash
cat haiku.txt | inject -b printf 'This is a beautiful haiku: "[!]"'
```

This command uses per-line execution (default behaviour), and a custom
delimiter.

```bash
cat keywords.txt | inject -d @ "grep @ data.txt"
```

That's all the examples I've written thus far! I know these are pretty
silly use cases, but I hope you can all find some more practical applications.
I know that this little tool has already helped me out a couple times.
