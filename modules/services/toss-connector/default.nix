# toss-connector: PC-side daemon and CLI for the touch-oriented-stream-shell
# (TOSS) deck.
#
# The connector dials out to the deck (TCP 7879) and serves its web console on
# 127.0.0.1 only, so no firewall ports are needed. Keys, pairings, and console
# tokens live in ~/.config/toss-connector, which stays under the persisted
# /home, so no extra impermanence entries are needed either.
{
  autostart ? true,
  enableConsole ? true,
  path ? [ ],
  settings ? null,
}:
{ toss-connector, ... }:
{
  imports = [ toss-connector.nixosModules.toss-connector ];

  programs.toss-connector = {
    enable = true;
    inherit autostart path;
    console.enable = enableConsole;
    # null leaves permissions and commands to the user (CLI or web console).
    config = settings;
  };
}
