package handlers

import (
	"backend/config"
	"backend/models"
	"errors"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
	"math/big"
	"net/http"

	"time"
)

type CreateExpenseRequest struct {
	GroupID      string  `json:"group_id" binding:"required"`
	Title        string  `json:"title" binding:"required"`
	TotalAmount  float64 `json:"total_amount" binding:"required"`
	Currency     string  `json:"currency" binding:"required"`
	PaidByWallet string  `json:"paid_by_wallet" binding:"required"`
}

func CreateExpense(c *gin.Context) {
	var req CreateExpenseRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	groupID, err := uuid.Parse(req.GroupID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid group ID"})
		return
	}

	db := config.GetDB()

	// Get group members
	var members []models.Member
	if err := db.Where("group_id = ?", groupID).Find(&members).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get group members"})
		return
	}

	if len(members) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No members in group"})
		return
	}

	tx := db.Begin()

	// Create expense
	expense := models.Expense{
		GroupID:      groupID,
		Title:        req.Title,
		TotalAmount:  req.TotalAmount,
		Currency:     req.Currency,
		PaidByWallet: req.PaidByWallet,
	}

	if err := tx.Create(&expense).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create expense"})
		return
	}

	// Calculate equal splits
	splitAmount := new(big.Float).Quo(big.NewFloat(req.TotalAmount), big.NewFloat(float64(len(members))))

	var splits []models.Split
	for i, member := range members {
		amount := splitAmount

		// Handle rounding - last person gets remainder
		if i == len(members)-1 {
			totalSplit := new(big.Float).Mul(splitAmount, big.NewFloat(float64(len(members)-1)))
			amount = new(big.Float).Sub(
				big.NewFloat(req.TotalAmount),
				totalSplit,
			)
		}

		splitAmount, _ := amount.Float64()

		split := models.Split{
			ExpenseID:     expense.ID,
			WalletAddress: member.WalletAddress,
			AmountOwed:    splitAmount,
		}

		// If paid by this member, mark as paid
		if member.WalletAddress == req.PaidByWallet {
			split.IsPaid = true
		}

		splits = append(splits, split)
	}

	if err := tx.Create(&splits).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create splits"})
		return
	}

	tx.Commit()

	// Update settlements
	//go services.UpdateGroupSettlements(groupID)

	expense.Splits = splits
	c.JSON(http.StatusCreated, expense)
}

func GetGroupExpenses(c *gin.Context) {
	groupID := c.Param("group_id")

	db := config.GetDB()
	var expenses []models.Expense

	if err := db.Where("group_id = ?", groupID).
		Preload("Splits").
		Order("created_at DESC").
		Find(&expenses).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get expenses"})
		return
	}

	c.JSON(http.StatusOK, expenses)
}

func GetExpenseDetails(c *gin.Context) {
	id := c.Param("id")

	db := config.GetDB()

	var expense models.Expense

	if err := db.Where("id = ?", id).Preload("Splits").Find(&expense).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get expense"})
	}

	c.JSON(http.StatusOK, expense)

}

type UpdateSplitRequest struct {
	ExpenseID     uuid.UUID `json:"expense_id" binding:"required"`
	WalletAddress string    `json:"wallet_address" binding:"required"`
	PaymentTxHash string    `json:"payment_tx_hash" binding:"required"`
}

// UpdateSplitResponse represents the response after updating a split
type UpdateSplitResponse struct {
	Success bool          `json:"success"`
	Message string        `json:"message"`
	Data    *models.Split `json:"data,omitempty"`
	Error   string        `json:"error,omitempty"`
}

// UpdateSplitAsPaid updates a split to mark it as paid
func UpdateSplitAsPaid(c *gin.Context) {
	var req UpdateSplitRequest

	db := config.GetDB()

	// Bind JSON request to struct
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, UpdateSplitResponse{
			Success: false,
			Error:   "Invalid request payload: " + err.Error(),
		})
		return
	}

	// Validate expense exists
	var expense models.Expense
	if err := db.First(&expense, "id = ?", req.ExpenseID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, UpdateSplitResponse{
				Success: false,
				Error:   "Expense not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, UpdateSplitResponse{
			Success: false,
			Error:   "Database error: " + err.Error(),
		})
		return
	}

	// Find and update the split
	var split models.Split
	result := db.Where("expense_id = ? AND wallet_address = ?", req.ExpenseID, req.WalletAddress).First(&split)

	if result.Error != nil {
		if result.Error == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, UpdateSplitResponse{
				Success: false,
				Error:   "Split not found for the given expense and wallet address",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, UpdateSplitResponse{
			Success: false,
			Error:   "Database error: " + result.Error.Error(),
		})
		return
	}

	// Check if split is already paid
	if split.IsPaid {
		c.JSON(http.StatusBadRequest, UpdateSplitResponse{
			Success: false,
			Error:   "Split is already marked as paid",
		})
		return
	}

	// Update split as paid
	now := time.Now()
	updateData := map[string]interface{}{
		"is_paid":         true,
		"payment_tx_hash": req.PaymentTxHash,
		"paid_at":         &now,
	}

	if err := db.Model(&split).Updates(updateData).Error; err != nil {
		c.JSON(http.StatusInternalServerError, UpdateSplitResponse{
			Success: false,
			Error:   "Failed to update split: " + err.Error(),
		})
		return
	}

	// Fetch updated split to return in response
	if err := db.First(&split, split.ID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, UpdateSplitResponse{
			Success: false,
			Error:   "Failed to fetch updated split: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, UpdateSplitResponse{
		Success: true,
		Message: "Split updated successfully as paid",
		Data:    &split,
	})
}
