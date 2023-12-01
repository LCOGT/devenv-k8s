{ pkgs, lib }:

pkgs.buildGoModule rec {
  pname = "octopilot";
  version = "1.5.5";

  src = pkgs.fetchFromGitHub {
    owner = "dailymotion-oss";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-CtCB8iVJlcnb8cxBclqujhIg+AspUWII0EBtVD1ez64=";
  };

  vendorHash = null;

  subPackages = [ "." ];

  ldflags = [
    "-s" "-w"
    "-X main.buildVersion=${version}"
    "-X main.buildCommit=v${version}"
  ];

  meta = with lib; {
    description = "Automate your Gitops workflow, by automatically creating/merging GitHub Pull Requests ";
    homepage = "https://github.com/dailymotion-oss/octopilot";
  };

}
