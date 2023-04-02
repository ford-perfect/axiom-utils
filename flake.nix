{
  description = "A flake utility to generate a function for linking and optionally unlinking files on shell exit.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";

  outputs = { self, nixpkgs }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    lib = {
      fetchUrlAndLink = { url, filename }:
        let
          fetchedFile = pkgs.fetchurl { inherit url; };
        in
          {shouldUnlink? true}:
            ''
              # Create a symlink to the fetched file
              ln -sf '${fetchedFile}' '${filename}'

              # Create a function to unlink the file on shell exit, if required
              ${if shouldUnlink then
                ''
                  unlink_file() {
                    rm -f '${filename}'
                  }
                  trap unlink_file EXIT
                ''
                else
                  ""
              }
            '';
      persistentLink = {shouldUnlink = false;};
    };
  };
}

