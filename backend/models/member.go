package models

import (
	"github.com/google/uuid"
	"time"
)

type Member struct {
	ID            uuid.UUID `json:"id" gorm:"type:uuid;primaryKey;default:uuid_generate_v4()"`
	GroupID       uuid.UUID `json:"group_id"`
	WalletAddress string    `json:"wallet_address" gorm:"not null;index:idx_wallet_address"`
	Name          *string   `json:"name"`
	JoinedAt      time.Time `json:"joined_at" gorm:"autoCreateTime"`
}
