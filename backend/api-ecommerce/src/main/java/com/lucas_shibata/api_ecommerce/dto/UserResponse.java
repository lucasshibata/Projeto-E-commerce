package com.lucas_shibata.api_ecommerce.dto;

import java.util.UUID;

public record UserResponse(UUID id, String name, String email, String role) {}
