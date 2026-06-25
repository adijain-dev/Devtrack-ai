package com.example.demo.dto;

import com.example.demo.model.DsaCategory;
import com.example.demo.model.DsaDifficulty;
import lombok.Data;
import java.time.LocalDate;

@Data
public class DsaTopicResponse {

    private Long id;
    private String topicName;
    private DsaCategory category;
    private DsaDifficulty difficulty;
    private boolean solved;
    private LocalDate solvedDate;
    private String notes;
    private int practiceCount;
}
