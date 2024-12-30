{ ... }:
{
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.ssh = {
    startAgent = false;
    knownHosts = {
      "elysium" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOWd8Xzy1H1PwwCYzAypTsnAnybhEXwX0RtWWI8LqcxL";
      };
    };
  };
}
