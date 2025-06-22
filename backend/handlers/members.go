package handlers

import (
	"backend/config"
	"backend/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"net/http"
)

func GetGroupsByUserWallet(c *gin.Context) {
	walletAddress := c.Param("wallet_address")
	db := config.GetDB()
	var groupIDs []uuid.UUID

	// Step 1: Get group IDs where wallet address matches
	err := db.Model(&models.Member{}).
		Where("wallet_address = ?", walletAddress).
		Pluck("group_id", &groupIDs).Error

	if err != nil || len(groupIDs) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "No groups found"})
		return
	}

	// Step 2: Fetch full group details for those IDs
	var groups []models.Group
	err = db.
		Where("id IN ?", groupIDs).
		Find(&groups).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch group details"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"groups": groups})

}

func GetGroupMembers(c *gin.Context) {
	db := config.GetDB()
	var members []models.Member

	err := db.Where("group_id = ?", c.Param("id")).Find(&members).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch members"})
	}
	c.JSON(http.StatusOK, gin.H{"members": members})
}
