{
  flake.nixosModules.local-ai = { unstable, ... }: {
    services.ollama = {
      enable = true;
      package = unstable.ollama-cuda;
      loadModels = [ "SparkLLM/Spark-X2.6-4B:q4_k_m" ];

      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = "65536";
        OLLAMA_NUM_PARALLEL = "1";
        OLLAMA_MAX_LOADED_MODELS = "1";
      };

    };
  };
}
