{
  description = "A flake utility to generate a function for linking and optionally unlinking files on shell exit.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";

  outputs = { self, nixpkgs }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    lib = {
      fetchUrlAndLink = { url, filename }:
        let
          fetchedFile = pkgs.fetchurl ( builtins.removeAttrs args [ "filename" ] );
          _filename = if filename!=null then filename else builtins.baseNameOf fetchedFile;
        in {
          shellHook =
            let
              persistentLink = ''
                # Create a symlink to the fetched file
                ln -sf '${fetchedFile}' '${filename}'
              '';
            in
            {
              inherit persistentLink;
              temporaryLink = persistentLink + ''
                  unlink_file() {
                    rm -f '${filename}'
                  }
                  trap unlink_file EXIT
              '';
            };
        };
    };
  };
}
