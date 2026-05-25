# Dishmade — Sistema de Gestão de Restaurantes

O **Dishmade** é um sistema de gestão para restaurantes, composto por uma API backend em .NET e um frontend em Flutter. O objetivo do sistema é centralizar os principais fluxos operacionais de um restaurante: gestão de cardápio, categorias, mesas, pedidos, cozinha/KDS, histórico de vendas e dashboard gerencial.

Este documento explica de forma técnica como o sistema funciona, quais módulos fazem parte da aplicação, como os fluxos se conectam e como a integração entre frontend e backend é realizada.

---

## Sumário

- [1. Visão geral](#1-visão-geral)
- [2. Arquitetura do sistema](#2-arquitetura-do-sistema)
- [3. Tecnologias utilizadas](#3-tecnologias-utilizadas)
- [4. Backend — Dishmade API](#4-backend--dishmade-api)
- [5. Frontend — Dishmade Flutter](#5-frontend--dishmade-flutter)
- [6. Módulos do sistema](#6-módulos-do-sistema)
- [7. Fluxo operacional principal](#7-fluxo-operacional-principal)
- [8. Fluxo de status dos pedidos](#8-fluxo-de-status-dos-pedidos)
- [9. Integração com a API](#9-integração-com-a-api)
- [10. Paginação, filtros e tratamento de erros](#10-paginação-filtros-e-tratamento-de-erros)
- [11. Estrutura de pastas do Flutter](#11-estrutura-de-pastas-do-flutter)
- [12. Como executar o projeto](#12-como-executar-o-projeto)
- [13. Roadmap técnico](#13-roadmap-técnico)

---

## 1. Visão geral

O Dishmade é uma aplicação para controle operacional e gerencial de restaurantes.

A aplicação permite:

- cadastrar e listar categorias do cardápio;
- cadastrar, editar, listar e remover pratos;
- cadastrar e gerenciar mesas;
- abrir pedidos vinculados a mesas livres;
- adicionar itens aos pedidos;
- acompanhar pedidos na cozinha/KDS;
- avançar o status dos pedidos;
- cancelar pedidos;
- consultar histórico de vendas;
- visualizar indicadores gerenciais no dashboard.

O sistema foi pensado para evoluir para um SaaS, permitindo futuramente autenticação, multi-tenancy, vínculo de usuários a restaurantes, permissões por perfil e atualizações em tempo real.

---

## 2. Arquitetura do sistema

A solução é dividida em duas partes principais:

```txt
Dishmade
├── Backend
│   └── Dishmade API (.NET)
│
└── Frontend
    └── Dishmade Flutter App
```

### Backend

O backend expõe uma API REST responsável pelas regras de negócio, persistência dos dados, validações e cálculo de totais.

A API centraliza regras como:

- impedir pedido em mesa ocupada;
- impedir item em pedido entregue ou cancelado;
- calcular total do pedido no backend;
- liberar mesa ao entregar ou cancelar pedido;
- considerar apenas pedidos entregues no histórico de vendas e dashboard.

### Frontend

O frontend em Flutter consome a API e disponibiliza uma interface visual para a operação do restaurante.

A aplicação Flutter segue uma arquitetura baseada em:

- **MVVM**;
- separação por features;
- Repository Pattern;
- Use Cases;
- DataSources;
- DTOs;
- entidades de domínio;
- Riverpod para estado e injeção de dependência;
- Dio para comunicação HTTP.

---

## 3. Tecnologias utilizadas

### Backend

- .NET 9
- ASP.NET Core
- Entity Framework Core
- SQL Server
- MediatR
- CQRS
- FluentValidation
- Swagger

### Frontend

- Flutter
- Dart
- Riverpod
- Dio
- GoRouter
- Flutter Dotenv
- Intl
- Cached Network Image
- FL Chart
- Material 3

---

## 4. Backend — Dishmade API

A API segue arquitetura em camadas:

```txt
dishmade-api
└── src
    ├── dishmade.api
    ├── dishmade.application
    ├── dishmade.domain
    └── dishmade.infra
```

### Responsabilidades das camadas

| Camada | Responsabilidade |
|---|---|
| `dishmade.api` | Controllers, middlewares, configuração HTTP, Swagger e entrada da aplicação. |
| `dishmade.application` | Casos de uso, CQRS, commands, queries, validações, contratos de repositório e paginação. |
| `dishmade.domain` | Entidades, enums e regras de negócio centrais. |
| `dishmade.infra` | Entity Framework Core, SQL Server, DbContext, mappings e repositórios. |

### URL base local

```txt
http://localhost:5280
```

### Swagger local

```txt
http://localhost:5280/swagger
```

Todos os endpoints usam o prefixo:

```txt
/api
```

---

## 5. Frontend — Dishmade Flutter

O frontend é organizado por features, mantendo cada módulo independente e com suas próprias camadas.

Fluxo de dependência usado no app:

```txt
Page / View
   ↓
ViewModel
   ↓
UseCase
   ↓
Repository Interface
   ↓
Repository Implementation
   ↓
Remote DataSource
   ↓
Dio
   ↓
Dishmade API
```

Essa organização melhora:

- manutenção;
- testabilidade;
- separação de responsabilidades;
- reaproveitamento de regras;
- evolução modular do sistema.

---

## 6. Módulos do sistema

### 6.1 Home

A Home centraliza o acesso aos principais módulos:

- Dashboard;
- Cardápio;
- Categorias;
- Mesas;
- Pedidos;
- Cozinha/KDS;
- Histórico de Vendas.

Ela funciona como ponto inicial da aplicação e facilita a navegação operacional.

---

### 6.2 Categorias

Categorias agrupam os pratos do cardápio.

Exemplos:

- Hambúrgueres;
- Bebidas;
- Sobremesas;
- Entradas.

Endpoints usados:

```http
GET  /api/categories
POST /api/categories
```

Principais funcionalidades no frontend:

- listar categorias;
- buscar por nome ou descrição;
- filtrar por ativas, inativas ou todas;
- criar nova categoria;
- usar categorias como filtro no módulo de pratos.

---

### 6.3 Pratos / Cardápio

Pratos representam os itens vendidos pelo restaurante.

Cada prato pertence a uma categoria e possui preço, descrição e disponibilidade.

Endpoints usados:

```http
GET    /api/dishes
GET    /api/dishes/{id}
POST   /api/dishes
PUT    /api/dishes/{id}
DELETE /api/dishes/{id}
```

Principais funcionalidades no frontend:

- listar pratos com paginação;
- buscar por nome ou descrição;
- filtrar por categoria;
- filtrar por disponibilidade;
- criar prato;
- editar prato;
- remover prato.

A remoção de prato no backend é feita via soft delete. Isso preserva o histórico de pedidos e vendas.

---

### 6.4 Mesas

Mesas representam os locais físicos onde os pedidos são abertos.

Endpoints usados:

```http
GET    /api/tables
GET    /api/tables/{id}
POST   /api/tables
PUT    /api/tables/{id}
DELETE /api/tables/{id}
PATCH  /api/tables/{id}/occupy
PATCH  /api/tables/{id}/release
```

Principais funcionalidades no frontend:

- listar mesas;
- filtrar por número;
- filtrar por livre ou ocupada;
- criar mesa;
- editar número da mesa;
- ocupar mesa manualmente;
- liberar mesa manualmente;
- remover mesa.

Regras importantes:

- uma mesa ocupada não pode ser removida;
- ao criar pedido para uma mesa, a API marca a mesa como ocupada;
- ao entregar ou cancelar pedido, a API libera a mesa.

---

### 6.5 Pedidos

Pedido é o fluxo central da aplicação.

Um pedido:

- pertence a uma mesa;
- possui um ou mais itens;
- possui status;
- calcula total com base nos itens;
- ocupa a mesa ao ser criado;
- libera a mesa ao ser entregue ou cancelado.

Endpoints usados:

```http
GET   /api/orders
GET   /api/orders/{id}
POST  /api/orders
POST  /api/orders/{id}/items
PATCH /api/orders/{id}/status
PATCH /api/orders/{id}/cancel
```

Principais funcionalidades no frontend:

- listar pedidos;
- filtrar por status;
- criar pedido selecionando mesa livre;
- adicionar itens ao pedido;
- atualizar status do pedido;
- cancelar pedido;
- atualizar o pedido após inclusão de item.

Após adicionar um item, o endpoint retorna `204 No Content`. Por isso, o frontend busca novamente o pedido com:

```http
GET /api/orders/{id}
```

Isso garante que o total exibido seja o total oficial calculado pelo backend.

---

### 6.6 Cozinha / KDS

A tela de cozinha, também chamada de KDS, é voltada para operação rápida dos pedidos.

Ela organiza os pedidos em colunas:

- Novos;
- Em preparo;
- Prontos.

Endpoints usados:

```http
GET   /api/orders?status=Created
GET   /api/orders?status=InPreparation
GET   /api/orders?status=Ready
PATCH /api/orders/{id}/status
```

Fluxo operacional:

```txt
Created -> InPreparation -> Ready -> Delivered
```

A tela permite avançar o pedido com um clique:

- `Created` para `InPreparation`;
- `InPreparation` para `Ready`;
- `Ready` para `Delivered`.

Quando o pedido é entregue, ele passa a entrar no histórico de vendas e no dashboard.

---

### 6.7 Histórico de Vendas

O histórico de vendas lista somente pedidos entregues.

Endpoint usado:

```http
GET /api/sales-history
```

Filtros disponíveis:

```http
GET /api/sales-history?startDate=2026-05-01&endDate=2026-05-31&pageNumber=1&pageSize=10
```

Principais funcionalidades no frontend:

- listar vendas entregues;
- filtrar por período;
- visualizar itens vendidos por pedido;
- visualizar mesa, total e data da venda;
- carregar mais registros via paginação.

Essa tela é útil para consulta operacional e auditoria simples de vendas.

---

### 6.8 Dashboard

O dashboard apresenta indicadores gerenciais com base em pedidos entregues.

Endpoint usado:

```http
GET /api/dashboard
```

Exemplo com filtro:

```http
GET /api/dashboard?startDate=2026-05-01&endDate=2026-05-31
```

Indicadores retornados:

| Campo | Descrição |
|---|---|
| `totalRevenue` | Faturamento total no período. |
| `totalOrders` | Quantidade de pedidos entregues. |
| `totalItemsSold` | Quantidade total de itens vendidos. |
| `averageTicket` | Faturamento dividido pela quantidade de pedidos. |
| `topDishes` | Top 5 pratos mais vendidos. |

Principais funcionalidades no frontend:

- filtrar dashboard por período;
- visualizar faturamento total;
- visualizar pedidos entregues;
- visualizar itens vendidos;
- visualizar ticket médio;
- visualizar ranking de pratos mais vendidos.

---

## 7. Fluxo operacional principal

O fluxo completo do restaurante segue a ordem abaixo:

```txt
1. Cadastrar categorias
2. Cadastrar pratos vinculados às categorias
3. Cadastrar mesas
4. Abrir pedido para uma mesa livre
5. Adicionar pratos ao pedido
6. Enviar pedido para preparo
7. Cozinha acompanha e atualiza status
8. Pedido fica pronto
9. Pedido é entregue
10. Mesa é liberada
11. Venda entra no histórico
12. Venda entra nos indicadores do dashboard
```

Fluxo resumido:

```txt
Categoria -> Prato -> Mesa -> Pedido -> Cozinha -> Entrega -> Venda -> Dashboard
```

---

## 8. Fluxo de status dos pedidos

O enum de status do pedido é enviado e recebido como string no JSON.

| Status | Descrição |
|---|---|
| `Created` | Pedido criado. |
| `InPreparation` | Pedido em preparo. |
| `Ready` | Pedido pronto. |
| `Delivered` | Pedido entregue. |
| `Canceled` | Pedido cancelado. |

Fluxo permitido:

```txt
Created -> InPreparation -> Ready -> Delivered
```

Cancelamento permitido:

```txt
Created       -> Canceled
InPreparation -> Canceled
Ready         -> Canceled
```

Restrições principais:

- pedido entregue não pode ser cancelado;
- pedido entregue não pode receber novos itens;
- pedido cancelado não pode receber novos itens;
- pedido só pode ir para `InPreparation` se estiver `Created`;
- pedido só pode ir para `Ready` se estiver `InPreparation`;
- pedido só pode ir para `Delivered` se estiver `Ready`.

---

## 9. Integração com a API

### URL base

A URL da API é configurada no arquivo `.env` do Flutter:

```env
API_BASE_URL=http://localhost:5280
```

Para Android Emulator:

```env
API_BASE_URL=http://10.0.2.2:5280
```

### Headers padrão

```http
Content-Type: application/json
Accept: application/json
```

### Cliente HTTP

O app utiliza `Dio` com `BaseOptions`:

```dart
Dio(
  BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ),
)
```

### Centralização de endpoints

Os endpoints são centralizados em:

```txt
lib/core/constants/api_endpoints.dart
```

Exemplo:

```dart
abstract final class ApiEndpoints {
  static const categories = '/api/categories';
  static const dishes = '/api/dishes';
  static const tables = '/api/tables';
  static const orders = '/api/orders';
  static const salesHistory = '/api/sales-history';
  static const dashboard = '/api/dashboard';

  static String dishById(String id) => '/api/dishes/$id';
  static String tableById(String id) => '/api/tables/$id';
  static String orderById(String id) => '/api/orders/$id';
  static String addOrderItem(String orderId) => '/api/orders/$orderId/items';
  static String updateOrderStatus(String orderId) => '/api/orders/$orderId/status';
  static String cancelOrder(String orderId) => '/api/orders/$orderId/cancel';
}
```

---

## 10. Paginação, filtros e tratamento de erros

### Paginação

As listagens principais retornam uma resposta paginada:

```json
{
  "items": [],
  "pageNumber": 1,
  "pageSize": 10,
  "totalCount": 25,
  "totalPages": 3,
  "hasPreviousPage": false,
  "hasNextPage": true
}
```

No Flutter, esse padrão é representado por um modelo genérico:

```txt
PaginatedResponse<T>
```

### Filtros

Os principais filtros usados são:

| Módulo | Filtros |
|---|---|
| Categorias | `search`, `isActive`, `pageNumber`, `pageSize` |
| Pratos | `search`, `categoryId`, `isAvailable`, `pageNumber`, `pageSize` |
| Mesas | `number`, `isOccupied`, `pageNumber`, `pageSize` |
| Pedidos | `status`, `tableId`, `startDate`, `endDate`, `pageNumber`, `pageSize` |
| Histórico | `startDate`, `endDate`, `pageNumber`, `pageSize` |
| Dashboard | `startDate`, `endDate` |

### Tratamento de erros

O backend pode retornar erros de validação, regra de negócio, recurso não encontrado ou erro interno.

Exemplo de erro de validação:

```json
{
  "statusCode": 400,
  "message": "Erro de validação.",
  "errors": [
    {
      "field": "Name",
      "message": "O nome do prato é obrigatório."
    }
  ]
}
```

No Flutter, erros de API são convertidos para uma exceção de aplicação, por exemplo:

```txt
ApiException
```

Essa exceção é tratada nos ViewModels para exibir mensagens amigáveis nas telas.

---

## 11. Estrutura de pastas do Flutter

Estrutura principal:

```txt
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   └── theme/
│
├── core/
│   ├── config/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── pagination/
│   ├── result/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── home/
│   ├── dashboard/
│   ├── categories/
│   ├── dishes/
│   ├── tables/
│   ├── orders/
│   ├── kitchen/
│   └── sales_history/
│
└── shared/
    ├── layout/
    └── widgets/
```

Estrutura padrão de uma feature:

```txt
feature/
├── data/
│   ├── datasources/
│   ├── dtos/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
└── presentation/
    ├── pages/
    ├── viewmodels/
    └── widgets/
```

---

## 12. Como executar o projeto

### 12.1 Executar backend

Entre na pasta do backend e rode a API:

```bash
dotnet run
```

A API deve ficar disponível em:

```txt
http://localhost:5280
```

Swagger:

```txt
http://localhost:5280/swagger
```

### 12.2 Executar frontend

Entre na pasta do frontend Flutter:

```bash
cd dishmade_front
```

Instale as dependências:

```bash
flutter pub get
```

Crie o arquivo `.env`:

```env
API_BASE_URL=http://localhost:5280
```

Para Android Emulator:

```env
API_BASE_URL=http://10.0.2.2:5280
```

Execute o app:

```bash
flutter run
```

---

## 13. Roadmap técnico

Possíveis evoluções futuras:

- autenticação com JWT;
- cadastro de restaurantes;
- vínculo de usuários a restaurantes;
- multi-tenancy;
- permissões por perfil, como administrador, atendente e cozinha;
- auditoria de alterações;
- fechamento de conta;
- controle de pagamentos;
- integração com impressora térmica;
- integração com tela de cozinha em tempo real;
- SignalR para atualização automática de pedidos;
- upload de imagens dos pratos;
- relatórios financeiros avançados;
- exportação de histórico em PDF ou Excel;

---

## Conclusão

O Dishmade organiza a operação de restaurantes em um fluxo simples e bem definido:

```txt
Cardápio -> Mesas -> Pedidos -> Cozinha -> Entrega -> Vendas -> Dashboard
```

A API concentra as regras de negócio e garante consistência dos dados. O frontend Flutter fornece uma interface moderna, responsiva e organizada por módulos, seguindo boas práticas de arquitetura, separação de responsabilidades e integração com serviços REST.
