package com.lucas_shibata.api_ecommerce.repository;

import java.time.LocalDate;
import java.util.UUID;

import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import lombok.RequiredArgsConstructor;

@Repository //Acesso a dados
@RequiredArgsConstructor 
public class UserRepository {
    private final JdbcClient jdbcClient;

    public UUID insert (String cpf, String name, LocalDate birthDate, String email, String passwordHash){
        return jdbcClient.sql("""
            INSERT INTO users (cpf, name, birth_date, email, password_hash)
            VALUES (:cpf, :name, :birthDate, :email, :passwordHash)
            RETURNING uuid_user
        """)
        .param("cpf", cpf)
        .param("name", name)
        .param("birthDate", birthDate)
        .param("email", email)
        .param("passwordHash", passwordHash)
        .query(UUID.class)
        .single();
    }
}
