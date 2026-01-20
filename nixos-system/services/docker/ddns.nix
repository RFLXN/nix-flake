{
  ddns = {
    image = "oznu/cloudflare-ddns";

    environment = {
      ZONE = "rflxn-with-doujin-music.work";
      SUBDOMAIN = "home";
      PROXIED = "false";
    };

    environmentFiles = [
      "/persist/secrets/ddns.env"
    ];

    extraOptions = [
      "--network=host"
    ];
  };
}
