# Testing Checklist - Employee Attendance Tracking System

## General
- [ ] Validate repository structure and component folders
- [ ] Confirm `README.md`, `ERD.md`, and API docs are present
- [ ] Ensure environment variables are documented

## Backend
- [ ] Run database migration script successfully on PostgreSQL
- [ ] Confirm API health endpoint returns healthy
- [ ] Validate JWT login flows for super admin and employee
- [ ] Test role-based authorization for super admin and company admin endpoints
- [ ] Validate company creation, update, and detail endpoints
- [ ] Confirm employee create/update/delete and profile endpoints
- [ ] Test attendance punch in/out and history endpoints
- [ ] Verify PC agent registration, sync, and heartbeat endpoints
- [ ] Validate mobile map data and location request submission
- [ ] Confirm alerts generation and read/unread flows
- [ ] Validate report generation and export endpoints

## Super Admin Panel
- [ ] Preview dashboard layout on desktop
- [ ] Validate KPI cards and charts layout
- [ ] Confirm companies table and filters render correctly
- [ ] Test add/edit company slide-over form UI
- [ ] Confirm plan cards and billing table layout
- [ ] Validate alerts list and filter design
- [ ] Ensure dark mode toggle works if implemented

## Company Admin Panel
- [ ] Preview admin dashboard statistics cards
- [ ] Validate attendance trend chart panel UI
- [ ] Confirm live map panel placeholder layout
- [ ] Test employees list, search and add employee UI
- [ ] Validate locations master panel and add location form design
- [ ] Confirm approvals workflow UI and review actions
- [ ] Check PC agents token generation UI flow
- [ ] Verify reports screen layout and filter controls
- [ ] Confirm alerts screen detail expansion and action buttons
- [ ] Validate settings tabs and form fields

## Mobile App
- [ ] Confirm splash screen and navigation to login
- [ ] Validate login/OTP screen layout and timer
- [ ] Ensure home screen punch card UI renders
- [ ] Confirm unknown location request flow UI
- [ ] Validate map screen placeholder and zone overlays
- [ ] Check history calendar and day detail layout
- [ ] Test profile screen with logout button
- [ ] Validate mock GPS warning screen UI

## PC Agent
- [ ] Confirm Python package dependencies in `requirements.txt`
- [ ] Validate agent registration payload structure
- [ ] Verify local SQLite initialization and encryption key handling
- [ ] Confirm activity tracker tick logic records active/idle summary
- [ ] Test heartbeat communication with backend endpoint
- [ ] Validate token file loading and registration sequence

## Security and Compliance
- [ ] Verify JWT tokens include role and company context
- [ ] Confirm password hashing for admin credentials
- [ ] Validate mobile OTP rate limiting conceptually
- [ ] Review mock GPS detection and alert flow
- [ ] Ensure data privacy and access controls in API docs

## Deployment
- [ ] Confirm AWS Mumbai region architecture recommendation
- [ ] Validate RDS PostgreSQL configuration and backup strategy
- [ ] Ensure frontend environment variables are documented
- [ ] Confirm mobile Firebase and Google Maps integration notes
- [ ] Verify PC agent installer delivery and security guidance
