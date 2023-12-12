{ config, options, lib, diskoLib, ... }:
{
  options = {
    name = lib.mkOption {
      type = lib.types.str;
      default = lib.replaceStrings [ "/" ] [ "_" ] config._module.args.name;
      description = "Device name";
    };
    type = lib.mkOption {
      type = lib.types.enum [ "disk" ];
      default = "disk";
      internal = true;
      description = "Type";
    };
    device = lib.mkOption {
      type = diskoLib.optionTypes.absolute-pathname; # TODO check if subpath of /dev ? - No! eg: /.swapfile
      description = "Device path";
    };
    imageSizeExtraBytes = lib.mkOption {
      type = lib.types.int;
      description = ''
        extra size in bytes to add to the end of the disk image if the makeDiskImages function from diksoLib is used.
        This is used as an argument to truncate -s
      '';
      default = 2000000000;
    };
    content = diskoLib.deviceType { parent = config; device = config.device; };
    _meta = lib.mkOption {
      internal = true;
      readOnly = true;
      type = diskoLib.jsonType;
      default =
        lib.optionalAttrs (config.content != null) (config.content._meta [ "disk" config.device ]);
      description = "Metadata";
    };
    _create = diskoLib.mkCreateOption {
      inherit config options;
      default = config.content._create;
    };
    _mount = diskoLib.mkMountOption {
      inherit config options;
      default = lib.optionalAttrs (config.content != null) config.content._mount;
    };
    _config = lib.mkOption {
      internal = true;
      readOnly = true;
      default =
        lib.optional (config.content != null) config.content._config;
      description = "NixOS configuration";
    };
    _pkgs = lib.mkOption {
      internal = true;
      readOnly = true;
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
      default = pkgs: [ pkgs.jq ] ++ lib.optionals (config.content != null) (config.content._pkgs pkgs);
      description = "Packages";
    };
  };
}
