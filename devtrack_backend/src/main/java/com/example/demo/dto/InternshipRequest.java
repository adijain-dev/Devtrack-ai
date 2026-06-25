package com.example.demo.dto;

import com.example.demo.model.ApplicationStatus;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import java.time.LocalDate;

@Data
public class InternshipRequest {

    @NotBlank
    private String companyName;

    @NotBlank
    private String role;

    private String location;
    private String salary;
    private String jobLink;

    private ApplicationStatus status;
    private LocalDate appliedDate;
    private String notes;
}
