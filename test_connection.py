"""
Simple Oracle Database Connection Test
"""

import sys
import os

# Add project root to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_basic_connection():
    """Test basic Oracle connection with detailed error handling"""
    print("🔍 Testing Oracle Database Connection...")
    
    try:
        # Import configuration
        from config.oracle_config import settings, ORACLE_CONFIG
        
        print(f"📋 Connection Details:")
        print(f"   Host: {settings.ORACLE_HOST}")
        print(f"   Port: {settings.ORACLE_PORT}")
        print(f"   SID: {settings.ORACLE_SID}")
        print(f"   Service Name: {settings.ORACLE_SERVICE_NAME}")
        print(f"   Username: {settings.ORACLE_USERNAME}")
        print(f"   DSN: {settings.oracle_dsn}")
        print()
        
        # Test with oracledb
        import oracledb
        print("✅ oracledb module imported successfully")
        
        # Try to connect
        print("🔗 Attempting connection...")
        connection = oracledb.connect(**ORACLE_CONFIG)
        
        print("✅ Connection successful!")
        
        # Test a simple query
        cursor = connection.cursor()
        cursor.execute("SELECT 'Hello from Oracle!' as message, SYSDATE as current_time FROM DUAL")
        result = cursor.fetchone()
        
        print(f"✅ Query test successful: {result[0]} at {result[1]}")
        
        cursor.close()
        connection.close()
        
        print("✅ All tests passed! Your Oracle connection is working.")
        return True
        
    except oracledb.DatabaseError as e:
        error_obj, = e.args
        print(f"❌ Oracle Database Error:")
        print(f"   Code: {error_obj.code}")
        print(f"   Message: {error_obj.message}")
        
        # Provide specific suggestions based on error code
        if "ORA-12505" in str(e) or "DPY-6003" in str(e):
            print("\n💡 This error means the SID is not registered with the listener.")
            print("   Possible solutions:")
            print("   1. Check if Oracle database is running")
            print("   2. Verify the SID name (common values: XE, ORCL, XEPDB1)")
            print("   3. Try using SERVICE_NAME instead of SID in .env file")
            print("   4. Check Oracle listener status: lsnrctl status")
            
        elif "ORA-12541" in str(e) or "DPY-6005" in str(e):
            print("\n💡 This error means cannot connect to the database server.")
            print("   Possible solutions:")
            print("   1. Check if Oracle database is installed and running")
            print("   2. Verify ORACLE_HOST and ORACLE_PORT in .env file")
            print("   3. Check firewall settings")
            
        elif "ORA-01017" in str(e):
            print("\n💡 This error means invalid username/password.")
            print("   Possible solutions:")
            print("   1. Verify ORACLE_USERNAME and ORACLE_PASSWORD in .env file")
            print("   2. Check if the user account exists and is unlocked")
            
        return False
        
    except ImportError as e:
        print(f"❌ Import Error: {e}")
        print("💡 Make sure you have installed the required packages:")
        print("   pip install oracledb")
        return False
        
    except Exception as e:
        print(f"❌ Unexpected Error: {e}")
        print("💡 Check your .env file configuration and Oracle installation")
        return False

def main():
    """Main function"""
    print("=" * 60)
    print("🧪 Oracle Database Connection Test")
    print("=" * 60)
    
    success = test_basic_connection()
    
    print("\n" + "=" * 60)
    if success:
        print("🎉 SUCCESS: Oracle connection is working!")
        print("You can now run your application: python app/main.py")
    else:
        print("❌ FAILED: Oracle connection is not working")
        print("Run the diagnostic tool for more help: python diagnose_oracle.py")
    print("=" * 60)
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())