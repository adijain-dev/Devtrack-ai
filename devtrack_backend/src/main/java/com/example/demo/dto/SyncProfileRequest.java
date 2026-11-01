package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class SyncProfileRequest {
    @NotBlank
    private String platform; // "LEETCODE" or "CODEFORCES"

    @NotBlank
    private String username;

    private boolean importProblems = true;
}
