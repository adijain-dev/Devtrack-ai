package com.example.demo.dto;

import com.example.demo.model.DsaCategory;
import com.example.demo.model.DsaDifficulty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalDate;

@Data
public class DsaTopicRequest {

    @NotBlank
    private String topicName;

    @NotNull
    private DsaCategory category;

    @NotNull
    private DsaDifficulty difficulty;

    private boolean solved;
    private LocalDate solvedDate;
    private LocalDate nextRevisionDate;
    private Integer revisionIntervalDays;
    private String platform;
    private String problemUrl;
    private String notes;
    private int practiceCount;
}
