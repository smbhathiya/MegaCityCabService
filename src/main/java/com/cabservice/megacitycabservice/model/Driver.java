package com.cabservice.megacitycabservice.model;

import java.util.UUID;

public class Driver {
    private UUID id;
    private UUID userId;
    private UUID carId;
    private String licenseNumber;
    private String availabilityStatus;
    private double rating;
    private String createdAt;
    private String updatedAt;
    private String name;  // Added from users table
    private String email; // Added from users table

    // Constructor
    public Driver(UUID id, UUID userId, UUID carId, String licenseNumber, String availabilityStatus, double rating, String createdAt, String updatedAt) {
        this.id = id;
        this.userId = userId;
        this.carId = carId;
        this.licenseNumber = licenseNumber;
        this.availabilityStatus = availabilityStatus;
        this.rating = rating;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public UUID getCarId() {
        return carId;
    }

    public void setCarId(UUID carId) {
        this.carId = carId;
    }

    public String getLicenseNumber() {
        return licenseNumber;
    }

    public void setLicenseNumber(String licenseNumber) {
        this.licenseNumber = licenseNumber;
    }

    public String getAvailabilityStatus() {
        return availabilityStatus;
    }

    public void setAvailabilityStatus(String availabilityStatus) {
        this.availabilityStatus = availabilityStatus;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}