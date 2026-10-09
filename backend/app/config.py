from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    supabase_url: str = ''
    supabase_anon_key: str = ''
    supabase_jwt_audience: str = 'authenticated'
    allowed_origins: str = ''
    judge0_url: str = ''
    judge0_auth_token: str = ''
    judge0_python_id: int = 71
    # Operator must verify a patched isolated runner, filesystem isolation and egress policy.
    judge0_sandbox_verified: bool = False
    model_config = SettingsConfigDict(env_file='.env', extra='ignore')


settings = Settings()
