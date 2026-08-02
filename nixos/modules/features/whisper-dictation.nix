{ self, inputs, ... }:
{
  flake.nixosModules.whisperDictation =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.myWhisperDictation
      ];
    };

  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      whisperCpp =
        (import inputs.nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
            cudaCapabilities = [ "12.0" ];
          };
        }).whisper-cpp;
      whisperModel = pkgs.fetchurl {
        name = "ggml-large-v3-turbo.bin";
        url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin";
        hash = "sha256-H8cPd0046xaZk6w5Huo1fvR8iHV+9y7llDh5t+jivGk=";
      };
    in
    {
      packages.myWhisperDictation = pkgs.writeShellApplication {
        name = "my-whisper-dictation";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.gnused
          pkgs.libnotify
          pkgs.pipewire
          pkgs.util-linux
          pkgs.wtype
          whisperCpp
        ];
        text = ''
          state_dir="''${XDG_RUNTIME_DIR:?}/whisper-dictation"
          audio="$state_dir/recording.wav"
          output="$state_dir/transcript"
          pid_file="$state_dir/recorder.pid"

          notify() {
            notify-send --app-name Whisper "Whisper" "$1" || true
          }

          mkdir -p "$state_dir"
          exec 9>"$state_dir/lock"
          if ! flock -n 9; then
            notify "Transcription already in progress"
            exit 0
          fi

          if [[ -s "$pid_file" ]]; then
            pid=$(<"$pid_file")
            if [[ "$pid" =~ ^[0-9]+$ && -r "/proc/$pid/cmdline" ]]; then
              cmdline=$(tr '\0' ' ' < "/proc/$pid/cmdline")
            else
              cmdline=""
            fi

            if kill -0 "$pid" 2>/dev/null && [[ "$cmdline" == *"$audio"* ]]; then
              trap 'rm -f "$pid_file" "$audio" "$output.txt"' EXIT
              notify "Transcribing…"
              kill -INT "$pid"
              while kill -0 "$pid" 2>/dev/null; do
                sleep 0.05
              done

              if ! whisper-cli \
                --model ${whisperModel} \
                --file "$audio" \
                --language auto \
                --no-timestamps \
                --no-prints \
                --output-txt \
                --output-file "$output"; then
                notify "Transcription failed"
                exit 1
              fi

              transcript=$(tr '\n' ' ' < "$output.txt" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
              if [[ -z "$transcript" ]]; then
                notify "No speech detected"
              elif printf '%s' "$transcript" | wtype -; then
                notify "Text inserted"
              else
                notify "Could not type into the focused window"
                exit 1
              fi
              exit 0
            fi

            rm -f "$pid_file"
          fi

          rm -f "$audio" "$output.txt"
          pw-record --rate 16000 --channels 1 --format s16 "$audio" 9>&- &
          printf '%s\n' "$!" > "$pid_file"
          notify "Recording… press Mod+Space to stop"
        '';
      };
    };
}
