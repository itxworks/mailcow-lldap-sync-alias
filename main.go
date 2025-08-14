package main

import (
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"log"
	"os"
)

func main() {
	dbUser := os.Getenv("DB_USER")
	dbPass := os.Getenv("DB_PASS")
	dbHost := os.Getenv("DB_HOST")
	dbName := os.Getenv("DB_NAME")

	if dbUser == "" || dbPass == "" || dbHost == "" || dbName == "" {
		log.Fatal("Missing required DB_* environment variables")
	}

	dsn := fmt.Sprintf("%s:%s@tcp(%s)/%s?parseTime=true", dbUser, dbPass, dbHost, dbName)
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		log.Fatalf("DB connection error: %v", err)
	}
	defer db.Close()

	query := `
	SELECT m.username, m.domain
	FROM mailbox m
	LEFT JOIN alias a ON a.address = m.username
	WHERE a.address IS NULL AND m.active = 1;
	`

	rows, err := db.Query(query)
	if err != nil {
		log.Fatalf("Failed query: %v", err)
	}
	defer rows.Close()

	countInserted := 0
	for rows.Next() {
		var username, domain string
		if err := rows.Scan(&username, &domain); err != nil {
			log.Printf("Row scan error: %v", err)
			continue
		}

		_, err := db.Exec(`
			INSERT INTO alias (
				address, goto, domain, created, modified,
				private_comment, public_comment, sogo_visible, active
			) VALUES (?, ?, ?, NOW(), NULL, NULL, NULL, 1, 1)
		`, username, username, domain)

		if err != nil {
			log.Printf("Failed to insert alias for %s: %v", username, err)
			continue
		}
		log.Printf("Inserted alias: %s", username)
		countInserted++
	}

	log.Printf("Done. Inserted %d aliases.", countInserted)
}
