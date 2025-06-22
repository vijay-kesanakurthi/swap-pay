package models

import (
	"github.com/google/uuid"
	"time"
)

type Split struct {
	ID            uuid.UUID  `json:"id" gorm:"type:uuid;primaryKey;default:uuid_generate_v4()"`
	ExpenseID     uuid.UUID  `json:"expense_id"`
	WalletAddress string     `json:"wallet_address" gorm:"not null"`
	AmountOwed    float64    `json:"amount_owed" gorm:"type:decimal(18,8)"`
	IsPaid        bool       `json:"is_paid" gorm:"default:false"`
	PaymentTxHash *string    `json:"payment_tx_hash"`
	PaidAt        *time.Time `json:"paid_at"`
	CreatedAt     time.Time  `json:"created_at" gorm:"autoCreateTime"`
}
