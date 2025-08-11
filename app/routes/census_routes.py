# =========================================
# FASTAPI ROUTES
# Census Database Management System - Oracle Edition
# Created: 2025-07-23 10:33:15
# =========================================

from fastapi import APIRouter, HTTPException, Depends, Query
from typing import Optional, List
from app.models.pydantic_models import *
from app.utils.db_service import census_service
import logging

logger = logging.getLogger(__name__)

# Create API router
router = APIRouter()

# =========================================
# GEOGRAPHICAL INFORMATION ROUTES
# =========================================

@router.post("/geographical-info/", response_model=APIResponse)
async def create_geographical_info(geo_data: GeographicalInfoCreate):
    """Create new geographical information"""
    try:
        geo_id = census_service.create_geographical_info(geo_data)
        return APIResponse(
            success=True,
            message="Geographical information created successfully",
            data={"geo_id": geo_id}
        )
    except Exception as e:
        logger.error(f"Error creating geographical info: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/geographical-info/", response_model=APIResponse)
async def get_geographical_info(geo_id: Optional[int] = Query(None)):
    """Get geographical information"""
    try:
        data = census_service.get_geographical_info(geo_id)
        return APIResponse(
            success=True,
            message="Geographical information retrieved successfully",
            data={"geographical_info": data},
            count=len(data)
        )
    except Exception as e:
        logger.error(f"Error retrieving geographical info: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/geographical-info/{geo_id}", response_model=APIResponse)
async def update_geographical_info(geo_id: int, geo_data: GeographicalInfoUpdate):
    """Update geographical information"""
    try:
        success = census_service.update_geographical_info(geo_id, geo_data)
        if success:
            return APIResponse(
                success=True,
                message="Geographical information updated successfully"
            )
        else:
            raise HTTPException(status_code=404, detail="Geographical information not found")
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating geographical info: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/geographical-info/{geo_id}", response_model=APIResponse)
async def delete_geographical_info(geo_id: int):
    """Delete geographical information"""
    try:
        success = census_service.delete_geographical_info(geo_id)
        if success:
            return APIResponse(
                success=True,
                message="Geographical information deleted successfully"
            )
        else:
            raise HTTPException(status_code=404, detail="Geographical information not found")
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting geographical info: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# =========================================
# HOUSEHOLD ROUTES
# =========================================

@router.post("/households/", response_model=APIResponse)
async def create_household(household_data: HouseholdCreate):
    """Create new household"""
    try:
        household_id = census_service.create_household(household_data)
        return APIResponse(
            success=True,
            message="Household created successfully",
            data={"household_id": household_id}
        )
    except Exception as e:
        logger.error(f"Error creating household: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/households/", response_model=APIResponse)
async def get_households(
    household_id: Optional[int] = Query(None),
    geo_id: Optional[int] = Query(None)
):
    """Get households"""
    try:
        data = census_service.get_households(household_id, geo_id)
        return APIResponse(
            success=True,
            message="Households retrieved successfully",
            data={"households": data},
            count=len(data)
        )
    except Exception as e:
        logger.error(f"Error retrieving households: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/households/{household_id}", response_model=APIResponse)
async def update_household(household_id: int, household_data: HouseholdUpdate):
    """Update household"""
    try:
        success = census_service.update_household(household_id, household_data)
        if success:
            return APIResponse(
                success=True,
                message="Household updated successfully"
            )
        else:
            raise HTTPException(status_code=404, detail="Household not found")
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating household: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/households/{household_id}", response_model=APIResponse)
async def delete_household(household_id: int):
    """Delete household"""
    try:
        success = census_service.delete_household(household_id)
        if success:
            return APIResponse(
                success=True,
                message="Household deleted successfully"
            )
        else:
            raise HTTPException(status_code=404, detail="Household not found")
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting household: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# =========================================
# INDIVIDUAL ROUTES
# =========================================

@router.post("/individuals/", response_model=APIResponse)
async def create_individual(individual_data: IndividualCreate):
    """Create new individual"""
    try:
        individual_id = census_service.create_individual(individual_data)
        return APIResponse(
            success=True,
            message="Individual created successfully",
            data={"individual_id": individual_id}
        )
    except Exception as e:
        logger.error(f"Error creating individual: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/individuals/", response_model=APIResponse)
async def get_individuals(
    individual_id: Optional[int] = Query(None),
    household_id: Optional[int] = Query(None)
):
    """Get individuals"""
    try:
        data = census_service.get_individuals(individual_id, household_id)
        return APIResponse(
            success=True,
            message="Individuals retrieved successfully",
            data={"individuals": data},
            count=len(data)
        )
    except Exception as e:
        logger.error(f"Error retrieving individuals: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/individuals/{individual_id}", response_model=APIResponse)
async def update_individual(individual_id: int, individual_data: IndividualUpdate):
    """Update individual"""
    try:
        success = census_service.update_individual(individual_id, individual_data)
        if success:
            return APIResponse(
                success=True,
                message="Individual updated successfully"
            )
        else:
            raise HTTPException(status_code=404, detail="Individual not found")
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating individual: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/individuals/{individual_id}", response_model=APIResponse)
async def delete_individual(individual_id: int):
    """Delete individual"""
    try:
        success = census_service.delete_individual(individual_id)
        if success:
            return APIResponse(
                success=True,
                message="Individual deleted successfully"
            )
        else:
            raise HTTPException(status_code=404, detail="Individual not found")
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting individual: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# =========================================
# HOUSING ROUTES
# =========================================

