{ ... }:
{
  environment.etc = {
    "machine-id".source = "/persist/etc/machine-id";
    "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections/";
  };

  users.users.root.hashedPasswordFile = "/persist/root/passwordfile";

  services.openssh.hostKeys = [
    {
      path = "/persist/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];
}
