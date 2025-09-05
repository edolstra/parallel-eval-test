{
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505.tar.gz";

  outputs =
    { self, nixpkgs, ... }@inputs:
    with builtins;
    let
      range = first: last: if first > last then [ ] else genList (n: first + n) (last - first + 1);
      sum = builtins.foldl' (x: y: x + y) 0;
      parallelSum = xs: builtins.parallel xs (sum xs);
    in
    {
      # Run with: `nix eval --json .#parallelMachines8`.
      parallelMachines8 =
        builtins.listToAttrs
          (map
            (n: {
              name = "n${toString n}";
              value = (getFlake "github:NixOS/hydra/8481acda2fa07b353ef716e4933c5f213cdd6f45").nixosConfigurations.container.config.system.build.toplevel.drvPath;
            })
            (range 0 7));

      # Run with: `nix eval .#ifd --extra-experimental-features parallel-eval --impure`.
      ifd =
        with nixpkgs.legacyPackages.x86_64-linux;

        let
          makeIfd = n: import (runCommand "ifd${toString n}"
            {}
            ''
              # force rebuild every time: ${toString builtins.currentTime or 0}
              echo "ifd ${toString n}: sleeping"
              sleep 10
              echo ${toString n} > $out
            '');

          ifds = map makeIfd (range 1 5);
        in parallelSum ifds;
    };
}
