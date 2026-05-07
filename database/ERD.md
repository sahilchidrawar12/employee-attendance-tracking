# Employee Attendance & Productivity Tracking System - Database ERD

## Overview
Multi-tenant SaaS platform with isolated schemas per company. Each company has its own database schema for complete data isolation.

## Core Tables

### 1. super_admins
Platform owner authentication table.
```
super_admins {
  id: UUID (PK)
  email: VARCHAR(255) UNIQUE
  password_hash: VARCHAR(255)
  created_at: TIMESTAMP
  last_login: TIMESTAMP
  status: ENUM('active', 'inactive')
}
```

### 2. plans
Subscription plans offered by the platform.
```
plans {
  id: UUID (PK)
  name: VARCHAR(100) UNIQUE
  max_users: INTEGER
  price_monthly: DECIMAL(10,2)
  features_json: JSONB
  is_active: BOOLEAN DEFAULT true
  created_at: TIMESTAMP
}
```

### 3. companies
Company/tenant information.
```
companies {
  id: UUID (PK)
  name: VARCHAR(255)
  owner_name: VARCHAR(255)
  email: VARCHAR(255) UNIQUE
  phone: VARCHAR(20)
  plan_id: UUID (FK → plans.id)
  max_users: INTEGER
  status: ENUM('active', 'inactive', 'suspended')
  logo_url: VARCHAR(500)
  address: TEXT
  city: VARCHAR(100)
  state: VARCHAR(100)
  timezone: VARCHAR(50)
  created_at: TIMESTAMP
  updated_at: TIMESTAMP
}
```

### 4. employees
Employee information within each company.
```
employees {
  id: UUID (PK)
  company_id: UUID (FK → companies.id)
  name: VARCHAR(255)
  email: VARCHAR(255)
  phone: VARCHAR(20) UNIQUE
  department: VARCHAR(100)
  designation: VARCHAR(100)
  manager_id: UUID (FK → employees.id, self-reference)
  work_start_time: TIME
  work_end_time: TIME
  avatar_url: VARCHAR(500)
  status: ENUM('active', 'inactive', 'terminated')
  firebase_uid: VARCHAR(255)
  created_at: TIMESTAMP
  updated_at: TIMESTAMP
}
```

### 5. locations
Geofenced zones/locations for each company.
```
locations {
  id: UUID (PK)
  company_id: UUID (FK → companies.id)
  name: VARCHAR(255)
  type: ENUM('office', 'client', 'government', 'bank', 'other')
  address: TEXT
  latitude: DECIMAL(10,8)
  longitude: DECIMAL(11,8)
  radius_meters: INTEGER
  status: ENUM('active', 'inactive')
  approval_status: ENUM('approved', 'pending', 'rejected')
  created_by: UUID (FK → employees.id)
  created_at: TIMESTAMP
  updated_at: TIMESTAMP
}
```

### 6. attendance_logs
Daily attendance records.
```
attendance_logs {
  id: UUID (PK)
  employee_id: UUID (FK → employees.id)
  company_id: UUID (FK → companies.id)
  punch_in: TIMESTAMP
  punch_out: TIMESTAMP NULL
  total_hours: DECIMAL(5,2) NULL
  zone_id: UUID (FK → locations.id) NULL
  date: DATE
  is_manual: BOOLEAN DEFAULT false
  created_at: TIMESTAMP
  updated_at: TIMESTAMP
}
```

### 7. zone_visits
Detailed zone entry/exit logs.
```
zone_visits {
  id: UUID (PK)
  employee_id: UUID (FK → employees.id)
  location_id: UUID (FK → locations.id)
  entered_at: TIMESTAMP
  exited_at: TIMESTAMP NULL
  duration_minutes: INTEGER NULL
  created_at: TIMESTAMP
}
```

### 8. gps_pings
GPS location tracking data.
```
gps_pings {
  id: UUID (PK)
  employee_id: UUID (FK → employees.id)
  latitude: DECIMAL(10,8)
  longitude: DECIMAL(11,8)
  accuracy: DECIMAL(5,2)
  is_mock: BOOLEAN DEFAULT false
  zone_id: UUID (FK → locations.id) NULL
  timestamp: TIMESTAMP
  created_at: TIMESTAMP
}
```

### 9. pc_agents
PC agent registration and mapping.
```
pc_agents {
  id: UUID (PK)
  employee_id: UUID (FK → employees.id)
  company_id: UUID (FK → companies.id)
  hardware_id: VARCHAR(255) UNIQUE
  token: VARCHAR(255) UNIQUE
  pc_name: VARCHAR(255)
  last_sync: TIMESTAMP NULL
  status: ENUM('mapped', 'online', 'offline', 'inactive')
  mapped_at: TIMESTAMP
  created_at: TIMESTAMP
}
```

### 10. pc_activity_logs
PC activity tracking (daily summaries).
```
pc_activity_logs {
  id: UUID (PK)
  agent_id: UUID (FK → pc_agents.id)
  employee_id: UUID (FK → employees.id)
  session_start: TIMESTAMP
  session_end: TIMESTAMP NULL
  active_minutes: INTEGER DEFAULT 0
  idle_minutes: INTEGER DEFAULT 0
  date: DATE
  synced_at: TIMESTAMP NULL
  is_offline_sync: BOOLEAN DEFAULT false
  created_at: TIMESTAMP
}
```

