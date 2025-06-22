package main

import (
	"backend/config"
	"backend/routes"
	"log"
)

func main() {
	// Initialize database
	config.ConnectDatabase()

	// Setup routes
	r := routes.SetupRoutes()

	// Start server
	log.Println("Server starting on :8080")
	if err := r.Run(":8081"); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
