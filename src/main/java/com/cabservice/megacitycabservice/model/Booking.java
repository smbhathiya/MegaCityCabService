package com.cabservice.megacitycabservice.model;

import java.sql.Timestamp;
import java.util.Date;
import java.util.UUID;

public class Booking {
    private UUID id;
    private String bookingNumber;
    private UUID customerId;
    private UUID driverId;
    private UUID carId;
    private String pickupLocation;
    private String dropoffLocation;
    private double distance;
    private int duration;
    private double fareEstimate;
    private double totalFare;
    private String hireDate;
    private String bookingStatus;
    private String paymentStatus;
    private Date createdAt;
    private Date updatedAt;
    private String hireTime;
    private Car carDetails;
    private Timestamp paymentDate;
    private String customerName;
    private String customerContact;

    public Booking(UUID id, String bookingNumber, UUID customerId, UUID driverId, UUID carId, String pickupLocation, String dropoffLocation, double distance, String bookingStatus, double totalFare, String paymentStatus, String hireDate, String hireTime) {
        this.id = id;
        this.bookingNumber = bookingNumber;
        this.customerId = customerId;
        this.driverId = driverId;
        this.carId = carId;
        this.pickupLocation = pickupLocation;
        this.dropoffLocation = dropoffLocation;
        this.distance = distance;
        this.bookingStatus = bookingStatus;
        this.totalFare = totalFare;
        this.paymentStatus = paymentStatus;
        this.hireDate = hireDate;
        this.hireTime = hireTime;
    }

    public Booking(String bookingNumber, String hireDate, String bookingStatus) {
        this.bookingNumber = bookingNumber;
        this.hireDate = hireDate;
        this.bookingStatus = bookingStatus;
    }

    public Booking() {}

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getBookingNumber() { return bookingNumber; }
    public void setBookingNumber(String bookingNumber) { this.bookingNumber = bookingNumber; }
    public UUID getCustomerId() { return customerId; }
    public void setCustomerId(UUID customerId) { this.customerId = customerId; }
    public UUID getDriverId() { return driverId; }
    public void setDriverId(UUID driverId) { this.driverId = driverId; }
    public UUID getCarId() { return carId; }
    public void setCarId(UUID carId) { this.carId = carId; }
    public String getPickupLocation() { return pickupLocation; }
    public void setPickupLocation(String pickupLocation) { this.pickupLocation = pickupLocation; }
    public String getDropoffLocation() { return dropoffLocation; }
    public void setDropOffLocation(String dropoffLocation) { this.dropoffLocation = dropoffLocation; }
    public double getDistance() { return distance; }
    public void setDistance(double distance) { this.distance = distance; }
    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }
    public double getFareEstimate() { return fareEstimate; }
    public void setFareEstimate(double fareEstimate) { this.fareEstimate = fareEstimate; }
    public double getTotalFare() { return totalFare; }
    public void setTotalFare(double totalFare) { this.totalFare = totalFare; }
    public String getHireDate() { return hireDate; }
    public void setHireDate(String hireDate) { this.hireDate = hireDate; }
    public String getBookingStatus() { return bookingStatus; }
    public void setBookingStatus(String bookingStatus) { this.bookingStatus = bookingStatus; }
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
    public String getHireTime() { return hireTime; }
    public void setHireTime(String hireTime) { this.hireTime = hireTime; }
    public Car getCarDetails() { return carDetails; }
    public void setCarDetails(Car carDetails) { this.carDetails = carDetails; }
    public void setPaymentDate(Timestamp paymentDate) { this.paymentDate = paymentDate; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getCustomerContact() { return customerContact; }
    public void setCustomerContact(String customerContact) { this.customerContact = customerContact; }
}