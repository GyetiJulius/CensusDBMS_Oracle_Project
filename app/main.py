# =========================================
# MAIN FASTAPI APPLICATION
# Census Database Management System - Oracle Edition
# Created: 2025-07-23 10:33:41
# =========================================

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse
import uvicorn
import logging
from contextlib import asynccontextmanager

# Import configuration and routes
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config.oracle_config import settings
from app.routes.census_routes import router as census_router

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events"""
    # Startup
    logger.info("Starting Census Database Management System...")
    logger.info(f"Debug mode: {settings.DEBUG}")

    # Test database connection
    try:
        from app.database.oracle_connection import connection_manager
        if connection_manager.test_connection():
            logger.info("✅ Database connection successful")
        else:
            logger.error("❌ Database connection failed")
    except Exception as e:
        logger.error(f"❌ Database connection error: {e}")

    yield

    # Shutdown
    logger.info("Shutting down Census Database Management System...")
    try:
        from app.database.oracle_connection import connection_manager
        connection_manager.close()
        logger.info("✅ Database connections closed")
    except Exception as e:
        logger.error(f"Error closing database connections: {e}")

# Create FastAPI application
app = FastAPI(
    title="Census Database Management System",
    description="""
    A comprehensive Census Database Management System built with Oracle PL/SQL and Python FastAPI.

    ## Features

    * **Complete CRUD Operations** - Create, Read, Update, Delete for all census entities
    * **Oracle Stored Procedures** - Backend operations using PL/SQL procedures
    * **Trigger-based Logging** - Automatic activity tracking with database triggers
    * **Advanced Analytics** - Regional statistics, household demographics, housing conditions
    * **Search & Filtering** - Powerful search with pagination support
    * **Real-time Monitoring** - Activity logs and database statistics

    ## Main Entities

    * **Geographical Information** - Regions, districts, localities
    * **Households** - Household-level census data
    * **Individuals** - Personal demographic information
    * **Housing** - Housing conditions and amenities
    * **Economic Activity** - Employment and economic data
    * **Analytics** - Statistical reports and insights

    ## Database Features

    * Oracle PL/SQL stored procedures for all operations
    * Database triggers for automatic activity logging
    * JOIN queries for multi-table data retrieval
    * Cursor-based result sets for large data handling
    * Comprehensive data validation and constraints
    """,
    version=settings.APP_VERSION,
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify allowed origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(census_router, prefix="/api/v1", tags=["Census Management"])

# Root endpoint
@app.get("/", include_in_schema=False)
async def root():
    """Redirect to API documentation"""
    return RedirectResponse(url="/docs")

# Info endpoint
@app.get("/info", tags=["System"])
async def get_system_info():
    """Get system information"""
    return {
        "application": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "description": "Census Database Management System - Oracle Edition",
        "database": "Oracle Database with PL/SQL",
        "features": [
            "CRUD Operations with Stored Procedures",
            "Activity Logging with Triggers", 
            "Advanced Analytics with Cursors",
            "JOIN Queries for Multi-table Data",
            "Search & Filtering with Pagination",
            "Real-time Database Statistics"
        ],
        "endpoints": {
            "documentation": "/docs",
            "alternative_docs": "/redoc",
            "health_check": "/api/v1/health",
            "database_stats": "/api/v1/analytics/database-statistics"
        }
    }

# Custom exception handlers
@app.exception_handler(404)
async def not_found_handler(request, exc):
    return {
        "success": False,
        "message": "Endpoint not found",
        "detail": "The requested resource was not found"
    }

@app.exception_handler(500)
async def internal_error_handler(request, exc):
    logger.error(f"Internal server error: {exc}")
    return {
        "success": False,
        "message": "Internal server error",
        "detail": "An unexpected error occurred"
    }

def run_server():
    """Run the FastAPI server"""
    uvicorn.run(
        "app.main:app",
        host=settings.API_HOST,
        port=settings.API_PORT,
        reload=settings.API_RELOAD,
        log_level="info" if settings.DEBUG else "warning"
    )

if __name__ == "__main__":
    run_server()
