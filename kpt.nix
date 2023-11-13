{ pkgs, lib }:

pkgs.buildGoModule rec {
  pname = "kpt";
  version = "1.0.0-beta.47";

  src = pkgs.fetchFromGitHub {
    owner = "kptdev";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-h+Ozah76UfgzPhYks2yRWd5gZrjO0XZ8UX01UGm2cYI=";
  };

  vendorSha256 = "sha256-SCIalKqIeWA9rG15CcD6ogk6o+38/tLNMt7zpyYXDz4=";

  subPackages = [ "." ];

  ldflags = [ "-s" "-w" "-X github.com/GoogleContainerTools/kpt/run.version=${version}" ];

  meta = with lib; {
    description = "Kpt beta";
  };

}
