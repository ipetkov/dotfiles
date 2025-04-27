{ ... }:
{
  programs.ssh = {
    knownHosts = {
      "elysium" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOWd8Xzy1H1PwwCYzAypTsnAnybhEXwX0RtWWI8LqcxL";
      };
    };
  };
}
