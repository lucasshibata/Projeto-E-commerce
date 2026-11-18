# Projeto E-commerce

Projeto pessoal de portfólio: e-commerce completo com cadastro de usuários, autenticação JWT, catálogo de produtos, carrinho, pedidos e pagamento. O objetivo é demonstrar domínio de arquitetura, segurança e CRUD. O repositório é público no GitHub, então **nunca commitar segredos** (senhas de banco, chave de assinatura do JWT, etc.).

## Como trabalhar neste projeto

- O dono do projeto está **aprendendo** (principalmente a estrutura e as boas práticas do Next.js). O código é escrito por ele.
- Por padrão, **não alterar arquivos do projeto**: orientar, explicar e revisar o que ele escreveu. Só editar um arquivo quando ele pedir explicitamente aquele arquivo (o `CLAUDE.md` foi um desses casos).
- Ao revisar, apontar o que está certo, o que está errado e por quê, e indicar o próximo passo, sem entregar o código pronto quando ele só pediu orientação.
- Responder em português.

## Estrutura do repositório

```
backend/api-ecommerce/   API Spring Boot (Maven, Java 21)
database/                compose.yml + Dockerfile do PostgreSQL
frontend/                Next.js (App Router, TypeScript, Tailwind v4)
README.md                requisitos de negócio e anotações
UML_database_modeling.png
```

## Backend (Spring Boot 4.1.1)

- Dependências: Security, Validation, WebMVC, JDBC (`JdbcClient`, sem JPA), Flyway (+ PostgreSQL), Lombok, Actuator, DevTools e Docker Compose.
- Camadas em `com.lucas_shibata.api_ecommerce`: `controller` → `service` → `repository`, mais `dto` (records Java) e `config`.
- Banco: PostgreSQL via Docker (`database/compose.yml`), exposto na porta **5433**. Precisa estar de pé para o backend subir. Para limpar o banco e refazer a migration: `docker compose -f database/compose.yml down -v`.
- Schema: migrations Flyway em `src/main/resources/db/migration` (hoje só `V1__criar_tabelas_iniciais.sql`). Chaves primárias são UUID, com nomes como `uuid_user`. Exclusão de usuários, lojas, produtos e endereços é **soft delete** (`deleted_at`), para preservar histórico.
- Regras já garantidas no banco: `cpf` com exatamente 11 dígitos, `email` sempre em minúsculas (`CHECK (email = LOWER(email))`) e único.
- Rodar: `./mvnw spring-boot:run` dentro de `backend/api-ecommerce`.
- Segurança (`SecurityConfig`): stateless, CSRF desabilitado, `/api/v1/auth/**` e `/error` públicos, o resto exige autenticação. CORS liberado para a origem em `app.cors.allowed-origins` (padrão `http://localhost:3000`), com os headers `Authorization` e `Content-Type`. Senhas com BCrypt.
- Os demais controllers (carrinho, pedidos, produtos, etc.) existem como esqueleto, ainda sem implementação.

### API pronta

`POST /api/v1/auth/register` → **201** com `{ id, name, email, role }`.

| Campo | Regra |
|---|---|
| `cpf` | string, exatamente 11 dígitos, sem máscara |
| `name` | obrigatório, até 120 caracteres |
| `birthDate` | data no passado, `"YYYY-MM-DD"` |
| `email` | e-mail válido (o serviço normaliza para minúsculas) |
| `password` | de 8 a 72 caracteres |

Pontos em aberto: ainda não foi verificado o formato dos erros de validação (400) nem de e-mail/CPF duplicado, e não há login nem geração de JWT.

## Frontend (Next.js 16, React 19)

- **Atenção:** `frontend/AGENTS.md` avisa que esta versão do Next tem mudanças em relação ao que se conhece. Consultar `node_modules/next/dist/docs/` e a documentação oficial antes de assumir convenções.
- Rodar: `npm run dev` dentro de `frontend` (porta 3000). Lint: `npm run lint`.
- Alias de import: `@/*` aponta para a raiz de `frontend/`.
- Organização:
  - `app/`: apenas rotas e layouts. O cadastro fica em `app/(auth)/register/page.tsx` (rota `/register`; o route group `(auth)` não entra na URL).
  - `components/`: componentes de UI (ex.: `components/auth/RegisterForm.tsx`).
  - `services/`: chamadas à API, uma função por endpoint (ex.: `services/auth.ts` com `registerUser`). Export nomeado.
  - `lib/`: infraestrutura. `lib/api.ts` tem `apiFetch<T>` e a classe `ApiError`; `lib/validators.ts` é para validações.
  - `types/`: tipos que espelham os DTOs do backend (ex.: `types/auth.ts`).
- Variáveis de ambiente: `NEXT_PUBLIC_API_URL` (ex.: `http://localhost:8080`). O valor real fica em `.env.local` (ignorado pelo git) e `frontend/.env.example` é versionado como modelo.

### Decisões tomadas

- Chamadas à API feitas **no cliente, com `fetch`** (`onSubmit`), e não com Server Actions/`useActionState`.
- `apiFetch` é o único ponto de acesso HTTP. Ele monta os headers, converte falhas de rede em `ApiError(0, ...)`, lê o corpo com segurança (vazio, JSON ou texto) e lança `ApiError(status, body)` quando `!res.ok`. O formulário deve tratar erros com `err instanceof ApiError`.
- Padrão de código: funções para lógica, componentes e services; classe só onde `instanceof` exige (erros).
- **Autenticação JWT (planejada):** o ponto de extensão está marcado com `TODO JWT` em `apiFetch`. A decisão de onde guardar o token (`localStorage` ou cookie `httpOnly` com `credentials: "include"` e `allowCredentials` no CORS) ainda não foi tomada.

## Requisitos de negócio (resumo do README)

- Qualquer pessoa vê o catálogo; para adicionar ao carrinho é preciso ter conta, e só então fechar o carrinho e pagar.
- Um usuário pode cadastrar sua loja como parceiro e seus produtos, com telas de controle de estoque e de vendas.
- Existe uma conta administradora que vê todos os usuários e pode cancelar a atividade deles, apenas com soft delete.
- `orders.status` e `payments.status` representam o mesmo fato ("foi pago?"), por isso o pagamento deve ser feito dentro de **uma transação**.

## Stack planejada

Next.js, Contexts, Java, Spring Boot, Spring Security, JUnit, JWT, PostgreSQL, Miro, Trello, Docker e Jenkins.
