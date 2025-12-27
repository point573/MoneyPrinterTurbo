# load_env.py
import os
import toml

def load_env_to_config():
    """Load environment variables from Railway and update config.toml"""
    config_path = "/MoneyPrinterTurbo/config.toml"
    
    # Load existing config
    with open(config_path, 'r', encoding='utf-8') as f:
        config = toml.load(f)
    
    # Map environment variables to config keys
    if os.getenv('PEXELS_API_KEY'):
        pexels_keys = os.getenv('PEXELS_API_KEY').split(',')
        config['app']['pexels_api_keys'] = [k.strip() for k in pexels_keys]
    
    if os.getenv('PIXABAY_API_KEY'):
        pixabay_keys = os.getenv('PIXABAY_API_KEY').split(',')
        config['app']['pixabay_api_keys'] = [k.strip() for k in pixabay_keys]
    
    if os.getenv('OPENAI_API_KEY'):
        config['app']['openai_api_key'] = os.getenv('OPENAI_API_KEY')
    
    if os.getenv('LLM_PROVIDER'):
        config['app']['llm_provider'] = os.getenv('LLM_PROVIDER')
    
    # Azure TTS (opcional)
    if os.getenv('AZURE_SPEECH_KEY'):
        config['azure']['speech_key'] = os.getenv('AZURE_SPEECH_KEY')
    
    if os.getenv('AZURE_SPEECH_REGION'):
        config['azure']['speech_region'] = os.getenv('AZURE_SPEECH_REGION')
    
    # Write updated config
    with open(config_path, 'w', encoding='utf-8') as f:
        toml.dump(config, f)
    
    print("✅ Environment variables loaded into config.toml")

if __name__ == "__main__":
    load_env_to_config()
