CREATE TABLE attendance (
    employee_code VARCHAR(20),
    team_code VARCHAR(20),
    employee_name VARCHAR(100),
    designation VARCHAR(100),
    department VARCHAR(100),
    circle VARCHAR(100),
    project VARCHAR(100),
    customer VARCHAR(100),
    site_id VARCHAR(30),
    reporting_manager VARCHAR(100),
    attendance_date DATE,
    check_in_time TIMESTAMP,
    check_in_gps VARCHAR(100),
    check_out_time TIMESTAMP,
    check_out_gps VARCHAR(100),
    attendance_status VARCHAR(30),
    shift VARCHAR(30),
    leave_type VARCHAR(50),
    regularization_status VARCHAR(30),
    approval_status VARCHAR(30),
    remarks VARCHAR(255),
    device_user_id VARCHAR(50),
    created_modified_datetime TIMESTAMP
);
CREATE DATABASE "ssq attendance";
--Confirm 500 rows
SELECT COUNT(*) AS total_records
FROM attendance;

--View the data
SELECT *
FROM attendance
LIMIT 10;

--Check table structure
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'attendance'
ORDER BY ordinal_position;

--Check missing values
SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (WHERE employee_code IS NULL) AS missing_employee_code,
    COUNT(*) FILTER (WHERE team_code IS NULL) AS missing_team_code,
    COUNT(*) FILTER (WHERE employee_name IS NULL) AS missing_employee_name,
    COUNT(*) FILTER (WHERE attendance_date IS NULL) AS missing_attendance_date,
    COUNT(*) FILTER (WHERE attendance_status IS NULL) AS missing_status
FROM attendance;

--Check duplicate attendance
SELECT
    employee_code,
    attendance_date,
    COUNT(*) AS record_count
FROM attendance
GROUP BY employee_code, attendance_date
HAVING COUNT(*) > 1;

--Check attendance status
SELECT
    attendance_status,
    COUNT(*) AS total_records
FROM attendance
GROUP BY attendance_status
ORDER BY total_records DESC;

--Check Leave Types
SELECT
    leave_type,
    COUNT(*) AS total
FROM attendance
WHERE attendance_status = 'Leave'
GROUP BY leave_type
ORDER BY total DESC;


--Employee-wise attendance
SELECT
    employee_code,
    employee_name,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE attendance_status = 'Present'
    ) AS present_days,
    COUNT(*) FILTER (
        WHERE attendance_status = 'Absent'
    ) AS absent_days,
    COUNT(*) FILTER (
        WHERE attendance_status = 'Leave'
    ) AS leave_days
FROM attendance
GROUP BY employee_code, employee_name
ORDER BY employee_code;


--Attendance percentage
SELECT
    employee_code,
    employee_name,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE attendance_status = 'Present'
    ) AS present_days,
    ROUND(
        COUNT(*) FILTER (
            WHERE attendance_status = 'Present'
        ) * 100.0 / COUNT(*),
        2
    ) AS attendance_percentage
FROM attendance
GROUP BY employee_code, employee_name
ORDER BY attendance_percentage DESC;


--Team-wise attendance
SELECT
    team_code,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE attendance_status = 'Present'
    ) AS present_count,
    COUNT(*) FILTER (
        WHERE attendance_status = 'Absent'
    ) AS absent_count,
    COUNT(*) FILTER (
        WHERE attendance_status = 'Leave'
    ) AS leave_count,
    COUNT(*) FILTER (
        WHERE attendance_status = 'Half Day'
    ) AS half_day_count
FROM attendance
GROUP BY team_code
ORDER BY team_code;


--Circle-wise attendance
SELECT
    circle,
    attendance_status,
    COUNT(*) AS total_records
FROM attendance
GROUP BY circle, attendance_status
ORDER BY circle, attendance_status;


--Project-wise attendance
SELECT
    project,
    attendance_status,
    COUNT(*) AS total_records
FROM attendance
GROUP BY project, attendance_status
ORDER BY project, attendance_status;


--Missing check-out
SELECT
    employee_code,
    employee_name,
    attendance_date,
    check_in_time,
    attendance_status,
    regularization_status,
    remarks
FROM attendance
WHERE attendance_status IN ('Present', 'Half Day')
AND check_out_time IS NULL;


--Late login
SELECT
    employee_code,
    employee_name,
    attendance_date,
    check_in_time,
    remarks
FROM attendance
WHERE remarks = 'Late login';


--Early logout
SELECT
    employee_code,
    employee_name,
    attendance_date,
    check_out_time,
    remarks
FROM attendance
WHERE remarks = 'Early logout';


--Pending regularization
SELECT
    employee_code,
    employee_name,
    attendance_date,
    attendance_status,
    regularization_status,
    remarks
FROM attendance
WHERE regularization_status = 'Pending';


--Unapproved absence
SELECT
    employee_code,
    employee_name,
    attendance_date,
    attendance_status,
    approval_status,
    remarks
FROM attendance
WHERE attendance_status = 'Absent'
AND approval_status = 'Pending';


--Working hours
SELECT
    employee_code,
    employee_name,
    attendance_date,
    check_in_time,
    check_out_time,
    ROUND(
        (EXTRACT(EPOCH FROM (check_out_time - check_in_time)) / 3600)::numeric,
        2
    ) AS working_hours
FROM attendance
WHERE check_in_time IS NOT NULL
AND check_out_time IS NOT NULL;


--GPS exceptions
SELECT
    employee_code,
    employee_name,
    attendance_date,
    attendance_status,
    check_in_gps,
    check_out_gps
FROM attendance
WHERE attendance_status IN ('Present', 'Half Day')
AND (
    check_in_gps IS NULL
    OR check_in_gps = ''
    OR check_out_gps IS NULL
    OR check_out_gps = ''
);


--Monthly attendance
SELECT
    DATE_TRUNC('month', attendance_date)::DATE AS attendance_month,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE attendance_status = 'Present'
    ) AS present_days,
    COUNT(*) FILTER (
        WHERE attendance_status = 'Absent'
    ) AS absent_days,
    COUNT(*) FILTER (
        WHERE attendance_status = 'Leave'
    ) AS leave_days
FROM attendance
GROUP BY DATE_TRUNC('month', attendance_date)
ORDER BY attendance_month;