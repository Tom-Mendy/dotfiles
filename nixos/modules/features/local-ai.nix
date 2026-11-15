{
  flake.nixosModules.local-ai =
    {
      ...
    }:
    {
      services.ollama = {
        enable = true;
        loadModels = [
          "SparkLLM/Spark-X2.6-4B:q8_0"
        ];
      };

    };
}
