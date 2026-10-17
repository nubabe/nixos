{

  den.aspects.keepassxc.homeManager = { config, ... }: {
    programs.keepassxc = {
      enable = true;
      settings = {
        Browser = {
          Enabled = true;
          UpdateBinaryPath = false;
        };
        GUI = {
          ApplicationTheme = "auto";
          ShowTrayIcon = true;
          TrayIconAppearance = "monochrome-light";
        };
        SSHAgent.Enabled = config.services.ssh-agent.enable;
      };
    };
    programs.librewolf.nativeMessagingHosts = [ config.programs.keepassxc.package ];
  };

}
