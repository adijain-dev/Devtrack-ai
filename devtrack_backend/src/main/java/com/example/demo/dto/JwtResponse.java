package com.example.demo.dto;

import lombok.Data;

@Data
public class JwtResponse {
    private String token;
    private String type = "Bearer";
    private Long id;
    private String name;
    private String email;

    public JwtResponse(String accessToken, Long id, String name, String email) {
        this.token = accessToken;
        this.id = id;
        this.name = name;
        this.email = email;
    }
}
