final: super:

let
  inherit (final)
    kernelPatches
    linuxPackagesFor
  ;
in
rec {
  linux-firmware = final.callPackage ./pkgs/linux-firmware {
    linux-firmware = super.linux-firmware;
  };
  linuxPackages_jovian = linuxPackagesFor final.linux_jovian;
  linux_jovian = super.callPackage ./pkgs/linux-jovian {
    kernelPatches = [
      kernelPatches.bridge_stp_helper
      kernelPatches.request_key_helper
      kernelPatches.export-rt-sched-migrate
    ];
  };

  gamescope = final.callPackage ./pkgs/gamescope {
    gamescope' = super.gamescope;
  };

  mangohud = final.callPackage ./pkgs/mangohud {
    libXNVCtrl = linuxPackages_jovian.nvidia_x11.settings.libXNVCtrl;
    mangohud32 = final.pkgsi686Linux.mangohud;
    inherit (final.python3Packages) mako;
  };

  mesa-radv-jupiter = final.callPackage ./pkgs/mesa-radv-jupiter {
    # Compat with the inputs from Nixpkgs; those are for Darwin.
    OpenGL = null;
    Xplugin = null;
  };

  jupiter-fan-control = final.callPackage ./pkgs/jupiter-fan-control { };

  jupiter-hw-support = final.callPackage ./pkgs/jupiter-hw-support { };
  steamdeck-hw-theme = final.callPackage ./pkgs/jupiter-hw-support/theme.nix { };
  steamdeck-firmware = final.callPackage ./pkgs/jupiter-hw-support/firmware.nix { };
  steamdeck-bios-fwupd = final.callPackage ./pkgs/jupiter-hw-support/bios-fwupd.nix { };
  jupiter-dock-updater-bin = final.callPackage ./pkgs/jupiter-dock-updater-bin { };

  opensd = super.callPackage ./pkgs/opensd { };

  jovian-greeter = super.callPackage ./pkgs/jovian-greeter { };

  jovian-documentation = final.callPackage ./support/docs {
    pagefind = final.callPackage ./pkgs/pagefind { };
    documentationPath = final.callPackage (
      { runCommand
      }:
      runCommand "jovian-documentation-source" {
        src = ./docs;
      } ''
        (PS4=" $ "; set -x
        cp --no-preserve=mode -r $src src
        chmod -R +w src
        rm -vf src/README.md
        cp -v ${./CONTRIBUTING.md} src/contributing.md
        printf '# Home\n\n' | cat - ${./README.md} > src/index.md
        mv src $out
        )
      ''
    ) { };
  };

  steamPackages = super.steamPackages.overrideScope (scopeFinal: scopeSuper: {
    steam = final.callPackage ./pkgs/steam-jupiter/unwrapped.nix {
      steam-original = scopeSuper.steam;
    };
    steam-fhsenv = final.callPackage ./pkgs/steam-jupiter/fhsenv.nix {
      steam-fhsenv = scopeSuper.steam-fhsenv;
    };
    steam-fhsenv-small = final.callPackage ./pkgs/steam-jupiter/fhsenv.nix {
      steam-fhsenv = scopeSuper.steam-fhsenv-small;
    };
  });

  sdgyrodsu = final.callPackage ./pkgs/sdgyrodsu { };

  decky-loader = final.callPackage ./pkgs/decky-loader { };
}
