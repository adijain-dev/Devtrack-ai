package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InterviewSessionResponse {
    private Long id;
    private String topic;
    private String difficulty;
    private LocalDateTime createdAt;
    private List<InterviewRoundDto> rounds;
}
