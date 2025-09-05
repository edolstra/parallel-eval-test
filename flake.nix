{
  outputs =
    { self, ... }@inputs:
    with builtins;
    let
      range = first: last: if first > last then [ ] else genList (n: first + n) (last - first + 1);
    in
    {
      parallelMachines8 =
        builtins.listToAttrs
          (map
            (n: {
              name = "n${toString n}";
              value = (getFlake "github:NixOS/hydra/8481acda2fa07b353ef716e4933c5f213cdd6f45").nixosConfigurations.container.config.system.build.toplevel.drvPath;
            })
            (range 0 7));
    };
}
