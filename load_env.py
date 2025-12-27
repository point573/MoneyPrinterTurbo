#!/usr/bin/env python3
# load_env.py
import os
import toml

def load_env_to_config():
    """Load environment variables from Railway and update config.toml"""
    config_path = "/MoneyPrinterTurbo/config.toml"
    
    # Load existing config or create from example
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            config = toml.load(f)
    except FileNotFoundError:
        # Si no existe, copiar desde example
        import shutil
        shutil.copy('/MoneyPrinterTurbo/config.example.toml', config_path)
        with open(config_path, 'r', encoding='utf-8') as f:
            config = toml.load(f)
    
    # Asegurar que existen las secciones
    if 'app' not in config:
        config['app'] = {}
    if 'azure' not in config:
        config['azure'] = {}
    
    # Map environment variables to config keys
    if os.getenv('PEXELS_API_KEY'):
        pexels_keys = os.getenv('PEXELS_API_KEY').split(',')
        config['app']['pexels_api_keys'] = [k.strip() for k in pexels_keys if k.strip()]
        print(f"✅ Loaded {len(config['app']['pexels_api_keys'])} Pexels API key(s)")
    
    if os.getenv('PIXABAY_API_KEY'):
        pixabay_keys = os.getenv('PIXABAY_API_KEY').split(',')
        config['app']['pixabay_api_keys'] = [k.strip() for k in pixabay_keys if k.strip()]
        print(f"✅ Loaded {len(config['app']['pixabay_api_keys'])} Pixabay API key(s)")
    
    if os.getenv('OPENAI_API_KEY'):
        config['app']['openai_api_key'] = os.getenv('OPENAI_API_KEY')
        print("✅ Loaded OpenAI API key")
    
    if os.getenv('LLM_PROVIDER'):
        config['app']['llm_provider'] = os.getenv('LLM_PROVIDER')
        print(f"✅ Set LLM provider to: {os.getenv('LLM_PROVIDER')}")
    
    # Azure TTS (opcional)
    if os.getenv('AZURE_SPEECH_KEY'):
        config['azure']['speech_key'] = os.getenv('AZURE_SPEECH_KEY')
        print("✅ Loaded Azure Speech key")
    
    if os.getenv('AZURE_SPEECH_REGION'):
        config['azure']['speech_region'] = os.getenv('AZURE_SPEECH_REGION')
        print(f"✅ Set Azure Speech region to: {os.getenv('AZURE_SPEECH_REGION')}")
    
    # Write updated config
    with open(config_path, 'w', encoding='utf-8') as f:
        toml.dump(config, f)
    
    print("✅ Environment variables loaded into config.toml")

if __name__ == "__main__":
    load_env_to_config()
