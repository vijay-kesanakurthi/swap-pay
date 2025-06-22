package jupiter

import (
	"encoding/json"
	"fmt"
	"github.com/gin-gonic/gin"
	"log"
	"net/http"
	"net/url"
	"time"
)

type ExactOutRequest struct {
	InputMint    string `json:"input_mint" binding:"required"`
	OutputMint   string `json:"output_mint" binding:"required"`
	OutputAmount int64  `json:"output_amount" binding:"required"` // Raw amount (before decimals)
	SlippageBps  int    `json:"slippage_bps"`                     // Optional
}

type ExactOutResponse struct {
	InputAmount string `json:"input_amount"`
	Message     string `json:"message"`
}

func GetRequiredInputAmount(c *gin.Context) {
	var req ExactOutRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.SlippageBps == 0 {
		req.SlippageBps = 50 // default to 0.5%
	}

	quoteResponse, err := fetchJupiterInputAmount(req.InputMint, req.OutputMint, req.OutputAmount, req.SlippageBps)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, quoteResponse)
}

type QuoteResponse struct {
	InputMint                   string      `json:"inputMint"`
	InAmount                    string      `json:"inAmount"`
	OutputMint                  string      `json:"outputMint"`
	OutAmount                   string      `json:"outAmount"`
	OtherAmountThreshold        string      `json:"otherAmountThreshold"`
	SwapMode                    string      `json:"swapMode"`
	SlippageBps                 int         `json:"slippageBps"`
	PlatformFee                 interface{} `json:"platformFee"` // null = dynamic type
	PriceImpactPct              string      `json:"priceImpactPct"`
	RoutePlan                   []RoutePlan `json:"routePlan"`
	ContextSlot                 int64       `json:"contextSlot"`
	TimeTaken                   float64     `json:"timeTaken"`
	SwapUsdValue                string      `json:"swapUsdValue"`
	SimplerRouteUsed            bool        `json:"simplerRouteUsed"`
	MostReliableAmmsQuoteReport struct {
		Info map[string]string `json:"info"`
	} `json:"mostReliableAmmsQuoteReport"`
	UseIncurredSlippageForQuoting interface{} `json:"useIncurredSlippageForQuoting"`
	OtherRoutePlans               interface{} `json:"otherRoutePlans"`
}

type RoutePlan struct {
	SwapInfo SwapInfo `json:"swapInfo"`
	Percent  int      `json:"percent"`
}

type SwapInfo struct {
	AmmKey     string `json:"ammKey"`
	Label      string `json:"label"`
	InputMint  string `json:"inputMint"`
	OutputMint string `json:"outputMint"`
	InAmount   string `json:"inAmount"`
	OutAmount  string `json:"outAmount"`
	FeeAmount  string `json:"feeAmount"`
	FeeMint    string `json:"feeMint"`
}

func fetchJupiterInputAmount(inputMint, outputMint string, outputAmount int64, slippageBps int) (QuoteResponse, error) {
	baseURL := "https://lite-api.jup.ag/swap/v1/quote"

	params := url.Values{}
	params.Set("inputMint", inputMint)
	params.Set("outputMint", outputMint)
	params.Set("amount", fmt.Sprintf("%d", outputAmount)) // Exact output amount in raw form
	params.Set("swapMode", "ExactOut")
	params.Set("slippageBps", fmt.Sprintf("%d", slippageBps))

	fullURL := fmt.Sprintf("%s?%s", baseURL, params.Encode())

	client := http.Client{Timeout: 10 * time.Second}
	resp, err := client.Get(fullURL)
	if err != nil {
		log.Println("Jipiter Error:", err)
		return QuoteResponse{}, fmt.Errorf("jupiter API request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		log.Println("jupiter API request failed with status code", resp)
		return QuoteResponse{}, fmt.Errorf("jupiter API error: %s", resp.Status)
	}

	var parsed QuoteResponse

	if err := json.NewDecoder(resp.Body).Decode(&parsed); err != nil {
		log.Println("Jupiter API error:", err)
		return QuoteResponse{}, fmt.Errorf("failed to parse Jupiter response: %w", err)
	}

	return parsed, nil
}
