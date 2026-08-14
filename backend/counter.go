package main

import (
	"database/sql"
	"errors"
	"net/http"
)

// handleHealth godoc
//
//	@Summary		ヘルスチェック
//	@Description	サーバーの稼働状態を返す
//	@Tags			system
//	@Produce		json
//	@Success		200	{object}	healthResponse
//	@Router			/ [get]
func (s *server) handleHealth(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, healthResponse{Status: "ok"})
}

// handleGetCounter godoc
//
//	@Summary		PVカウンター
//	@Description	現在のページビュー数を返す
//	@Tags			system
//	@Produce		json
//	@Success		200	{object}	countResponse
//	@Failure		404	{object}	errorResponse
//	@Failure		500	{object}	errorResponse
//	@Router			/counter [get]
func (s *server) handleGetCounter(w http.ResponseWriter, r *http.Request) {
	var current int
	err := s.db.QueryRow(
		"SELECT count FROM views WHERE id = 1",
	).Scan(&current)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "counter not found")
			return
		}
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, countResponse{Count: current})
}

// handleIncrementCounter godoc
//
//	@Summary		PVカウンター加算
//	@Description	ページビュー数をインクリメントして現在値を返す
//	@Tags			system
//	@Produce		json
//	@Success		200	{object}	countResponse
//	@Failure		404	{object}	errorResponse
//	@Failure		500	{object}	errorResponse
//	@Router			/counter [post]
func (s *server) handleIncrementCounter(w http.ResponseWriter, r *http.Request) {
	var current int
	err := s.db.QueryRow(
		"UPDATE views SET count = count + 1 WHERE id = 1 RETURNING count",
	).Scan(&current)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "counter not found")
			return
		}
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, countResponse{Count: current})
}
