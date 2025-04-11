# Defold Bin
This is a flake for the precompiled Defold engine.

Just add it to your NixOS flake.nix or home-manager:

```nix
inputs = {
  defold.url = "github:spl3g/defold-flake";
  ...
}
```

Then to your packages add:
```nix
inputs.defold.packages."x86_64-linux".default
```
