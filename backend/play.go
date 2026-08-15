//go:build ignore

// Scratch pad. go build skips this file because of the ignore tag.
// Run: go run play.go
package main

import (
	"encoding/json"
	"fmt"
	"os"
)

func main() {
	raw, err := os.ReadFile("../docs/api/fixtures/quiz.json")
	if err != nil {
		fmt.Fprintf(os.Stderr, "read fixture: %v\n", err)
		os.Exit(1)
	}
	var payload map[string]any
	if err := json.Unmarshal(raw, &payload); err != nil {
		fmt.Fprintf(os.Stderr, "parse fixture: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("quiz id=%v section=%v\n", payload["id"], payload["section"])
}
