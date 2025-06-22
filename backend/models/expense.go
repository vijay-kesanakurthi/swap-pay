package models

import (
	"github.com/google/uuid"
	"time"
)

type Expense struct {
	ID           uuid.UUID `json:"id" gorm:"type:uuid;primaryKey;default:uuid_generate_v4()"`
	GroupID      uuid.UUID `json:"group_id"`
	Title        string    `json:"title" gorm:"not null"`
	TotalAmount  float64   `json:"total_amount" gorm:"type:decimal(18,8)"`
	Currency     string    `json:"currency" gorm:"not null"`
	PaidByWallet string    `json:"paid_by_wallet" gorm:"not null"`
	CreatedAt    time.Time `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt    time.Time `json:"updated_at" gorm:"autoUpdateTime"`
	Splits       []Split   `json:"splits,omitempty" gorm:"foreignKey:ExpenseID"`
}
