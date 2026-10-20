package com.lucas_shibata.api_ecommerce.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration //diz ao Spring que a classe define beans
@EnableWebSecurity //ativa a configuração de segurança web customizada
public class SecurityConfig {
    @Bean 
    SecurityFilterChain filterChain(HttpSecurity http) throws Exception{ //regras http
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(s-> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/v1/auth/**").permitAll()
                .anyRequest().authenticated()
            );
        return http.build();
    }

    @Bean
    PasswordEncoder passwordEncoder(){
        return new BCryptPasswordEncoder(); //bean para gerar e comparar o hash BCrypt
    }
}
