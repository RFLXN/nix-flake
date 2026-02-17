{  }:
{ pkgs, username, ... }:
{
  home-manager.users.${username} = {
    wayland.windowManager.hyprland.settings = {
      exec-once = [ "waybar" ];
      layerrule = [
        "blur, waybar"
        "ignorezero, waybar"
        "ignorealpha 0.5, waybar"
      ];
    };
    programs.waybar = {
      enable = true;
      systemd.enable = false;
      settings.mainBar = {
        layer = "top";
        position = "top";
        reload_style_on_change = true;
        modules-left = [ "custom/notification" "clock" "tray" ];
        modules-center = [];
        modules-right = [ "group/expand" "bluetooth" "network" ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "";
            default = "";
            empty = "";
          };
          persistent-workspaces."*" = [ 1 2 3 4 5 ];
        };

        "custom/notification" = {
          tooltip = false;
          format = "";
          on-click = "swaync-client -t -sw";
          escape = true;
        };

        clock = {
          format = "{:%Y-%m-%d %I:%M:%S %p}";
          interval = 1;
          tooltip-format = "<tt>{calendar}</tt>";
          calendar.format.today = "<span color='#fAfBfC'><b>{}</b></span>";
          actions = {
            on-click-right = "shift_down";
            on-click = "shift_up";
          };
        };

        network = {
          format-wifi = "";
          format-ethernet = "󰈀";
          format-disconnected = "";
          format-alt = "󰈀 {ifname} {ipaddr}";
          tooltip = false;
          on-click-right = "nm-connection-editor";
        };

        bluetooth = {
          format-on = "󰂯";
          format-off = "BT-off";
          format-disabled = "󰂲";
          format-connected-battery = "{device_battery_percentage}% 󰂯";
          format-alt = "{num_connections} connected 󰂯";
          tooltip = false;
          on-click-right = "blueman-manager";
        };

        "custom/expand" = {
          format = "";
          tooltip = false;
        };

        "custom/endpoint" = {
          format = "|";
          tooltip = false;
        };

        "group/expand" = {
          orientation = "horizontal";
          drawer = {
            transition-duration = 600;
            transition-to-left = true;
            click-to-reveal = true;
          };
          modules = [ "custom/expand" "cpu" "memory" "temperature" "custom/endpoint" ];
        };

        cpu = {
          format = "󰻠";
          tooltip = true;
        };

        memory = {
          format = "";
        };

        temperature = {
          critical-threshold = 80;
          format = "";
        };

        tray = {
          icon-size = 14;
          spacing = 10;
        };
      };

      style = ''
        * {
          font-size: 15px;
          font-family: "FiraCode Nerd Font";
        }
        window#waybar {
          all: unset;
        }
        .modules-left {
          padding: 7px;
          margin: 10px 0 5px 10px;
          border-radius: 10px;
          background: alpha(#141318, .6);
          box-shadow: 0px 0px 2px rgba(0, 0, 0, .6);
        }
        .modules-center {
          padding: 7px;
          margin: 10px 0 5px 0;
          border-radius: 10px;
          background: alpha(#141318, .6);
          box-shadow: 0px 0px 2px rgba(0, 0, 0, .6);
        }
        .modules-right {
          padding: 7px;
          margin: 10px 10px 5px 0;
          border-radius: 10px;
          background: alpha(#141318, .6);
          box-shadow: 0px 0px 2px rgba(0, 0, 0, .6);
        }
        tooltip {
          background: #141318;
          color: #cac4cf;
        }
        #clock:hover, #custom-notification:hover, #bluetooth:hover, #network:hover, #cpu:hover, #memory:hover, #temperature:hover {
          transition: all .3s ease;
          color: #ccbeff;
        }
        #custom-notification {
          padding: 0px 5px;
          transition: all .3s ease;
          color: #cac4cf;
        }
        #clock {
          padding: 0px 5px;
          color: #cac4cf;
          transition: all .3s ease;
        }
        #workspaces {
          padding: 0px 5px;
        }
        #workspaces button {
          all: unset;
          padding: 0px 5px;
          color: alpha(#ccbeff, .4);
          transition: all .2s ease;
        }
        #workspaces button:hover {
          color: rgba(0,0,0,0);
          border: none;
          text-shadow: 0px 0px 1.5px rgba(0, 0, 0, .5);
          transition: all 1s ease;
        }
        #workspaces button.active {
          color: #ccbeff;
          border: none;
          text-shadow: 0px 0px 2px rgba(0, 0, 0, .5);
        }
        #workspaces button.empty {
          color: rgba(0,0,0,0);
          border: none;
          text-shadow: 0px 0px 1.5px rgba(0, 0, 0, .2);
        }
        #workspaces button.empty:hover {
          color: rgba(0,0,0,0);
          border: none;
          text-shadow: 0px 0px 1.5px rgba(0, 0, 0, .5);
          transition: all 1s ease;
        }
        #workspaces button.empty.active {
          color: #ccbeff;
          border: none;
          text-shadow: 0px 0px 2px rgba(0, 0, 0, .5);
        }
        #bluetooth {
          padding: 0px 5px;
          transition: all .3s ease;
          color: #cac4cf;
        }
        #network {
          padding: 0px 5px;
          transition: all .3s ease;
          color: #cac4cf;
        }
        #group-expand {
          padding: 0px 5px;
          transition: all .3s ease;
        }
        #custom-expand {
          padding: 0px 5px;
          color: alpha(#e6e1e9, .2);
          text-shadow: 0px 0px 2px rgba(0, 0, 0, .7);
          transition: all .3s ease;
        }
        #custom-expand:hover {
          color: rgba(255,255,255,.2);
          text-shadow: 0px 0px 2px rgba(255, 255, 255, .5);
        }
        #cpu, #memory, #temperature {
          padding: 0px 5px;
          transition: all .3s ease;
          color: #cac4cf;
        }
        #custom-endpoint {
          color: transparent;
          text-shadow: 0px 0px 1.5px rgba(0, 0, 0, 1);
        }
        #tray {
          padding: 0px 5px;
          transition: all .3s ease;
        }
        #tray menu * {
          padding: 0px 5px;
          transition: all .3s ease;
        }
        #tray menu separator {
          padding: 0px 5px;
          transition: all .3s ease;
        }
      '';
    };
  };
}
