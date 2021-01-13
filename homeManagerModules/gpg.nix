{
  programs.gpg.enable = true;
  home.file.".gnupg/gpg-agent.conf".text = ''
    default-cache-ttl 300
  '';
}
