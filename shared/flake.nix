{
  description = "RFLXN's Shared Configuration Across All Systems";

  inputs = {
  };

  outputs = { ... }: {
    # Shared data (for specialArgs)
    data = {
      username = "rflxn";
      hostNames = {
        home-server = "rflxn-server";
        macbook = "rflxn-macbook";
        wsl = "rflxn-wsl";
      };
    };

    # Shared modules (for modules list)
    modules = {
      imports = [
        ./systems
        ./services
        ./programs
        ./packages
      ];
    };
  };
}
