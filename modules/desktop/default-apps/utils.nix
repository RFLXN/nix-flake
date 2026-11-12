rec {
  mkMimeDefaults = desktopId: mimeTypes:
    builtins.listToAttrs (map (mime: {
      name = mime;
      value = [ desktopId ];
    }) mimeTypes);

  # Home Manager xdg.mimeApps value that makes the given MIME map both the
  # default and an added association.
  mkMimeApps = mimeDefaults: {
    enable = true;
    defaultApplications = mimeDefaults;
    associations.added = mimeDefaults;
  };
}
