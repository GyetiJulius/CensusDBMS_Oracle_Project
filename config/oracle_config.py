# =========================================
# ORACLE DATABASE CONFIGURATION
# Census Database Management System
# Created: 2025-07-23 10:29:32
# =========================================

import os
from typing import Optional
from pydantic_settings import BaseSettings

class OracleSettings(BaseSettings):
    """Oracle Database Configuration Settings"""

    # Oracle Database Connection Parameters
    ORACLE_HOST: str = "localhost"
    ORACLE_PORT: int = 1521
    ORACLE_SID: str = "XE"  # Or your Oracle SID
    ORACLE_SERVICE_NAME: Optional[str] = None  # Alternative to SID
    ORACLE_USERNAME: str = "census_user"
    ORACLE_PASSWORD: str = "census_password"

    # Connection Pool Settings
    ORACLE_POOL_SIZE: int = 5
    ORACLE_MAX_OVERFLOW: int = 10
    ORACLE_POOL_TIMEOUT: int = 30
    ORACLE_POOL_RECYCLE: int = 3600

    # Application Settings
    APP_NAME: str = "Census DBMS"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True

    # API Settings
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8000
    API_RELOAD: bool = True

    # Security Settings
    SECRET_KEY: str = "your-secret-key-here-change-in-production"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    class Config:
        env_file = ".env"
        case_sensitive = True

    @property
    def oracle_url(self) -> str:
        """Generate Oracle database URL"""
        if self.ORACLE_SERVICE_NAME:
            return f"oracle+oracledb://{self.ORACLE_USERNAME}:{self.ORACLE_PASSWORD}@{self.ORACLE_HOST}:{self.ORACLE_PORT}/?service_name={self.ORACLE_SERVICE_NAME}"
        else:
            return f"oracle+oracledb://{self.ORACLE_USERNAME}:{self.ORACLE_PASSWORD}@{self.ORACLE_HOST}:{self.ORACLE_PORT}/{self.ORACLE_SID}"

    @property
    def oracle_dsn(self) -> str:
        """Generate Oracle DSN for direct connections"""
        if self.ORACLE_SERVICE_NAME:
            return f"{self.ORACLE_HOST}:{self.ORACLE_PORT}/{self.ORACLE_SERVICE_NAME}"
        else:
            return f"{self.ORACLE_HOST}:{self.ORACLE_PORT}/{self.ORACLE_SID}"

# Global settings instance
settings = OracleSettings()

# Database connection parameters for direct Oracle connections (oracledb format)
ORACLE_CONFIG = {
    'user': settings.ORACLE_USERNAME,
    'password': settings.ORACLE_PASSWORD,
    'dsn': settings.oracle_dsn
}

# Print configuration (for debugging - remove passwords in production)
def print_config():
    """Print current configuration (for debugging)"""
    print("Oracle Database Configuration:")
    print(f"  Host: {settings.ORACLE_HOST}")
    print(f"  Port: {settings.ORACLE_PORT}")
    print(f"  SID: {settings.ORACLE_SID}")
    print(f"  Service Name: {settings.ORACLE_SERVICE_NAME}")
    print(f"  Username: {settings.ORACLE_USERNAME}")
    print(f"  Database URL: {settings.oracle_url}")
    print(f"  App Name: {settings.APP_NAME}")
    print(f"  Debug Mode: {settings.DEBUG}")

if __name__ == "__main__":
    print_config()
