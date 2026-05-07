# Employee Attendance & Productivity Tracking System — Complete Setup & Deployment Guide

## System Overview

This is a production-ready SaaS **multi-tenant attendance and productivity tracking platform** with:
- **Backend**: Spring Boot 3.2 + Java 21 with JWT auth, PostgreSQL
- **Super Admin Panel**: Next.js 14 dashboard for managing companies and billing
- **Company Admin Panel**: Next.js 14 for live employee tracking, location management, and alerts
- **Mobile App**: Flutter app for employees to clock in/out with GPS validation
- **PC Agent**: Python service for tracking productivity activity and idle time

---

## Prerequisites

### System Requirements
- **macOS/Linux**: Docker, Docker Compose (for PostgreSQL)
- **Java 21+**: For backend compilation and runtime
- **Node.js 18+**: For Next.js admin panels
- **Flutter 3.4+**: For mobile app development
- **Python 3.9+**: For PC agent service

### Environment Setup

```bash
# Install Homebrew packages (macOS)
brew install openjdk@21 node postgresql docker

# Or use Java from your PATH if already available
java -version  # Should be 21+
```

---

## Deployment Steps

### 1. Backend Service (Spring Boot)

#### Build
```bash
cd backend
mvn clean package -DskipTests
```

#### Database Setup
```bash
# Option A: Run PostgreSQL locally
brew install postgresql
brew services start postgresql

# Create database and user
psql -U postgres
CREATE DATABASE attendance_tracker;
CREATE USER attendance_user WITH PASSWORD 'secure_password';
ALTER ROLE attendance_user WITH CREATEDB;
GRANT ALL PRIVILEGES ON DATABASE attendance_tracker TO attendance_user;
\q
```

#### Or use Docker
```bash
docker run -d \
  --name postgres_att \
  -e POSTGRES_USER=attendance_user \
  -e POSTGRES_PASSWORD=secure_password \
  -e POSTGRES_DB=attendance_tracker \
  -p 5432:5432 \
  postgres:15
```

#### Run Backend
```bash
# Update application.yml if needed (database credentials, JWT secret)
java -jar target/backend-0.1.0.jar
# Server runs at http://localhost:8080
```

#### Test Backend
```bash
# Login as Super Admin
curl -X POST http://localhost:8080/auth/super-admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@attendancetracker.com","password":"secret"}'

# Response should contain JWT token
```

---

### 2. Super Admin Panel

#### Build & Run
```bash
cd super-admin-panel
npm install
npm run dev
# Open http://localhost:3000/login

# Or build for production
npm run build
npm start
```

#### Features
- Dashboard with company metrics
- Create/edit/suspend companies
- Billing and invoice management
- Platform-wide alerts
- Plan management

#### Test Accounts
- Email: `admin@attendancetracker.com`
- Password: `secret`

---

### 3. Company Admin Panel

#### Build & Run
```bash
cd company-admin-panel
npm install
npm run dev
# Open http://localhost:3001/login

# Or build for production
npm run build
npm start
```

#### Features
- Live employee attendance dashboard
- Real-time location tracking on map
- Employee management
- Location/zone setup
- PC agent monitoring
- Approval workflows
- Attendance reports and alerts

---

### 4. Mobile App (Flutter)

#### Build Android APK
```bash
cd mobile-app
flutter pub get
flutter build apk --release
# Generated at: build/app/outputs/apk/release/app-release.apk

# For testing on emulator
flutter run
```

#### Build iOS IPA
```bash
flutter build ios --release
# Uses Xcode for final packaging
```

#### Features
- OTP-based login
- Real-time attendance punch in/out
- Zone status display
- Attendance history
- User profile management
- Unknown location approval flow

---

### 5. PC Agent (Python Service)

#### Setup Environment
```bash
cd pc-agent
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

#### Configuration
```bash
# Create agent_token.json (auto-generated on first run, or preset)
cat > agent_token.json << EOF
{"token": "your-registration-token"}
EOF

