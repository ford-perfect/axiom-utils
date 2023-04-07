{
  description = "A flake utility to generate a function for linking and optionally unlinking files on shell exit.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";

  outputs = { self, nixpkgs }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    lib = {
      fetchUrlAndLink = { url, filename ? null, ... } @ args:
        let
          fetchedFile = pkgs.fetchurl ( builtins.removeAttrs args [ "filename" ] );
          # non greedy split
          splitResult = storeBaseName: builtins.split "([a-z0-9]+)-" storeBaseName;
          # get the last element of the list
          last = list: builtins.elemAt list (builtins.length list - 1);
          baseNameOfSingleFile = storePath: last (splitResult (builtins.baseNameOf storePath));
          _filename = if filename!=null then filename else baseNameOfSingleFile fetchedFile;

        in {
          misc.baseNameOfSingleFile = baseNameOfSingleFile;
          shellHook =
            let
              persistentLink = ''
                # Create a symlink to the fetched file
                ln -sf '${fetchedFile}' '${_filename}'
              '';
            in
            {
              inherit persistentLink;
              temporaryLink = persistentLink + ''
                  unlink_file() {
                    rm -f '${_filename}'
                  }
                  trap unlink_file EXIT
              '';
            };
        };
    };
    pythonPathHook = {
      selenium.chromium = pkgs: let
        pathsInfo = pkgs.writeTextFile {
          name = "selenium-chromium-paths-info";
          destination = "/paths_info.py";
          text = ''
          from selenium.webdriver.chrome.options import Options
          from selenium.webdriver.chrome.webdriver import WebDriver

          chromium_path = "${pkgs.chromium}/bin/chromium"
          chromedriver_path = "${pkgs.chromedriver}/bin/chromedriver"

          def create_webdriver():
              chrome_options = Options()
              chrome_options.binary_location = chromium_path
              chrome_options.add_argument("--disable-dev-shm-usage")
              chrome_options.add_argument("--no-sandbox")
              chrome_options.add_argument("--remote-debugging-port=9222")
              return WebDriver(executable_path=chromedriver_path, options=chrome_options)
        '';
        };
        in ''
            export PYTHONPATH="$PYTHONPATH:${pathsInfo}"
          '';
    };
    eyeCandy = {
      colorPrompt = projectName: ''
        export PS1="\[\033[01;35m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\[\033[01;33m\][${projectName}]\$\[\033[00m\] "
      '';
    };
  };
}
