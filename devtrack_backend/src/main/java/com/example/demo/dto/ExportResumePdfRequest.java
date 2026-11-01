package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExportResumePdfRequest {
    private String candidateName;
    private String candidateEmail;
    private String role;
    private String experience;
    private String bullets;
}
