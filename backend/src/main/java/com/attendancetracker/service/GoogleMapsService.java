package com.attendancetracker.service;

import com.google.maps.GeoApiContext;
import com.google.maps.GeocodingApi;
import com.google.maps.model.GeocodingResult;
import com.google.maps.model.LatLng;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class GoogleMapsService {

    private final GeoApiContext context;

    public GoogleMapsService(@Value("${google.maps-api-key:}") String apiKey) {
        if (apiKey != null && !apiKey.isEmpty()) {
            this.context = new GeoApiContext.Builder()
                .apiKey(apiKey)
                .build();
        } else {
            this.context = null;
        }
    }

    public String getAddressFromCoordinates(double latitude, double longitude) {
        if (context == null) {
            return "Address lookup not available (API key not configured)";
        }

        try {
            LatLng location = new LatLng(latitude, longitude);
            GeocodingResult[] results = GeocodingApi.reverseGeocode(context, location).await();

            if (results.length > 0) {
                return results[0].formattedAddress;
            }
        } catch (Exception e) {
            // Log error and return fallback
            System.err.println("Error getting address from coordinates: " + e.getMessage());
        }

        return String.format("%.6f, %.6f", latitude, longitude);
    }

    public LatLng getCoordinatesFromAddress(String address) {
        if (context == null) {
            throw new RuntimeException("Google Maps API key not configured");
        }

        try {
            GeocodingResult[] results = GeocodingApi.geocode(context, address).await();

            if (results.length > 0) {
                return results[0].geometry.location;
            }
        } catch (Exception e) {
            throw new RuntimeException("Error getting coordinates from address: " + e.getMessage());
        }

        throw new RuntimeException("No coordinates found for address: " + address);
    }

    public double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Radius of the earth in km

        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distance = R * c * 1000; // convert to meters

        return distance;
    }

    public boolean isWithinRadius(double employeeLat, double employeeLng,
                                double zoneLat, double zoneLng, double radiusMeters) {
        double distance = calculateDistance(employeeLat, employeeLng, zoneLat, zoneLng);
        return distance <= radiusMeters;
    }
}