{pkgs, ...}: {
  nix = {
    optimise = {
      automatic = true;
      dates = ["03:30"];
    };

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    settings = {
      auto-optimise-store = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}
