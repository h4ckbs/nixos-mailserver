#  nixos-mailserver: a simple mail server
#  Copyright (C) 2016-2018  Robin Raymond
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>

{ config, pkgs, lib, options, ... }:

let
  cfg = config.mailserver;
  clamHasSettings = options.services.clamav.daemon ? settings;
in
with lib;
{
  config = lib.mkIf (cfg.enable && cfg.virusScanning) {

    # Remove extraConfig and settings conditional after 20.09 support is removed

    services.clamav.daemon = {
      enable = true;
    } // (if clamHasSettings then {
      settings.PhishingScanURLs = "no";
    } else {
      extraConfig = ''
        PhishingScanURLs no
      '';
    });

    services.clamav.updater.enable = true;
  };
}

