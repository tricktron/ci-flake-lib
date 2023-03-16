{
    description             = "ci-flake-lib";
    inputs.nixpkgs.url      = "github:NixOS/nixpkgs";
    
    outputs = { self, nixpkgs }:
    let
        supportedSystems =
        [
            "x86_64-darwin" 
            "aarch64-darwin"
            "x86_64-linux" 
            "aarch64-linux"
        ];

        forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
        pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {   
        overlays = import ./overlays.nix;
    };
}