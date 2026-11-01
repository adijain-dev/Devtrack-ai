package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ResumeHistoryResponse {
    private Long id;
    private String role;
    private String experience;
    private String additionalContext;
    private String generatedBullets;
    private LocalDateTime createdAt;
}
