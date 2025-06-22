package routes

import (
	"backend/handlers"
	"backend/jupiter"
	"github.com/gin-gonic/gin"
)

func SetupRoutes() *gin.Engine {
	r := gin.Default()

	api := r.Group("/api/v1")
	{
		// Group routes
		api.POST("/groups", handlers.CreateGroup)
		api.GET("/groups/:wallet_address", handlers.GetGroupsByUserWallet)

		//api.GET("/groups/:invite_code", handlers.GetGroupByInviteCode)
		api.POST("/groups/:invite_code/join", handlers.JoinGroup)
		api.GET("/groups/members/:id", handlers.GetGroupMembers)

		// Expense routes
		api.POST("/expenses", handlers.CreateExpense)
		api.GET("/expenses/:group_id", handlers.GetGroupExpenses)
		api.GET("/expenses/details/:id", handlers.GetExpenseDetails)

		//// Update Payment
		api.POST("/payment/paid", handlers.UpdateSplitAsPaid)

		//// Payment routes
		api.POST("/payments/quote", jupiter.GetRequiredInputAmount)
		api.POST("/payments/swap-and-pay", jupiter.ExecuteSwap)
	}

	return r
}
