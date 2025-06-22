# Swap-Pay

> Split bills with friends in any token. Receive in your token of choice.

Split-Wise is a backend application that simplifies expense sharing. It allows users to create groups, log expenses, and settle up debts. What makes it unique is its integration with the Jupiter API, enabling users to pay their share of a bill using any Solana token, which is then automatically swapped to the bill creator's preferred token.


## 🛠️ How it works:
1.  One person creates a bill (e.g., rent for 180 USDC).
2.  Group members can see the expense.
3.  They can contribute their share using any Solana token they hold (like BONK, JUP, SOL, etc.).
4.  Each contribution is automatically swapped to the bill creator's preferred token (e.g., USDC) using the Jupiter API.
5.  The creator receives the payment in their chosen token, and the debt is marked as settled.

## ✨ Features
- **Group Management**: Create and manage expense groups with friends.
- **Expense Tracking**: Log shared expenses, specifying who paid and how much.
- **Flexible Payments**: Pay your share of expenses using any Solana token.
- **Automatic Swaps**: Leverages Jupiter API for seamless token-to-token swaps.
- **Settlement**: Tracks who owes whom and facilitates easy settlement.

## ⚙️ Tech Stack
- **Backend**: Go, Gin-Gonic
- **ORM**: GORM
- **Database**: PostgreSQL (designed for Supabase)
- **Crypto Integration**: Jupiter API for token swaps on Solana

## 🚀 Getting Started

### Prerequisites
- Go (version 1.18 or higher)
- A PostgreSQL database. You can get one from [Supabase](https://supabase.com/).

### Installation & Setup

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/your-username/split-wise.git
    cd split-wise
    ```

2.  **Install dependencies:**
    ```sh
    go mod tidy
    ```

3.  **Configure environment variables:**
    Create a `.env` file in the root of the project and add your database connection string:
    ```env
    DATABASE_URL="your_postgresql_connection_string"
    ```

4.  **Run the application:**
    ```sh
    go run main.go
    ```
    The server will start on `http://localhost:8080`.

## <caption>API Endpoints

The API provides endpoints for managing groups, expenses, and payments.

### Base URL
`http://localhost:8080/api/v1`

### Groups
- `POST /groups`: Create a new group.
- `GET /groups/:wallet_address`: Get all groups for a user.
- `POST /groups/:invite_code/join`: Join a group using an invite code.
- `GET /groups/members/:id`: Get all members of a group.

### Expenses
- `POST /expenses`: Create a new expense.
- `GET /expenses/:group_id`: Get all expenses for a group.
- `GET /expenses/details/:id`: Get details for a specific expense.

### Payments
- `POST /payments/quote`: Get a quote for a token swap.
- `POST /payments/swap-and-pay`: Execute the token swap and settle an expense.