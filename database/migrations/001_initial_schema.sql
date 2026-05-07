-- Employee Attendance Tracking System - Database Schema
-- PostgreSQL Multi-tenant SaaS Platform

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'terminated', 'suspended');
CREATE TYPE location_type AS ENUM ('office', 'client', 'government', 'bank', 'other');
CREATE TYPE approval_status AS ENUM ('approved', 'pending', 'rejected');
CREATE TYPE alert_type AS ENUM ('mock_gps', 'out_of_zone', 'late_login', 'idle_exceeded', 'agent_offline', 'location_request', 'system');
CREATE TYPE alert_severity AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE dispute_status AS ENUM ('pending', 'resolved', 'dismissed');
CREATE TYPE agent_status AS ENUM ('mapped', 'online', 'offline', 'inactive');

-- Super Admin Table (Platform Owner)
CREATE TABLE super_admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE,
    status user_status DEFAULT 'active'
);

-- Subscription Plans
CREATE TABLE plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    max_users INTEGER NOT NULL,
    price_monthly DECIMAL(10,2) NOT NULL,
    features_json JSONB,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Companies/Tenants
CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    owner_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    plan_id UUID REFERENCES plans(id),
    max_users INTEGER NOT NULL,
    status user_status DEFAULT 'active',
    logo_url VARCHAR(500),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Employees
CREATE TABLE employees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    department VARCHAR(100),
    designation VARCHAR(100),
    manager_id UUID REFERENCES employees(id),
    work_start_time TIME,
    work_end_time TIME,
    avatar_url VARCHAR(500),
    status user_status DEFAULT 'active',
    firebase_uid VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Locations/Geofences
CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type location_type NOT NULL,
    address TEXT,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    radius_meters INTEGER NOT NULL DEFAULT 100,
    status user_status DEFAULT 'active',
    approval_status approval_status DEFAULT 'approved',
    created_by UUID REFERENCES employees(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Attendance Logs
CREATE TABLE attendance_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    punch_in TIMESTAMP WITH TIME ZONE NOT NULL,
    punch_out TIMESTAMP WITH TIME ZONE,
    total_hours DECIMAL(5,2),
    zone_id UUID REFERENCES locations(id),
    date DATE NOT NULL,
    is_manual BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Zone Visits (Detailed zone entry/exit tracking)
CREATE TABLE zone_visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    location_id UUID NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
    entered_at TIMESTAMP WITH TIME ZONE NOT NULL,
    exited_at TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- GPS Pings (Location tracking)
CREATE TABLE gps_pings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    accuracy DECIMAL(5,2),
    is_mock BOOLEAN DEFAULT false,
    zone_id UUID REFERENCES locations(id),
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (timestamp);

-- PC Agents
CREATE TABLE pc_agents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    hardware_id VARCHAR(255) UNIQUE NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    pc_name VARCHAR(255),
    last_sync TIMESTAMP WITH TIME ZONE,
    status agent_status DEFAULT 'mapped',
    mapped_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- PC Activity Logs (Daily summaries)
CREATE TABLE pc_activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_id UUID NOT NULL REFERENCES pc_agents(id) ON DELETE CASCADE,
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    session_start TIMESTAMP WITH TIME ZONE NOT NULL,
    session_end TIMESTAMP WITH TIME ZONE,
    active_minutes INTEGER DEFAULT 0,
    idle_minutes INTEGER DEFAULT 0,
    date DATE NOT NULL,
    synced_at TIMESTAMP WITH TIME ZONE,
    is_offline_sync BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (date);

-- Application Usage Logs
CREATE TABLE app_usage_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_id UUID NOT NULL REFERENCES pc_agents(id) ON DELETE CASCADE,
    app_name VARCHAR(255) NOT NULL,
    window_title TEXT,
    duration_minutes INTEGER NOT NULL DEFAULT 0,
    is_productive BOOLEAN DEFAULT false,
    date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (date);

-- Location Requests (Employee submitted locations for approval)
CREATE TABLE location_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    location_name VARCHAR(255) NOT NULL,
    type location_type NOT NULL,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    reason TEXT,
    status approval_status DEFAULT 'pending',
    reviewed_by UUID REFERENCES employees(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Alerts & Notifications
CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    type alert_type NOT NULL,
    severity alert_severity DEFAULT 'medium',
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Attendance Disputes
CREATE TABLE disputes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    attendance_log_id UUID NOT NULL REFERENCES attendance_logs(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    status dispute_status DEFAULT 'pending',
    resolved_by UUID REFERENCES employees(id),
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolution_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Company Settings
CREATE TABLE company_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID UNIQUE NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    idle_threshold_minutes INTEGER DEFAULT 5,
    productive_apps JSONB DEFAULT '[]',
    work_weekends BOOLEAN DEFAULT false,
    timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',
    notification_settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX idx_companies_email ON companies(email);
CREATE INDEX idx_companies_status ON companies(status);
CREATE INDEX idx_employees_company_status ON employees(company_id, status);
CREATE INDEX idx_employees_phone ON employees(phone);
CREATE INDEX idx_employees_manager ON employees(manager_id);
CREATE INDEX idx_locations_company_status ON locations(company_id, status);
CREATE INDEX idx_locations_coordinates ON locations(latitude, longitude);
CREATE INDEX idx_attendance_employee_date ON attendance_logs(employee_id, date);
CREATE INDEX idx_attendance_company_date ON attendance_logs(company_id, date);
CREATE INDEX idx_zone_visits_employee_entered ON zone_visits(employee_id, entered_at);
CREATE INDEX idx_gps_employee_timestamp ON gps_pings(employee_id, timestamp);
CREATE INDEX idx_pc_agents_employee ON pc_agents(employee_id);
CREATE INDEX idx_pc_agents_hardware ON pc_agents(hardware_id);
CREATE INDEX idx_pc_activity_agent_date ON pc_activity_logs(agent_id, date);
CREATE INDEX idx_app_usage_agent_date ON app_usage_logs(agent_id, date);
CREATE INDEX idx_alerts_company_read_created ON alerts(company_id, is_read, created_at);
CREATE INDEX idx_disputes_employee_status ON disputes(employee_id, status);

-- Create partitions for large tables (monthly partitions for current year)
-- GPS Pings partitions
CREATE TABLE gps_pings_2024_01 PARTITION OF gps_pings FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE gps_pings_2024_02 PARTITION OF gps_pings FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
-- Add more partitions as needed...

-- PC Activity Logs partitions
CREATE TABLE pc_activity_logs_2024_01 PARTITION OF pc_activity_logs FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE pc_activity_logs_2024_02 PARTITION OF pc_activity_logs FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
-- Add more partitions as needed...

-- App Usage Logs partitions
CREATE TABLE app_usage_logs_2024_01 PARTITION OF app_usage_logs FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE app_usage_logs_2024_02 PARTITION OF app_usage_logs FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
-- Add more partitions as needed...

-- Insert default plans
INSERT INTO plans (name, max_users, price_monthly, features_json) VALUES
('Starter', 25, 999.00, '{
  "mobile_only": true,
  "basic_reports": true,
  "email_support": true
}'),
('Professional', 100, 2499.00, '{
  "mobile_pc_tracking": true,
  "approvals": true,
  "advanced_reports": true,
  "priority_support": true
}'),
('Enterprise', 999999, 4999.00, '{
  "all_features": true,
  "custom_integrations": true,
  "dedicated_support": true,
  "white_label": true
}');

-- Insert default super admin
INSERT INTO super_admins (email, password_hash) VALUES
('admin@attendancetracker.com', '$2a$10$hashedpasswordhere'); -- Use bcrypt hash

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers
CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON companies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON employees FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_locations_updated_at BEFORE UPDATE ON locations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_attendance_logs_updated_at BEFORE UPDATE ON attendance_logs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_company_settings_updated_at BEFORE UPDATE ON company_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();