### 11. app_usage_logs
Application usage tracking.
```
app_usage_logs {
  id: UUID (PK)
  agent_id: UUID (FK → pc_agents.id)
  app_name: VARCHAR(255)
  window_title: TEXT
  duration_minutes: INTEGER
  is_productive: BOOLEAN
  date: DATE
  created_at: TIMESTAMP
}
```

### 12. location_requests
Employee location approval requests.
```
location_requests {
  id: UUID (PK)
  employee_id: UUID (FK → employees.id)
  company_id: UUID (FK → companies.id)
  location_name: VARCHAR(255)
  type: ENUM('office', 'client', 'government', 'bank', 'other')
  latitude: DECIMAL(10,8)
  longitude: DECIMAL(11,8)
  reason: TEXT
  status: ENUM('pending', 'approved', 'rejected')
  reviewed_by: UUID (FK → employees.id) NULL
  reviewed_at: TIMESTAMP NULL
  created_at: TIMESTAMP
}
```

### 13. alerts
System alerts and notifications.
```
alerts {
  id: UUID (PK)
  company_id: UUID (FK → companies.id)
  employee_id: UUID (FK → employees.id) NULL
  type: ENUM('mock_gps', 'out_of_zone', 'late_login', 'idle_exceeded', 'agent_offline', 'location_request', 'system')
  severity: ENUM('low', 'medium', 'high', 'critical')
  message: TEXT
  is_read: BOOLEAN DEFAULT false
  metadata: JSONB
  created_at: TIMESTAMP
}
```

### 14. disputes
Attendance dispute records.
```
disputes {
  id: UUID (PK)
  employee_id: UUID (FK → employees.id)
  attendance_log_id: UUID (FK → attendance_logs.id)
  reason: TEXT
  status: ENUM('pending', 'resolved', 'dismissed')
  resolved_by: UUID (FK → employees.id) NULL
  resolved_at: TIMESTAMP NULL
  resolution_notes: TEXT NULL
  created_at: TIMESTAMP
}
```

### 15. company_settings
Company-specific configuration.
```
company_settings {
  id: UUID (PK)
  company_id: UUID (FK → companies.id) UNIQUE
  idle_threshold_minutes: INTEGER DEFAULT 5
  productive_apps: JSONB
  work_weekends: BOOLEAN DEFAULT false
  timezone: VARCHAR(50)
  notification_settings: JSONB
  created_at: TIMESTAMP
  updated_at: TIMESTAMP
}
```

## Relationships

### One-to-Many Relationships:
- companies → employees (1:N)
- companies → locations (1:N)
- companies → pc_agents (1:N)
- companies → alerts (1:N)
- employees → attendance_logs (1:N)
- employees → zone_visits (1:N)
- employees → gps_pings (1:N)
- employees → location_requests (1:N)
- employees → disputes (1:N)
- locations → zone_visits (1:N)
- pc_agents → pc_activity_logs (1:N)
- pc_agents → app_usage_logs (1:N)
- attendance_logs → disputes (1:N)

### Many-to-One Relationships:
- employees → companies
- locations → companies
- pc_agents → companies
- alerts → companies

### Self-Referencing Relationships:
- employees.manager_id → employees.id (Manager hierarchy)

### Many-to-Many Relationships:
- employees ↔ locations (through zone_visits and attendance_logs)

## Indexes

### Performance Indexes:
- companies(email)
- employees(company_id, status)
- employees(phone)
- locations(company_id, status)
- attendance_logs(employee_id, date)
- attendance_logs(company_id, date)
- zone_visits(employee_id, entered_at)
- gps_pings(employee_id, timestamp)
- pc_agents(employee_id)
- pc_agents(hardware_id)
- pc_activity_logs(agent_id, date)
- app_usage_logs(agent_id, date)
- alerts(company_id, is_read, created_at)
- disputes(employee_id, status)

### Unique Indexes:
- super_admins(email)
- companies(email)
- employees(phone)
- pc_agents(hardware_id)
- pc_agents(token)

## Multi-Tenant Architecture

### Schema Isolation:
- Each company gets its own PostgreSQL schema
- Schema naming: company_{company_id}
- Shared tables in public schema: super_admins, plans
- Company-specific tables in isolated schemas

### Row-Level Security:
- All queries include company_id filtering
- JWT tokens contain company_id for automatic filtering
- Database triggers ensure data isolation

### Data Partitioning:
- Large tables partitioned by date:
  - gps_pings (monthly partitions)
  - pc_activity_logs (monthly partitions)
  - app_usage_logs (monthly partitions)
  - attendance_logs (monthly partitions)

## Data Retention Policies

- GPS pings: 90 days
- PC activity logs: 1 year
- App usage logs: 1 year
- Attendance logs: 3 years
- Alerts: 6 months
- Location requests: 1 year

## Backup Strategy

- Daily incremental backups
- Weekly full backups
- Point-in-time recovery capability
- Cross-region backup replication
- Encrypted backup storage