# =========================================
# ORACLE DATABASE CONNECTION UTILITY
# Census Database Management System
# Created: 2025-07-23 10:30:11
# =========================================

import oracledb
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.pool import QueuePool
from typing import Generator, Optional, Dict, Any, List
from contextlib import contextmanager
import logging
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from config.oracle_config import settings, ORACLE_CONFIG

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# SQLAlchemy Base
Base = declarative_base()

class OracleConnectionManager:
    """Oracle Database Connection Manager"""

    def __init__(self):
        self.engine = None
        self.SessionLocal = None
        self._initialize_engine()

    def _initialize_engine(self):
        """Initialize SQLAlchemy engine with Oracle database"""
        try:
            # Create SQLAlchemy engine with connection pooling
            self.engine = create_engine(
                settings.oracle_url,
                poolclass=QueuePool,
                pool_size=settings.ORACLE_POOL_SIZE,
                max_overflow=settings.ORACLE_MAX_OVERFLOW,
                pool_timeout=settings.ORACLE_POOL_TIMEOUT,
                pool_recycle=settings.ORACLE_POOL_RECYCLE,
                echo=settings.DEBUG,  # Log SQL queries in debug mode
                future=True
            )

            # Create session factory
            self.SessionLocal = sessionmaker(
                autocommit=False,
                autoflush=False,
                bind=self.engine
            )

            logger.info("Oracle database engine initialized successfully")

        except Exception as e:
            logger.error(f"Failed to initialize Oracle database engine: {e}")
            raise

    def get_session(self):
        """Get SQLAlchemy database session"""
        if not self.SessionLocal:
            raise Exception("Database engine not initialized")
        return self.SessionLocal()

    @contextmanager
    def get_session_context(self):
        """Context manager for database sessions"""
        session = self.get_session()
        try:
            yield session
            session.commit()
        except Exception as e:
            session.rollback()
            logger.error(f"Database session error: {e}")
            raise
        finally:
            session.close()

    def test_connection(self) -> bool:
        """Test database connection"""
        try:
            with self.engine.connect() as connection:
                result = connection.execute(text("SELECT 'Connection Test' FROM DUAL"))
                test_result = result.fetchone()
                logger.info(f"Database connection test successful: {test_result[0]}")
                return True
        except Exception as e:
            logger.error(f"Database connection test failed: {e}")
            return False

    def execute_raw_sql(self, sql: str, params: Optional[Dict] = None) -> List[Dict]:
        """Execute raw SQL query and return results"""
        try:
            with self.engine.connect() as connection:
                result = connection.execute(text(sql), params or {})
                if result.returns_rows:
                    columns = result.keys()
                    rows = result.fetchall()
                    return [dict(zip(columns, row)) for row in rows]
                else:
                    return [{"affected_rows": result.rowcount}]
        except Exception as e:
            logger.error(f"Error executing raw SQL: {e}")
            raise

    def call_procedure(self, procedure_name: str, params: Optional[Dict] = None) -> Any:
        """Call Oracle stored procedure"""
        try:
            with self.get_session_context() as session:
                # Prepare procedure call
                param_list = []
                if params:
                    for key, value in params.items():
                        param_list.append(f":{key}")

                sql = f"CALL {procedure_name}({', '.join(param_list)})"
                result = session.execute(text(sql), params or {})
                return result.fetchall() if result.returns_rows else None

        except Exception as e:
            logger.error(f"Error calling procedure {procedure_name}: {e}")
            raise

    def close(self):
        """Close database engine"""
        if self.engine:
            self.engine.dispose()
            logger.info("Database engine closed")

# Global connection manager instance
connection_manager = OracleConnectionManager()

# Dependency for FastAPI
def get_database_session() -> Generator:
    """Dependency to get database session for FastAPI routes"""
    session = connection_manager.get_session()
    try:
        yield session
    finally:
        session.close()

# Direct Oracle connection utility (for raw oracledb operations)
class DirectOracleConnection:
    """Direct Oracle connection using oracledb"""

    @staticmethod
    @contextmanager
    def get_connection():
        """Context manager for direct Oracle connections"""
        connection = None
        try:
            connection = oracledb.connect(**ORACLE_CONFIG)
            yield connection
        except Exception as e:
            if connection:
                connection.rollback()
            logger.error(f"Direct Oracle connection error: {e}")
            raise
        finally:
            if connection:
                connection.close()

    @staticmethod
    def execute_procedure_with_cursor(procedure_name: str, params: Optional[Dict] = None):
        """Execute procedure that returns cursor"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()
            try:
                # Create output cursor for procedures that return cursors
                output_cursor = connection.cursor()

                # Prepare parameters including output cursor
                call_params = list(params.values()) if params else []
                call_params.append(output_cursor)

                # Execute procedure
                cursor.callproc(procedure_name, call_params)

                # Fetch results from output cursor
                results = []
                for row in output_cursor:
                    results.append(row)

                output_cursor.close()
                return results

            except Exception as e:
                logger.error(f"Error executing procedure with cursor: {e}")
                raise
            finally:
                cursor.close()

# Utility functions
def create_tables():
    """Create all tables defined in models"""
    try:
        Base.metadata.create_all(bind=connection_manager.engine)
        logger.info("Database tables created successfully")
    except Exception as e:
        logger.error(f"Error creating tables: {e}")
        raise

def drop_tables():
    """Drop all tables"""
    try:
        Base.metadata.drop_all(bind=connection_manager.engine)
        logger.info("Database tables dropped successfully")
    except Exception as e:
        logger.error(f"Error dropping tables: {e}")
        raise

def init_database():
    """Initialize database with tables and sample data"""
    logger.info("Initializing Census database...")

    # Test connection first
    if not connection_manager.test_connection():
        raise Exception("Cannot connect to Oracle database")

    # Note: Tables are created via SQL scripts, not SQLAlchemy
    logger.info("Database initialized successfully")
    logger.info("Please run the SQL scripts to create tables and sample data:")
    logger.info("1. sql/schemas/oracle_schema.sql")
    logger.info("2. sql/procedures/oracle_procedures.sql") 
    logger.info("3. sql/triggers/oracle_triggers.sql")
    logger.info("4. sql/sample_data/oracle_sample_data.sql")

if __name__ == "__main__":
    # Test the connection
    logger.info("Testing Oracle database connection...")

    try:
        init_database()

        # Test raw SQL execution
        result = connection_manager.execute_raw_sql("SELECT SYSDATE FROM DUAL")
        logger.info(f"Current database time: {result}")

        # Test direct connection
        with DirectOracleConnection.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT USER FROM DUAL")
            user = cursor.fetchone()[0]
            logger.info(f"Connected as user: {user}")
            cursor.close()

        logger.info("All database tests passed!")

    except Exception as e:
        logger.error(f"Database test failed: {e}")
    finally:
        connection_manager.close()
