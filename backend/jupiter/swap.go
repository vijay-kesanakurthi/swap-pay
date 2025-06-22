package jupiter

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/gagliardetto/solana-go"
	"github.com/gin-gonic/gin"
	"log"
	"net/http"
)

type SwapRequest struct {
	UserPublicKey string        `json:"userPublicKey" binding:"required"`
	DestPublicKey string        `json:"destPublicKey" binding:"required"`
	MintAddress   string        `json:"mintAddress" binding:"required"`
	QuoteResponse QuoteResponse `json:"quoteResponse" binding:"required"`
}

type SwapResponse struct {
	SwapTransaction               string             `json:"swapTransaction"`
	LastValidBlockHeight          int64              `json:"lastValidBlockHeight"`
	PrioritizationFeeLamports     int64              `json:"prioritizationFeeLamports"`
	ComputeUnitLimit              int64              `json:"computeUnitLimit"`
	PrioritizationType            PrioritizationType `json:"prioritizationType"`
	SimulationSlot                int64              `json:"simulationSlot"`
	DynamicSlippageReport         interface{}        `json:"dynamicSlippageReport"`
	SimulationError               *SimulationError   `json:"simulationError,omitempty"`
	AddressesByLookupTableAddress interface{}        `json:"addressesByLookupTableAddress"`
}

type PrioritizationType struct {
	ComputeBudget struct {
		MicroLamports          int64 `json:"microLamports"`
		EstimatedMicroLamports int64 `json:"estimatedMicroLamports"`
	} `json:"computeBudget"`
}

type SimulationError struct {
	ErrorCode string `json:"errorCode"`
	Error     string `json:"error"`
}

func GetAssociatedTokenAddress(walletPubkey, mintPubkey solana.PublicKey) (solana.PublicKey, uint8, error) {
	return solana.FindAssociatedTokenAddress(walletPubkey, mintPubkey)
}

func ExecuteSwap(c *gin.Context) {
	var req SwapRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	publicKey, err := solana.PublicKeyFromBase58(req.DestPublicKey)
	if err != nil {
		return
	}
	mint, err := solana.PublicKeyFromBase58(req.MintAddress)
	if err != nil {
		return
	}

	accountTokenAddress, _, err := GetAssociatedTokenAddress(publicKey, mint)
	if err != nil {
		log.Fatal(err)
	}
	log.Println("Account sdf", accountTokenAddress.String())

	swapPayload := map[string]interface{}{
		"userPublicKey":           req.UserPublicKey,
		"quoteResponse":           req.QuoteResponse,
		"destinationTokenAccount": accountTokenAddress,
		"prioritizationFeeLamports": map[string]interface{}{
			"priorityLevelWithMaxLamports": map[string]interface{}{
				"maxLamports":   10000000,
				"priorityLevel": "veryHigh",
			},
		},
		"dynamicComputeUnitLimit": true,
	}

	payloadBytes, err := json.Marshal(swapPayload)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to marshal swap request"})
		return
	}

	resp, err := http.Post("https://lite-api.jup.ag/swap/v1/swap", "application/json", bytes.NewReader(payloadBytes))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Jupiter swap API request failed"})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		c.JSON(resp.StatusCode, gin.H{"error": fmt.Sprintf("Jupiter swap error: %s", resp.Status)})
		return
	}

	var result SwapResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to parse Jupiter swap response"})
		return
	}
	log.Println(result)

	c.JSON(http.StatusOK, result)
}
