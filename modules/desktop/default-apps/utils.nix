{
  mkMimeDefaults = desktopId: mimeTypes:
    builtins.listToAttrs (map (mime: {
      name = mime;
      value = [ desktopId ];
    }) mimeTypes);
}
