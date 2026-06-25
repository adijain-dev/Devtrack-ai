package com.example.demo.dto;

import com.example.demo.model.ApplicationStatus;
import lombok.Data;
import java.time.LocalDate;

@Data
public class InternshipResponse {

    private Long id;
    private String companyName;
    private String role;
    private String location;
    private String salary;
    private String jobLink;
    private ApplicationStatus status;
    private LocalDate appliedDate;
    private String notes;
}
