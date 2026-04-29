{pkgs, ...}: {
  home.packages = with pkgs; [
    (callPackage ./print {})
    (callPackage ./check-user {})
    (callPackage ./check-packages {})
    (callPackage ./ensure-config {})
  ];
}
