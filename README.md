O objetivo desse projeto é desenvolver uma API completa para um e-commerce com cadastro de usuários, autenticação JWT, catálogo de produtos, carrinho de compras, pedidos e integração com banco de dados. É um projeto para demonstrar domínio de arquitetura, segurança e CRUD.

Tecnologias que vão ser usadas: Next.js, Contextos, Java, Spring Boot, Spring Security, JUnit, JWT, PostgreSQL, Miro, Trello, Docker e Jenkins.

Banco de dados vai rodar via Docker e vai ser um banco Postgres e ele precisa estar inicializado para rodar o backend.

O usuário vai poder entrar na aplicação e olhar o catálogo de produtos vendidos, mas para poder adicionar algo no carrinho ele vai precisar criar uma conta primeiro, com isso ele vai poder fechar o carrinho e ir para a sessão de pagamento.

Ainda na parte de cadastro, a pessoa pode se cadastrar a loja dele como parceiro do e-commerce e cadastrar os produtos a serem vendidos, vai ter na visão de parceiro tela de controle de estoque e de vendas realizadas.

Para a parte de administração, irá ter uma conta mestra que vai ter uma tela onde ele pode ver todos os usuários e cancelar a atividade deles, porém isso só vai dar um soft delete para preservar histórico.

o sistema deve garantir também o email minúsculo no banco


Sobre orders.status x payments.status
O problema

O mesmo fato do mundo real aparece em dois lugares: “esse pedido foi pago?”.

payments.status = 'approved' diz que o pagamento foi aprovado.
orders.status = 'paid' também diz que o pedido foi pago.

por isso a aplicação deve realizar o pagamento com uma transação


docker compose -f database/compose.yml down -v (para limpar migration)