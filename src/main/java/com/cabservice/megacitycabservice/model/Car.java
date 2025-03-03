package com.cabservice.megacitycabservice.model;

import java.util.UUID;

public class Car {
    private UUID id;
    private String plateNumber;
    private String model;
    private String brand;
    private int year;
    private String color;
    private int capacity;
    private String status;
    private String createdAt;
    private String updatedAt;
    private int bookings;

    public Car(UUID id, String brand, String model, String plateNumber, int capacity) {
        this.id = id;
        this.brand = brand;
        this.model = model;
        this.plateNumber = plateNumber;
        this.capacity = capacity;
    }

    public Car(UUID id, String plateNumber, String model, String brand, int year, String color, int capacity, String status, String createdAt, String updatedAt) {
        this.id = id;
        this.plateNumber = plateNumber;
        this.model = model;
        this.brand = brand;
        this.year = year;
        this.color = color;
        this.capacity = capacity;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Car() {

    }

    public Car(String plateNumber, int bookings) {
        this.plateNumber = plateNumber;
        this.bookings = bookings;
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getPlateNumber() {
        return plateNumber;
    }

    public void setPlateNumber(String plateNumber) {
        this.plateNumber = plateNumber;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public int getBookings() {
        return bookings;
    }

    public void setBookings(int bookings) {
        this.bookings = bookings;
    }
}