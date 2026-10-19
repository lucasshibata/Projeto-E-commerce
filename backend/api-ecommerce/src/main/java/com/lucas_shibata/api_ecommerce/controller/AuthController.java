package com.lucas_shibata.api_ecommerce.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@RestController 
@RequestMapping("/auth")
public class AuthController {
    
    @PostMapping("/register")
    public String AuthRegister(@RequestBody String body){
        return "olá";
    }
}
