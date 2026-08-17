package main

import (
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"strconv"
)

func writeJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if payload == nil {
		return
	}

	if err := json.NewEncoder(w).Encode(payload); err != nil {
		log.Printf("encode response: %v", err)
	}
}

func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, errorResponse{Error: message})
}

func decodeJSON(r *http.Request, dst any) error {
	defer r.Body.Close()

	decoder := json.NewDecoder(io.LimitReader(r.Body, 1<<20))
	decoder.DisallowUnknownFields()

	if err := decoder.Decode(dst); err != nil {
		return err
	}

	var extra json.RawMessage
	if err := decoder.Decode(&extra); err != io.EOF {
		return errors.New("request body must contain a single JSON object")
	}

	return nil
}

func parseID(raw string) (int64, error) {
	id, err := strconv.ParseInt(raw, 10, 64)
	if err != nil || id <= 0 {
		return 0, errors.New("invalid quiz id")
	}
	return id, nil
}

func writePublicError(w http.ResponseWriter, status int, code, message string) {
	writeJSON(w, status, publicErrorResponse{Code: code, Message: message})
}
