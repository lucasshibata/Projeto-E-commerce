package com.lucas_shibata.api_ecommerce.dto;

import java.time.LocalDate;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
    @NotBlank @Pattern(regexp = "\\d{11}") String cpf,
    @NotBlank @Size(max = 120) String name,
    @NotNull @Past LocalDate birthDate,
    @NotBlank @Email String email,
    @NotBlank @Size(min = 8, max = 72) String password
) {}
