let
   jupyterLib = builtins.fetchGit {
    url = https://github.com/tweag/jupyterWith;
    rev = "70f1dddd6446ab0155a5b0ff659153b397419a2d";
  };

  overlays = [
    # Only necessary for Haskell kernel
    (import ./overlay/python.nix)
  ];

  pkgs = import <nixpkgs> { inherit overlays; };

  jupyter = import jupyterLib {pkgs=pkgs;};

  iPython = jupyter.kernels.iPythonWith {
    python3 = pkgs.callPackage ./overlay/own-python.nix {};
    name = "agriculture";
    packages = p: with p; [ numpy pandas matplotlib editdistance ipywidgets ];
  };

  iHaskell = jupyter.kernels.iHaskellWith {
    name = "haskell";
    packages = p: with p; [ hvega formatting ] ;
  };


  jupyterEnvironment =
    jupyter.jupyterlabWith {
      kernels = [ iPython ];
       directory = jupyter.mkDirectoryWith {
         extensions = [
           "@jupyter-widgets/jupyterlab-manager@2.0"
           #"jupyterlab-ihaskell@0.0.7" https://github.com/gibiansky/IHaskell/pull/1151
        ];
       };

    };
in
  pkgs.mkShell rec {
  name = "analysis-arg";
  buildInputs = [ jupyterEnvironment
                  pkgs.python3Packages.ipywidgets
                  juliaEnv
                ];
  shellHook = ''
  jupyter nbextension enable --py widgetsnbextension
  jupyter
    '';
  }
