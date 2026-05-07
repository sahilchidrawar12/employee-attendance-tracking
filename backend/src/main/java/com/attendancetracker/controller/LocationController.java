package com.attendancetracker.controller;

import com.attendancetracker.dto.LocationDTO;
import com.attendancetracker.model.Location;
import com.attendancetracker.repository.LocationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/locations")
public class LocationController {

    @Autowired
    private LocationRepository locationRepository;

    @GetMapping("/zones/{companyId}")
    public ResponseEntity<List<LocationDTO>> getCompanyZones(@PathVariable String companyId) {
        try {
            List<Location> zones = locationRepository.findByCompanyId(java.util.UUID.fromString(companyId));
            List<LocationDTO> dtos = zones.stream()
                    .map(this::convertToDTO)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(dtos);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/zones")
    public ResponseEntity<List<LocationDTO>> getAllZones() {
        try {
            List<Location> zones = locationRepository.findAll();
            List<LocationDTO> dtos = zones.stream()
                    .map(this::convertToDTO)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(dtos);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/zones")
    @PreAuthorize("hasRole('COMPANY_ADMIN')")
    public ResponseEntity<LocationDTO> createZone(@RequestBody LocationDTO dto) {
        try {
            Location location = new Location();
            location.setName(dto.getName());
            location.setLatitude(dto.getLatitude());
            location.setLongitude(dto.getLongitude());
            location.setRadius(dto.getRadius());
            location.setAddress(dto.getAddress());
            location.setType(dto.getType());
            location.setStatus("active");
            
            Location saved = locationRepository.save(location);
            return ResponseEntity.ok(convertToDTO(saved));
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/{locationId}")
    public ResponseEntity<LocationDTO> getZoneDetails(@PathVariable String locationId) {
        try {
            return locationRepository.findById(java.util.UUID.fromString(locationId))
                    .map(location -> ResponseEntity.ok(convertToDTO(location)))
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    private LocationDTO convertToDTO(Location location) {
        LocationDTO dto = new LocationDTO();
        dto.setId(location.getId().toString());
        dto.setName(location.getName());
        dto.setLatitude(location.getLatitude());
        dto.setLongitude(location.getLongitude());
        dto.setAddress(location.getAddress());
        dto.setType(location.getType());
        dto.setStatus(location.getStatus());
        dto.setRadius(location.getRadius());
        return dto;
    }
}
