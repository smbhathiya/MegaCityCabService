package com.cabservice.megacitycabservice.model;

import java.util.UUID;

public class Customer {
    private UUID id;
    private UUID userId;
    private String address;
    private String contactNo;
    private String createdAt;
    private String updatedAt;

    // Constructors
    public Customer(Object o, String address, String contactNo) {}

    public Customer(UUID id, UUID userId, String address, String contactNo, String createdAt, String updatedAt) {
        this.id = id;
        this.userId = userId;
        this.address = address;
        this.contactNo = contactNo;
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

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getContactNo() {
        return contactNo;
    }

    public void setContactNo(String contactNo) {
        this.contactNo = contactNo;
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