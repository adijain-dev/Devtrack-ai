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
public class InterviewRoundDto {
    private Long id;
    private int roundNumber;
    private String question;
    private String userAnswer;
    private String feedback;
    private LocalDateTime answeredAt;
}
