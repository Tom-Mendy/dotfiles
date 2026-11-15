{
  flake.nixosModules.local-ai = { unstable, ... }: {
    services.ollama = {
      enable = true;
      package = unstable.ollama-cuda;
      loadModels = [ "SparkLLM/Spark-X2.6-4B:q4_k_m" ];

      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = "32768";
        OLLAMA_FLASH_ATTENTION = "1";
      };
    };
  };
}
