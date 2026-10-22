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
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional 
    public UserResponse register(RegisterRequest request){
        String emailNormalizado = request.email().trim().toLowerCase();
        String passwordHash = passwordEncoder.encode(request.password().trim());
        UUID idRetornado = userRepository.insert(request.cpf().trim(), request.name().trim(), request.birthDate(), emailNormalizado, passwordHash);
        return new UserResponse(idRetornado, request.name().trim(), emailNormalizado, "customer");
    }
}
