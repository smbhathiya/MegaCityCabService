package com.cabservice.megacitycabservice.model;

import java.math.BigDecimal;
import java.util.UUID;

public class Booking {
    private UUID id;
    private String bookingNumber;
    private UUID customerId;
    private UUID driverId;
    private UUID carId;
    private String pickupLocation;
    private String dropoffLocation;
    private BigDecimal distance;
    private int duration;
    private String bookingStatus;
    private BigDecimal fareEstimate;
    private BigDecimal totalFare;
    private String paymentStatus;
    private String hireDate;
    private String createdAt;
    private String updatedAt;

    // Constructors
    public Booking() {
    }

    public Booking(UUID id, String bookingNumber, UUID customerId, UUID driverId, UUID carId, String pickupLocation, String dropoffLocation, BigDecimal distance, int duration, String bookingStatus, BigDecimal fareEstimate, BigDecimal totalFare, String paymentStatus, String hireDate, String createdAt, String updatedAt) {
        this.id = id;
        this.bookingNumber = bookingNumber;
        this.customerId = customerId;
        this.driverId = driverId;
        this.carId = carId;
        this.pickupLocation = pickupLocation;
        this.dropoffLocation = dropoffLocation;
        this.distance = distance;
        this.duration = duration;
        this.bookingStatus = bookingStatus;
        this.fareEstimate = fareEstimate;
        this.totalFare = totalFare;
        this.paymentStatus = paymentStatus;
        this.hireDate = hireDate;
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

    public String getBookingNumber() {
        return bookingNumber;
    }

    public void setBookingNumber(String bookingNumber) {
        this.bookingNumber = bookingNumber;
    }

    public UUID getCustomerId() {
        return customerId;
    }

    public void setCustomerId(UUID customerId) {
        this.customerId = customerId;
    }

    public UUID getDriverId() {
        return driverId;
    }

    public void setDriverId(UUID driverId) {
        this.driverId = driverId;
    }

    public UUID getCarId() {
        return carId;
    }

    public void setCarId(UUID carId) {
        this.carId = carId;
    }

    public String getPickupLocation() {
        return pickupLocation;
    }

    public void setPickupLocation(String pickupLocation) {
        this.pickupLocation = pickupLocation;
    }

    public String getDropoffLocation() {
        return dropoffLocation;
    }

    public void setDropoffLocation(String dropoffLocation) {
        this.dropoffLocation = dropoffLocation;
    }

    public BigDecimal getDistance() {
        return distance;
    }

    public void setDistance(BigDecimal distance) {
        this.distance = distance;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public String getBookingStatus() {
        return bookingStatus;
    }

    public void setBookingStatus(String bookingStatus) {
        this.bookingStatus = bookingStatus;
    }

    public BigDecimal getFareEstimate() {
        return fareEstimate;
    }

    public void setFareEstimate(BigDecimal fareEstimate) {
        this.fareEstimate = fareEstimate;
    }

    public BigDecimal getTotalFare() {
        return totalFare;
    }

    public void setTotalFare(BigDecimal totalFare) {
        this.totalFare = totalFare;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getHireDate() {
        return hireDate;
    }

    public void setHireDate(String hireDate) {
        this.hireDate = hireDate;
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
}