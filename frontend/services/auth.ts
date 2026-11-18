import { apiFetch } from "@/lib/api";
import type { RegisterRequest, UserResponse } from "@/types/auth";

export function registerUser(data: RegisterRequest): Promise<UserResponse>{
    return apiFetch<UserResponse>("/api/v1/auth/register",{
        method: "POST",
        body: JSON.stringify(data)
    })
}