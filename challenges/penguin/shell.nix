with import <nixpkgs> {};
mkShell {
  buildInputs = [
    python310
    python310Packages.pwntools
    python310Packages.pysocks
    python310Packages.colored-traceback
    python310Packages.pyserial
    python310Packages.psutil
  ];
}
