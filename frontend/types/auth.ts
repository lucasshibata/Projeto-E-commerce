export type RegisterRequest = {
    cpf: string;
    name: string;
    birthDate: string;
    email: string;
    password: string;
}

export type UserResponse = {
    id: string;
    name: string;
    email: string;
    role: "customer"|"seller"|"admin";
}