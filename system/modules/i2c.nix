{user, ...}: {
  boot = {
    kernelModules = ["i2c-dev"];
  };

  users = {
    groups.i2c = {};

    users.${user.name}.extraGroups = ["i2c"];
  };
}
