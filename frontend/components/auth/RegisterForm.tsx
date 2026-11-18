"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { registerUser } from "@/services/auth"
import { ApiError } from "@/lib/api"
import type { RegisterRequest } from "@/types/auth"

export default function RegisterForm() {
    const router = useRouter();
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [error, setError] = useState <string|null>(null);

    async function handleSubmit(e: React.SubmitEvent<HTMLFormElement>) {
        e.preventDefault();
        setError(null);
        setIsSubmitting(true);
        const form = new FormData(e.currentTarget);
        const cpf = String(form.get("cpf"));
        const name = String(form.get("name"));
        const birthDate = String(form.get("birthDate"));
        const email = String(form.get("email"));
        const password = String(form.get("password"));

        const data:RegisterRequest = {
            "cpf":cpf.trim(),
            "name": name,
            "birthDate": birthDate,
            "email": email,
            "password": password,
        }

        try{
            await registerUser(data);
            router.push("/")
        }catch (err){
            if (err instanceof ApiError){
                if(err.status === 0){
                    setError("Não foi possível conectar ao servidor!")
                } else if (err.status === 400){
                    setError("Verifique os dados informados!")
                } else{
                    setError("Não foi possível concluir o cadastro!")
                }
            }else{
                setError("Erro inesperado!")
            }
        }finally{
            setIsSubmitting(false)
        }
    }

    return(
        <>
            <form onSubmit={handleSubmit}>
                <label htmlFor="cpf">CPF</label>
                <input id="cpf" type="text" name="cpf" inputMode="numeric" maxLength={14} required/>
                <label htmlFor="name">Nome</label>
                <input id="name" type="text" name="name" required/>
                <label htmlFor="birthDate">Data de Nascimento</label>
                <input id="birthDate" type="date" name="birthDate"  required/>
                <label htmlFor="email">Email</label>
                <input id="email" type="email" name="email" required/>
                <label htmlFor="password">Senha</label>
                <input id="password" type="password" name="password" minLength={8} required/>
                {error && <p role="alert">{error}</p>}
                <button type="submit" disabled={isSubmitting}>
                    {isSubmitting ? "Cadastrando...":"Cadastrar"}
                </button>
            </form>
        </>
    )
}