{
  user = {
    name = "romank";
  };

  hosts = let
    hostList = [
      {
        hostname = "huawei";
      }
      {
        hostname = "xiaomi";
      }
    ];

    hostDefaults = {
      system = "x86_64-linux";
      version = "26.05";
    };
  in
    map (host: hostDefaults // host) hostList;
}
