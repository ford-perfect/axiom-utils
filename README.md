# Axiom Utils

Axiom Utils is a Nix flake utility designed to assist with downloading and storing machine learning weights in the Nix store. It provides a convenient way to manage model files, making it easy to utilize them temporarily or persistently.

The `axiom-utils.lib.fetchUrlAndLink` function works similarly to `fetchurl` but returns a set that can be used for the shellHook of e.g. a development shell. Users can choose between a `persistentLink` or a `temporaryLink`, which gets unlinked on shell exit. Currently only tested with bash.

By leveraging the Nix store garbage collection, Axiom Utils prevents overcrowding of disk space with unused models, making it ideal for creatives who use the latest AI advancements in multiple fields.
Usage

    In the flake where you want to use this utility, add axiom-utils as an input using the path attribute:

``` nix

inputs.axiom-utils.url = "path:/path/to/your/axiom-utils";
```
    Use the fetchUrlAndLink function in the shellHook of your flake:

``` nix
{
  # ... other parts of your flake ...

  devShell = pkgs.mkShell {
    buildInputs = [ /* ... */ ];
    shellHook = ''
      ${axiom-utils.lib.fetchUrlAndLink {
        url = "https://example.com/some-model-weights.pth";
        filename = "./some-model-weights.pth";
      }.temporaryLink}
    '';
  };
}
```
Upcoming Features

Axiom Utils aims to become an essential tool for creatives who use the latest AI advancements in multiple fields. We plan to introduce the following features:

1. AI Framework Integration: Seamless integration with popular AI frameworks such as TensorFlow, PyTorch, and OpenAI's API for efficient model management and deployment.
2. Declarative Model Configuration: Define and configure models using a declarative syntax, making it easier to manage and reproduce experiments.
3. Model Versioning: Support for versioning of machine learning models, allowing users to roll back or switch between different versions with ease.
4. Pipeline Automation: Automate the entire AI development process from data preprocessing, model training, to deployment using Nix-based pipelines.
5. Collaboration Tools: Enhancements to improve collaboration between team members, including sharing of models, configurations, and results.

Axiom Utils aims to empower creatives by simplifying the process of building, managing, and deploying AI models in a declarative OS environment.
