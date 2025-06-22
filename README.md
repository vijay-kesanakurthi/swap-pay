# 🔁 SwapPay

> _Split bills with friends using any Solana token — get paid in the token you prefer._

**SwapPay** is a Solana bill-splitting mobile dapp  powered by the **Jupiter Aggregator**. It lets users split group expenses and settle bills using any SPL token — BONK, SOL, JUP, USDC, and more — with automatic swaps handled via Jupiter to ensure that the recipient receives exactly what they expect.

This project was built as part of the **Namaste Jupiverse Hackathon**, hosted in Hyderabad.

---

## 🧩 Problem

Traditional expense-splitting apps like Splitwise rely on users transacting in a shared currency. In Web3, this model breaks down:

- Users hold different SPL tokens (SOL, BONK, JUP, USDC, etc.)
- Settling expenses requires manual swaps across wallets and DEXs
- Gas fees, slippage, and UX complexity make it unfeasible for everyday use

---

## 💡 Solution

**SwapPay** abstracts all of this complexity:

> “Each user pays with the token they hold. The receiver gets the token they want.”

Using Jupiter’s liquidity aggregation engine, SwapPay automatically swaps tokens under the hood to ensure fair, efficient, and transparent settlement — without requiring users to manually trade tokens.

---


## 🌟 Key Features

- 👥 **Group Management**: Create or join groups with a QR or invite code.
- 💸 **Multi-Token Payments**: Pay your share of a bill using *any SPL token* (BONK, JUP, SOL, USDC).
- 🔄 **Auto Swap Engine**: Uses Jupiter API to swap contributions into recipient’s preferred token.
- 🧾 **Real-Time Settlement**: Track who paid and view transaction history.
- 🔐 **Phantom Wallet Integration**: Authenticate and sign transactions securely.
- 📱 **Mobile-First Experience**: Built in Flutter .


## 📷 Screenshots

<div align="center">

<table>
  <tr>
    <td align="center"><strong>🔐 Wallet Connect</strong></td>
    <td align="center"><strong>🏠 Groups Screen</strong></td>
    <td align="center"><strong>➕ Create Group</strong></td>
  </tr>
  <tr>
    <td><img src="mobile-app/screenshots/wallet_connect.png" width="200" /></td>
    <td><img src="mobile-app/screenshots/groups_screen.png" width="200" /></td>
    <td><img src="mobile-app/screenshots/create_group.png" width="200" /></td>
  </tr>
  <tr>
    <td align="center"><strong>📨 Invite to Group</strong></td>
    <td align="center"><strong>📋 Expenses Screen</strong></td>
    <td align="center"><strong>✍️ Create Expenses</strong></td>
  </tr>
  <tr>
    <td><img src="mobile-app/screenshots/invite_group.png" width="200" /></td>
    <td><img src="mobile-app/screenshots/expenses_screen.png" width="200" /></td>
    <td><img src="mobile-app/screenshots/create_expenses.png" width="200" /></td>
  </tr>
  <tr>
    <td align="center" ><strong>💸 Pay Expense</strong></td>
    <td align="center" ><strong>✅ Settled Expense</strong></td>
    <td align="center" ><strong>👤 My Profile</strong></td>
  </tr>
  <tr>
    <td  align="center"><img src="mobile-app/screenshots/pay_expense.png" width="200" /></td>
    <td  align="center"><img src="mobile-app/screenshots/settled_expense.png" width="200" /></td>
    <td  align="center"><img src="mobile-app/screenshots/my_profile.png" width="200" /></td>
  </tr>
</table>

</div>

## 🧱 Tech Stack

| Layer          | Technology                      |
|----------------|----------------------------------|
| 🖼 Frontend     | Flutter + GetX (Dart)            |
| 🔧 Backend      | Go + Gin                        |
| 🔗 Blockchain   | Solana                          |
| 💱 Swap Engine  | Jupiter Aggregator APIs         |
| 🧠 Wallets      | Phantom Wallet (mobile deep link)|
| 🗄️ Storage      | PostgreSQL (via Supabase)        |

---

## 🚀 Getting Started

To run the full SwapPay app, you'll need both the Flutter frontend and the Go backend running.

### 📱 mobile-app (Flutter)

Follow the setup guide here:  
🔗 [`Flutter mobile setup`](./mobile-app/README.md)

### 🖥 backend (Go)

Follow the setup guide here:  
🔗 [`Go backend setup `](./backend/README.md)


---




> 🛠 Built at **Namaste Jupiverse Hackathon – Hyderabad**  
> ⚡ Powered by **Jupiter Exchange** + **Solana**