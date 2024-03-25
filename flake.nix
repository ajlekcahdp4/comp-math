{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    systemDependent = flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
      };

      pythonEnv =
        pkgs.python3.withPackages
        (pyPkgs:
          with pyPkgs; [
            jupyter
            ipywidgets
            ipython
            ipympl
            numpy
            scipy
            pandas
            matplotlib
            black
            autopep8
            numba
            av
            sympy
          ]);

      envPackages = with pkgs; [
        pythonEnv
        bashInteractive
        coreutils
        nodePackages.pyright
        ffmpeg
      ];

      jupyterRunScript = pkgs.writeShellScriptBin "jupyter-run" ''
        ${pythonEnv}/bin/jupyter lab --no-browser --ip 0.0.0.0
      '';
    in {
      packages = {
        inherit jupyterRunScript;
      };

      apps.default = {
        type = "app";
        program = "${jupyterRunScript}/bin/jupyter-run";
      };

      devShells.default = pkgs.mkShell {
        packages = envPackages;
      };
    });
  in
    systemDependent;
}


