const API_URL = process.env.NEXT_PUBLIC_API_URL;
if (!API_URL){
    throw new Error("NEXT_PUBLIC_API_URL não está definida. Crie o .env.local a partir do .env.example.");
}

export class ApiError extends Error{
    status:number;
    body:unknown;

    constructor(status: number, body: unknown, message?: string){
        super(message ?? `Erro ${status}`);
        this.name = "ApiError";
        this.status = status;
        this.body = body;
    }
}

export async function apiFetch<T>(path:string, options: RequestInit = {}): Promise<T> {
    const headers = new Headers(options.headers);
    if (options.body && !headers.has("Content-Type")){
        headers.set("Content-Type", "application/json");
    }

    //TODO JWT: headers.set("Authorization", `Bearer ${token}`) aqui

    let res:Response;
    try{
        res = await fetch(`${API_URL}${path}`,{
            ...options,
            headers
        });
    } catch{
        throw new ApiError(0, null, "Não foi possível conectar ao servidor");
    }

    let body: unknown = null;

    const text = await res.text();
    if(text === ""){
        body = null;
    } else{
        try{
            body = JSON.parse(text);
        } catch{
            body = text;
        }
    }
    
    if(!res.ok) throw new ApiError(res.status, body);
    return body as T;
}