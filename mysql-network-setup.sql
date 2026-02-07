-- MySQL Network Access Setup
-- Creates 'remote_user' for database operations from any host
-- This avoids root user issues and provides proper access control

-- Run with mysqlsh --sql -u root -p[PASSWORD] < mysql-network-setup.sql

-- Create remote_user for access from any host (used by chears-dotnet and chears-sql-migrations)
CREATE USER IF NOT EXISTS 'remote_user'@'%' IDENTIFIED BY 'G1234567';

-- Grant privileges on all chears databases (chears_new, chears_int, etc.)
GRANT ALL PRIVILEGES ON `chears_%`.* TO 'remote_user'@'%';
GRANT CREATE ON *.* TO 'remote_user'@'%';

-- Apply changes
FLUSH PRIVILEGES;

-- Show created user
SELECT User, Host FROM mysql.user WHERE User = 'remote_user';

-- CONNECTION TESTING COMMANDS
-- Run these commands separately to test the remote_user connections

-- Test 1: Test localhost connection
-- mysqlsh --sql -u remote_user -p -h localhost -e "SELECT 'localhost connection successful' as test_result;"

-- Test 2: Test network connection (replace YOUR_SERVER_IP with actual server IP)
-- mysqlsh --sql -u remote_user -p -h YOUR_SERVER_IP -e "SELECT 'network connection successful' as test_result;"

-- Test 3: Check if MySQL is listening on all interfaces
-- netstat -an | grep 3306

-- Test 4: Test port connectivity from remote machine
-- telnet YOUR_SERVER_IP 3306

-- Test 5: Show MySQL bind-address configuration
-- mysqlsh --sql -u root -p -e "SHOW VARIABLES LIKE 'bind_address';"

-- Test 6: Show remote_user grants
-- mysqlsh --sql -u root -p -e "SHOW GRANTS FOR 'remote_user'@'%';"

-- TROUBLESHOOTING NOTES:
-- If network connections fail, check:
-- 1. MySQL bind-address setting (should be 0.0.0.0 or commented out)
-- 2. Firewall rules allowing port 3306
-- 3. MySQL service is running and listening on port 3306
