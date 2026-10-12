package com.efrei.tp2.bmi.dto;

import java.util.Map;

public class BMIStatisticsResponse {

    private long totalRecords;
    private double averageBmi;
    private Map<String, Long> categoryCount;
    private Map<String, Double> categoryPercentage;

    public BMIStatisticsResponse() {
    }

    public BMIStatisticsResponse(long totalRecords, double averageBmi, Map<String, Long> categoryCount, Map<String, Double> categoryPercentage) {
        this.totalRecords = totalRecords;
        this.averageBmi = averageBmi;
        this.categoryCount = categoryCount;
        this.categoryPercentage = categoryPercentage;
    }

    public long getTotalRecords() {
        return totalRecords;
    }

    public void setTotalRecords(long totalRecords) {
        this.totalRecords = totalRecords;
    }

    public double getAverageBmi() {
        return averageBmi;
    }

    public void setAverageBmi(double averageBmi) {
        this.averageBmi = averageBmi;
    }

    public Map<String, Long> getCategoryCount() {
        return categoryCount;
    }

    public void setCategoryCount(Map<String, Long> categoryCount) {
        this.categoryCount = categoryCount;
    }

    public Map<String, Double> getCategoryPercentage() {
        return categoryPercentage;
    }

    public void setCategoryPercentage(Map<String, Double> categoryPercentage) {
        this.categoryPercentage = categoryPercentage;
    }
}
