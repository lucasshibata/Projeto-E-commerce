"use client"

import { useRouter } from "next/navigation";

export default function Home() {
    const router = useRouter();
    return (
        <div className="flex flex-col flex-1 items-center justify-center bg-zinc-100 font-sans">
            <main className="flex flex-1 w-[90%] flex-col items-center justify-center bg-white sm:items-start">
                <button onClick={()=>router.push("/register")}
                    className="text-black border-black rounded border-1">Ir para cadastro</button>
            </main>
        </div>
    );
}