# Set environment variables
export PC_AGENT_TOKEN_PATH=$(pwd)/agent_token.json
export PC_AGENT_DB=$(pwd)/agent_data.db
export PC_AGENT_KEY=$(pwd)/agent_key.bin
export API_BASE_URL=https://api.attendancetracker.com/v1  # Or http://localhost:8080/api for local
```

#### Run Agent
```bash
python src/main.py
# Agent will:
# - Create/load encryption key
# - Initialize local SQLite database
# - Register with backend
# - Start polling activity every 60 seconds
# - Send heartbeat every 5 minutes
```

#### Features
- Automatic PC registration with hardware ID
- Idle time detection (300 seconds)
- Activity tracking (active/idle)
- Local encrypted SQLite database
- Heartbeat and sync with backend
- Graceful shutdown on Ctrl+C

---

## Architecture & API Endpoints

### Authentication
- **POST** `/auth/super-admin/login` — Super admin login
- **POST** `/auth/employee/send-otp` — Send OTP to employee phone
- **POST** `/auth/employee/verify-otp` — Verify OTP and get JWT token

### Company Management (Super Admin)
- **GET** `/api/super-admin/companies` — List all companies
- **POST** `/api/super-admin/companies` — Create new company
- **PUT** `/api/super-admin/companies/{companyId}` — Update company

### Company Admin Dashboard
- **GET** `/api/company-admin/dashboard` — Dashboard summary (employees, check-ins, PCs online)
- **GET** `/api/company-admin/employees` — List company employees
- **POST** `/api/company-admin/employees` — Create employee

### PC Agent
- **POST** `/api/agent/register` — Register new PC agent
- **POST** `/api/agent/heartbeat` — Send agent heartbeat

---

## Database Schema

All tables are auto-created by Hibernate on first run (JPA `hibernate.ddl-auto=update`):

- `super_admins` — Platform administrators
- `companies` — SaaS tenants/organizations
- `employees` — Field workers and team members
- `attendance_records` — Clock in/out records with GPS
- `locations` — Approved work zones
- `pc_agents` — Registered workstation agents
- `activity_logs` — PC activity summaries
- `alerts` — Safety and compliance alerts

---

## Security Considerations

### JWT Configuration
Update `backend/src/main/resources/application.yml`:
```yaml
jwt:
  secret: CHANGE-THIS-TO-A-STRONG-SECRET-IN-PRODUCTION
  expiration: 86400000  # 24 hours in milliseconds
```

### Database
- Use strong password (not `secure_password` in production)
- Enable SSL for PostgreSQL connections in production
- Use managed database services (AWS RDS, Google Cloud SQL) in production

### API Endpoints
- All endpoints except `/auth/**` and `/api/agent/**` require valid JWT
- Implement rate limiting on authentication endpoints
- Use HTTPS/TLS in production environments

### Mobile / PC Agent
- Tokens stored securely using platform-specific secure storage
- PC agent database encrypted with Fernet (AES-128)
- GPS data validated against approved zones (distance + lat/long)

---

## Development & Testing

### Backend Testing
```bash
mvn test
mvn test-compile
```

### Next.js Linting
```bash
cd super-admin-panel && npm run lint
cd company-admin-panel && npm run lint
```

### Flutter Testing
```bash
cd mobile-app
flutter test
```

### PC Agent Testing
```bash
cd pc-agent
python -m pytest tests/  # (if test suite exists)
```

---

## Production Deployment Checklist

- [ ] Update JWT secret to a strong random value
- [ ] Set `ddl-auto` in Spring Boot config to `validate` (not `update`)
- [ ] Use managed PostgreSQL (AWS RDS, Google Cloud SQL)
- [ ] Enable HTTPS/TLS on all endpoints
- [ ] Set up domain/DNS (api.attendancetracker.com, admin.attendancetracker.com, etc.)
- [ ] Configure Firebase for OTP (mobile app)
- [ ] Set up Google Maps API key (mobile app)
- [ ] Deploy admin frontends to CDN (Vercel, Netlify, CloudFront)
- [ ] Configure PC agent distribution (Windows installer, macro, or deployment service)
- [ ] Set up monitoring and alerting (DataDog, New Relic, CloudWatch)
- [ ] Enable database backups and replication
- [ ] Implement audit logging for compliance
- [ ] Set up CI/CD pipelines (GitHub Actions, GitLab CI)

---

## Support & Troubleshooting

### Backend won't start
- Check PostgreSQL is running: `psql -U attendance_user -d attendance_tracker`
- Verify Java 21: `java -version`
- Check port 8080 is available: `lsof -i :8080`

### Admin panel won't load
- Clear `.next` cache: `rm -rf .next`
- Rebuild: `npm run build && npm start`
- Check backend is running on port 8080

### Mobile app GPS/location issues
- Enable location permissions in app settings
- Verify Google Maps API key is configured
- Test with real device (emulator GPS is unreliable)

### PC agent won't register
- Verify backend is accessible at configured API_BASE_URL
- Check firewall allows outbound HTTPS/HTTP
- Review agent logs for network errors
- Ensure JWT token in agent_token.json is valid

---

## Next Steps

1. Configure all external integrations (Firebase, Google Maps, AWS S3)
2. Customize branding (logos, colors, company name)
3. Add more validation and error handling
4. Implement real notification system (email, SMS, push)
5. Add role-based access control (RBAC)
6. Implement audit logging
7. Add advanced reporting and analytics
8. Set up company-specific geofencing rules

**System is now ready for end-to-end testing and production deployment!**
