{ username, ... }: {
  home-manager.users.${username} = {
    programs.plasma = {
      input.mice = [
        {
          name = "Razer DeathAdder V4 Pro";
          productId = "00bf";
          vendorId = "1532";
          enable = true;
          accelerationProfile = "none";
          acceleration = -0.3;
          leftHanded = false;
          middleButtonEmulation = false;
          naturalScroll = false;
          scrollSpeed = 1;
        }
      ];
    };
  };
}