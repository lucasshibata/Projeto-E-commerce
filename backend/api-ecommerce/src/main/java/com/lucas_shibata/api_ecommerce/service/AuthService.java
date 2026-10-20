package com.lucas_shibata.api_ecommerce.service;

import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.lucas_shibata.api_ecommerce.dto.RegisterRequest;
import com.lucas_shibata.api_ecommerce.dto.UserResponse;
import com.lucas_shibata.api_ecommerce.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service 
@RequiredArgsConstructor 
public class AuthService {
    private final UserRepository UserRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional 
    public UserResponse register(RegisterRequest request){
        return new UserResponse(UUID.randomUUID(), request.name(), request.email(), "customer");
    }
}
