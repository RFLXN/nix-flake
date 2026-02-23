{
  logFile ? null,
  lockFile ? null,
  powerSupplyDir ? null,
  batteryDeviceName ? null
}:
{ lib, battery-logger, ... }:
{
  imports = [ battery-logger.nixosModules.default ];

  config = lib.mkMerge [
    {
      services.batteryLogger.enable = true;
    }
    (lib.mkIf (logFile != null) {
      services.batteryLogger.logFile = logFile;
    })
    (lib.mkIf (lockFile != null) {
      services.batteryLogger.lockFile = lockFile;
    })
    (lib.mkIf (powerSupplyDir != null) {
      services.batteryLogger.powerSupplyDir = powerSupplyDir;
    })
    (lib.mkIf (batteryDeviceName != null) {
      services.batteryLogger.batteryDeviceName = batteryDeviceName;
    })
  ];
}
