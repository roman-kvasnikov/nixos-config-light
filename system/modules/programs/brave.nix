{
  lib,
  pkgs,
  ...
}: {
  programs.chromium = {
    enable = true;

    package = pkgs.brave;

    extensions = [
      {id = "bnjjngeaknajbdcgpfkgnonkmififhfo";} # Fake Filler
      {id = "lfncinhjhjgebfnnblppmbmkgjgifhdf";} # IP Address & Geolocation
      {id = "pnidmkljnhbjfffciajlcpeldoljnidn";} # Linkwarden
      {id = "naepdomgkenhinolocfifgehidddafch";} # Browserpass
      {id = "nkbihfbeogaeaoehlefnkodbefgpgknn";} # MetaMask
      {id = "egjidjbpglichdcondbcbdnbeeppgdph";} # Trust Wallet
    ];
  };
}
