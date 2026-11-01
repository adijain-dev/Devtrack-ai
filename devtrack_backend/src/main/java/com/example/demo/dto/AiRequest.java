package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AiRequest {

    @NotBlank
    private String role; // e.g. "SDE Intern at Google"

    @NotBlank
    private String experience; // e.g. "Worked on REST APIs and React dashboards"

    private String additionalContext; // optional extra context
}
