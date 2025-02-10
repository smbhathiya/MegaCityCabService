package com.cabservice.megacitycabservice.model;

import java.util.UUID;

public class Customer {
    private UUID userId;
    private String address;
    private String contactNo;

    public Customer(UUID userId, String address, String contactNo) {
        this.userId = userId;
        this.address = address;
        this.contactNo = contactNo;
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
}
