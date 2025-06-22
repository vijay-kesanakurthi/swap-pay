package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
	"time"
)

type Group struct {
	ID         uuid.UUID `json:"id" gorm:"type:uuid;primaryKey;default:uuid_generate_v4()"`
	Name       string    `json:"name" gorm:"not null"`
	InviteCode string    `json:"invite_code" gorm:"unique;not null"`
	CreatedAt  time.Time `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt  time.Time `json:"updated_at" gorm:"autoUpdateTime"`
	Members    []Member  `json:"members,omitempty" gorm:"foreignKey:GroupID"`
}

func SetRLSContext(db *gorm.DB, walletAddress string) *gorm.DB {
	return db.Exec("SELECT set_config('app.user_wallet', ?, true)", walletAddress)
}