@router.post("/housing/", response_model=APIResponse)
async def create_housing(housing_data: HousingCreate):
    """Create new housing information"""
    try:
        housing_id = census_service.create_housing(housing_data)
        return APIResponse(
            success=True,
            message="Housing information created successfully",
            data={"housing_id": housing_id}
        )
    except Exception as e:
        logger.error(f"Error creating housing: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/housing/{housing_id}", response_model=APIResponse)
async def update_housing(housing_id: int, housing_data: HousingUpdate):
    """Update housing information"""
    try:
        success = census_service.update_housing(housing_id, housing_data)
        if success:
            return APIResponse(
                success=True,
                message="Housing information updated successfully"
            )
        else:
            raise HTTPException(status_code=404, detail="Housing information not found")
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating housing: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/housing/{housing_id}", response_model=APIResponse)
async def delete_housing(housing_id: int):
    """Delete housing information"""
    try:
        success = census_service.delete_housing(housing_id)
        if success:
            return APIResponse(
                success=True,
                message="Housing information deleted successfully"
            )
        else:
            raise HTTPException(status_code=404, detail="Housing information not found")
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting housing: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# =========================================
# ECONOMIC ACTIVITY ROUTES
# =========================================

@router.post("/economic-activity/", response_model=APIResponse)
async def create_economic_activity(economic_data: EconomicActivityCreate):
    """Create new economic activity"""
    try:
        economic_id = census_service.create_economic_activity(economic_data)
        return APIResponse(
            success=True,
            message="Economic activity created successfully",
            data={"economic_id": economic_id}
        )
    except Exception as e:
        logger.error(f"Error creating economic activity: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# =========================================
# ANALYTICS & REPORTING ROUTES
# =========================================

@router.get("/analytics/household-demographics/{household_id}", response_model=APIResponse)
async def get_household_demographics(household_id: int):
    """Get household demographics using stored procedure with cursor"""
    try:
        data = census_service.get_household_demographics(household_id)
        return APIResponse(
            success=True,
            message="Household demographics retrieved successfully",
            data={"demographics": data},
            count=len(data)
        )
    except Exception as e:
        logger.error(f"Error retrieving household demographics: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/analytics/regional-statistics", response_model=APIResponse)
async def get_regional_statistics(region_name: Optional[str] = Query(None)):
    """Get regional statistics using stored procedure with cursor"""
    try:
        data = census_service.get_regional_statistics(region_name)
        return APIResponse(
            success=True,
            message="Regional statistics retrieved successfully",
            data={"statistics": data},
            count=len(data)
        )
    except Exception as e:
        logger.error(f"Error retrieving regional statistics: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/analytics/housing-conditions", response_model=APIResponse)
async def get_housing_conditions(district_name: Optional[str] = Query(None)):
    """Get housing conditions using stored procedure with cursor"""
    try:
        data = census_service.get_housing_conditions(district_name)
        return APIResponse(
            success=True,
            message="Housing conditions retrieved successfully",
            data={"conditions": data},
            count=len(data)
        )
    except Exception as e:
        logger.error(f"Error retrieving housing conditions: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/analytics/database-statistics", response_model=APIResponse)
async def get_database_statistics():
    """Get general database statistics"""
    try:
        data = census_service.get_database_statistics()
        return APIResponse(
            success=True,
            message="Database statistics retrieved successfully",
            data={"statistics": data}
        )
    except Exception as e:
        logger.error(f"Error retrieving database statistics: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# =========================================
# SEARCH & FILTER ROUTES
# =========================================

@router.post("/search/individuals", response_model=APIResponse)
async def search_individuals(
    filters: SearchFilters,
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100)
):
    """Search individuals with filters and pagination"""
    try:
        pagination = PaginationParams(page=page, size=size)
        data, total_count = census_service.search_individuals(filters, pagination)

        return APIResponse(
            success=True,
            message="Individual search completed successfully",
            data={
                "individuals": data,
                "pagination": {
                    "page": page,
                    "size": size,
                    "total": total_count,
                    "pages": (total_count + size - 1) // size
                }
            },
            count=len(data)
        )
    except Exception as e:
        logger.error(f"Error searching individuals: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# =========================================
# ACTIVITY LOG ROUTES
# =========================================

@router.get("/activity-log", response_model=APIResponse)
async def get_activity_log(
    table_name: Optional[str] = Query(None),
    operation_type: Optional[str] = Query(None),
    user_name: Optional[str] = Query(None),
    days_back: int = Query(7, ge=1, le=30)
):
    """Get activity log using stored procedure with cursor"""
    try:
        data = census_service.get_activity_log(table_name, operation_type, user_name, days_back)
        return APIResponse(
            success=True,
            message="Activity log retrieved successfully",
            data={"activity_log": data},
            count=len(data)
        )
    except Exception as e:
        logger.error(f"Error retrieving activity log: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# =========================================
# HEALTH CHECK ROUTES
# =========================================

@router.get("/health", response_model=APIResponse)
async def health_check():
    """Health check endpoint"""
    try:
        # Test database connection
        from app.database.oracle_connection import connection_manager
        is_connected = connection_manager.test_connection()

        return APIResponse(
            success=is_connected,
            message="Service is healthy" if is_connected else "Database connection failed",
            data={"database_connected": is_connected}
        )
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return APIResponse(
            success=False,
            message=f"Health check failed: {str(e)}"
        )
