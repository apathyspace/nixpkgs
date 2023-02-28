{ lib, vscode-utils, jq, moreutils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "jupyter";
    publisher = "ms-toolsai";
    version = "2023.2.1000411022";
    sha256 = "sha256-gMK/t/rLXYN3rlHxxVeW0W/FWEP0ZCiEwzM8DY14vYg=";
  };

  nativeBuildInputs = [
    jq
    moreutils
  ];

  postPatch = ''
    # Patch 'packages.json' so that the expected '__metadata' field exists.
    # This works around observed extension load failure on vscode's attempt
    # to rewrite 'packages.json' with this new information.
    print_jq_query() {
        cat <<"EOF"
    .__metadata = {
      "id": "6c2f1801-1e7f-45b2-9b5c-7782f1e076e8",
      "publisherId": "ac8eb7c9-3e59-4b39-8040-f0484d8170ce",
      "publisherDisplayName": "Microsoft",
      "installedTimestamp": 0
    }
    EOF
    }
    jq "$(print_jq_query)" ./package.json | sponge ./package.json
    
    # Precreate './temp/jupyter/kernels/' in the extention root.
    # This works around observed extension load failure on 
    # 'getKernelSpecTempRegistrationFolder()'s attempt to create it 
    # inside nix store at runtime, while looking for jupyter kernels
    mkdir --parents ./temp/jupyter/kernels
  '';

  meta = with lib; {
    description = "Jupyter extension for vscode";
    homepage = "https://github.com/microsoft/vscode-jupyter";
    license = licenses.mit;
    maintainers = with maintainers; [ jraygauthier ];
  };
}
