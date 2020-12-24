# ipetkov's dotfiles

These are my personal dotfiles and NixOS/home-manager configurations for
setting everything up. I doubt anyone would even want to use this directly,
but feel free to use it for your own inspiration (or apply any workarounds for
issues I've hit...).

## Layout Structure

I've tried to organize things in a logical way, so for the time being,
things are structured as follows:

* `config`: contents which might represent the `~/.config` directory. Basically
"literal" configs and definitions which get linked/incorporated through home-manager
* `homeManagerModules`: a collection of "common" home-manager modules which could be used
in other dependent flakes. They're definitely tailored to my own preferences though, and lack
robust options (like how home-manager might lay things out)!
* `lib`: collection of helper functions for doing things like crawling
directories and automatically making flake outputs of things
* `nixosConfigurations`: top level system configurations, named by machine/host name
* `nixosModules`: same as `homeManagerModules` but related to system configuration modules
* `users`: common user definitions that can be reused across system configurations.
Normally this directory would have a `default.nix` module which defines user groups,
home directories, etc., and a `home.nix` module which contains the root of the
home-manager configurations for this user.
