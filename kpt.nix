{ pkgs, lib }:

pkgs.buildGoModule rec {
  pname = "kpt";
  version = "1.0.0-beta.48";

  src = pkgs.fetchFromGitHub {
    owner = "kptdev";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-GHEk5nezva+26cpCrgriaGIL2PvSLWgC0UtmFkNHoDc=";
  };

  vendorHash = "sha256-NQ/JqXokNmr8GlIhqTJb0JFyU2mAEXO+2y5vI79TuX4=";

  subPackages = [ "." ];

  ldflags = [ "-s" "-w" "-X github.com/GoogleContainerTools/kpt/run.version=${version}" ];

  meta = with lib; {
    description = "Kpt beta";
  };

}
