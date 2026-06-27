{
  flake.nixosModules.rog = {
    services.asusd.enable = true;
    systemd.services.asusd.wantedBy = [ "multi-user.target" ];

    system.activationScripts.asusdSlashConfig.text = ''
      mkdir -p /etc/asusd
      rm -f /etc/asusd/slash.ron
      install -m 0644 /dev/stdin /etc/asusd/slash.ron <<'EOF'
      (
          enabled: false,
          brightness: 255,
          display_interval: 0,
          display_mode: Bounce,
          show_on_boot: false,
          show_on_shutdown: false,
          show_on_sleep: false,
          show_on_battery: false,
          show_battery_warning: false,
          show_on_lid_closed: false,
      )
      EOF
    '';
  };
}
