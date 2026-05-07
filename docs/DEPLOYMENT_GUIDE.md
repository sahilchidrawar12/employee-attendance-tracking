# Deployment Guide - AWS Mumbai

## Overview
This deployment guide covers the recommended setup for the Employee Attendance Tracking SaaS platform in AWS Mumbai (`ap-south-1`). The architecture includes backend services, database, web frontends, mobile backend integration, and PC agent delivery.

## Architecture Summary
- **Backend API**: Spring Boot service running on AWS Elastic Beanstalk / ECS
- **Database**: Amazon RDS for PostgreSQL
- **Web Apps**: Next.js apps deployed to Vercel / AWS Amplify / S3 + CloudFront
- **Mobile App**: Flutter builds published to Google Play Store and Apple App Store
- **PC Agent**: Windows installer distributed through secure download links; service communicates to backend API
- **Storage**: Amazon S3 for assets, installer binaries, and logs
- **Authentication**: JWT authentication and Firebase OTP for mobile login
- **Maps**: Google Maps API with restrict access to web/mobile domains

## Infrastructure Components

### 1. AWS VPC
- Create a dedicated VPC in `ap-south-1`
- Public and private subnets across 2 AZs
- NAT Gateway for backend internet access
- Security groups for web, application, and database tiers

### 2. Amazon RDS PostgreSQL
- Engine: PostgreSQL 15
- Instance: db.t4g.medium or larger
- Storage: 200 GB gp3
- Multi-AZ: enabled for production
- Backups: automated daily with 7-day retention
- Public accessibility: no
- Parameter group: enable `uuid-ossp` and `pgcrypto`

### 3. Backend Service
Option A: AWS Elastic Beanstalk
- Create Java SE environment
- Deploy packaged JAR
- Environment variables: `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD`, `JWT_SECRET`, etc.

Option B: Amazon ECS
- Build Docker image with JDK 21 and Spring Boot jar
- Push to ECR
- Run service behind Application Load Balancer

### 4. Web Frontends
- Build `super-admin-panel` and `company-admin-panel` using Next.js
- Deploy to Vercel or AWS Amplify
- Set environment variables for API base URL and Google Maps key
- Setup SSL and custom domains

### 5. Storage and Assets
- S3 bucket: `attendancetracker-assets-ap-south-1`
- Use for: company logos, installer binaries, token files
- Enable bucket policy to allow only authenticated backend access

### 6. Firebase
- Configure Firebase project for authentication and FCM
- Use OTP authentication for mobile phone login
- Add iOS and Android apps in Firebase console
- Copy API key and config values into mobile app

### 7. Monitoring
- CloudWatch for backend logs and metrics
- RDS performance insights enabled
- AWS WAF for web protection
- Sentry / Datadog optional for frontend and backend error monitoring

## Deployment Steps

### Backend Deployment
1. Build the backend:
   ```bash
   cd backend
   mvn clean package -DskipTests
   ```
2. Deploy to Elastic Beanstalk or ECS.
3. Verify `/health` endpoint returns healthy.
4. Apply database migrations from `database/migrations/001_initial_schema.sql`.

### Frontend Deployment
1. Install dependencies:
   ```bash
   cd super-admin-panel
   npm install
   npm run build
   ```
2. Repeat for `company-admin-panel`.
3. Deploy to hosting platform and set environment variables.

### Mobile App Release
1. Update `pubspec.yaml` and app icons.
2. Configure Firebase and Google Maps API keys.
3. Build release APK / App Bundle for Android.
4. Build release archive for iOS.
5. Publish to stores.

### PC Agent Release
1. Package `pc-agent` with Python runtime or PyInstaller.
2. Publish installer `.exe` to secure S3 location.
3. Provide admin token file download support in company admin panel.

## Environment Variables
### Backend
- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`
- `JWT_SECRET`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_API_KEY`
- `GOOGLE_MAPS_API_KEY`
- `AWS_REGION`
- `AWS_S3_BUCKET`

### Web Frontend
- `NEXT_PUBLIC_API_BASE_URL`
- `NEXT_PUBLIC_MAPS_API_KEY`

### Mobile App
- `FIREBASE_API_KEY`
- `FIREBASE_PROJECT_ID`
- `API_BASE_URL`

## Security Best Practices
- Use AWS Secrets Manager for database and JWT secrets
- Enforce HTTPS on all endpoints
- Restrict Firebase and Google Maps keys by domain
- Use AWS IAM roles for ECS / Lambda access to S3
- Enable CloudFront WAF for frontend URLs
- Use strong password hashing (bcrypt) for admins

## Backup and Disaster Recovery
- Enable RDS automated backups
- Use S3 versioning for uploaded assets
- Export daily schema snapshots
- Test restore workflow quarterly

## Post-deployment Validation
- Validate super-admin login and admin dashboard data
- Validate company admin dashboard and live map connectivity
- Validate mobile OTP login and punch workflows
- Validate PC agent registration and sync endpoints
- Verify alert events and report generation
