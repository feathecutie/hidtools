{
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.buildDotnetModule rec {
          pname = "waratah";
          version = "1.6.0";
          src = ./.;
          projectFile = "Waratah/WaratahCmd/WaratahCmd.csproj";
          nugetDeps = ./deps.nix;
          dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
          dotnet-runtime = pkgs.dotnetCorePackages.runtime_8_0;
          executables = [ "WaratahCmd" ];
          prePatch = ''
            cp ${builtins.fetchurl {
              url = "https://www.usb.org/sites/default/files/hut1_5.pdf";
              sha256 = "sha256:1cvxq29ba0j0akcxlwsz1ba9mbpfshbdcphmk68zhd0in0bx5spl";
            }} Waratah/HidSpecification/hut1_5.pdf
          '';
          postFixup = ''
            ${pkgs.ripgrep}/bin/rg "/nix" "$out"
          '';
        };
        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.default;
          name = "WaratahCmd";
        };
      });
}
