package handlers

import (
	"backend/config"
	"backend/models"
	"crypto/rand"
	"encoding/hex"
	"github.com/gin-gonic/gin"
	"net/http"
)

type CreateGroupRequest struct {
	Name          string `json:"name" binding:"required"`
	CreatorWallet string `json:"creator_wallet" binding:"required"`
	CreatorName   string `json:"creator_name"`
}

func CreateGroup(c *gin.Context) {
	var req CreateGroupRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Generate unique invite code
	inviteCode := generateInviteCode()

	group := models.Group{
		Name:       req.Name,
		InviteCode: inviteCode,
	}

	db := config.GetDB()
	tx := db.Begin()

	if err := tx.Create(&group).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create group"})
		return
	}

	// Add creator as first member
	member := models.Member{
		GroupID:       group.ID,
		WalletAddress: req.CreatorWallet,
		Name:          &req.CreatorName,
	}

	if err := tx.Create(&member).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add creator"})
		return
	}

	tx.Commit()

	c.JSON(http.StatusCreated, gin.H{
		"group":       group,
		"invite_link": "https://your-app.com/join/" + inviteCode,
	})
}

type JoinGroupRequest struct {
	WalletAddress string `json:"wallet_address" binding:"required"`
	Name          string `json:"name"`
}

func JoinGroup(c *gin.Context) {
	inviteCode := c.Param("invite_code")

	var req JoinGroupRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	db := config.GetDB()

	var group models.Group
	if err := db.Where("invite_code = ?", inviteCode).First(&group).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Group not found"})
		return
	}

	member := models.Member{
		GroupID:       group.ID,
		WalletAddress: req.WalletAddress,
		Name:          &req.Name,
	}

	if err := db.Create(&member).Error; err != nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Already a member or database error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Successfully joined group", "group": group})
}

func GetGroupByInviteCode() {
	//
	//db := config.GetDB()
	//
	//var group models.Group
	//if err := db.Where("invite_code = ?", inviteCode).First(&group).Error; err != nil {
	//	c.JSON(http.StatusNotFound, gin.H{"error": "Group not found"})
	//	return
	//}

}

func generateInviteCode() string {
	bytes := make([]byte, 6)
	rand.Read(bytes)
	return hex.EncodeToString(bytes)
}
