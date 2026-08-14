package main

import (
	"fmt"
	"log"
	"net/http"
	"runtime"
	"time"

	"github.com/shirou/gopsutil/mem"
)

func withCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		if origin != "" {
			w.Header().Set("Access-Control-Allow-Origin", origin)
			w.Header().Set("Vary", "Origin")
		}
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Authorization, Content-Type")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func (s *server) routes() http.Handler {
	mux := http.NewServeMux()

	mux.HandleFunc("GET /", s.handleHealth)
	mux.HandleFunc("GET /healthz", s.handleHealthz)
	mux.HandleFunc("GET /counter", s.handleGetCounter)
	mux.HandleFunc("POST /counter", s.handleIncrementCounter)
	mux.HandleFunc("GET /v1/quizzes", s.handleListPublicQuizzes)
	mux.HandleFunc("GET /v1/quizzes/{id}", s.handleGetPublicQuiz)
	mux.HandleFunc("GET /v1/sections", s.handleListPublicSections)
	mux.HandleFunc("GET /v1/push/feed", s.handleGetPublicPushFeed)
	mux.HandleFunc("POST /api/admin/login/verification", s.handleRequestLoginVerification)
	mux.HandleFunc("POST /api/admin/login", s.handleLogin)
	mux.Handle("GET /api/admin/quizzes", s.requireAuth(http.HandlerFunc(s.handleListQuizzes)))
	mux.Handle("POST /api/admin/quizzes/sync-production", s.requireAuth(http.HandlerFunc(s.handleSyncProductionQuizzes)))
	mux.Handle("POST /api/admin/push/dispatch", s.requireAuth(http.HandlerFunc(s.handleDispatchMockPush)))
	mux.Handle("GET /api/admin/push/deliveries", s.requireAuth(http.HandlerFunc(s.handleListPushDeliveries)))
	mux.Handle("GET /api/admin/quizzes/{id}", s.requireAuth(http.HandlerFunc(s.handleGetQuiz)))
	mux.Handle("POST /api/admin/quizzes", s.requireAuth(http.HandlerFunc(s.handleCreateQuiz)))
	mux.Handle("PUT /api/admin/quizzes/{id}", s.requireAuth(http.HandlerFunc(s.handleUpdateQuiz)))
	mux.Handle("DELETE /api/admin/quizzes/{id}", s.requireAuth(http.HandlerFunc(s.handleDeleteQuiz)))
	mux.Handle("PATCH /api/admin/quizzes/{id}/status", s.requireAuth(http.HandlerFunc(s.handleToggleStatus)))
	mux.Handle("PATCH /api/admin/quizzes/{id}/push", s.requireAuth(http.HandlerFunc(s.handleTogglePush)))

	return withCORS(mux)
}

// @title			Quiz Admin API
// @version		1.0
// @description	クイズ管理アプリケーションのバックエンドAPI
// @host			localhost:8080
// @BasePath		/
//
// @securityDefinitions.apikey	BearerAuth
// @in							header
// @name						Authorization
// @description				Bearer トークンを入力（例: Bearer eyJhbG...）
func main() {
	v, _ := mem.VirtualMemory()
	fmt.Printf("OS全体の使用中: %.2f%%\n", v.UsedPercent)
	fmt.Printf("Number of CPUs: %d\n", runtime.NumCPU())
	fmt.Printf("GOMAXPROCS: %d\n", runtime.GOMAXPROCS(0))
	fmt.Printf("Go Version: %s\n", runtime.Version())
	fmt.Printf("OS/Arch: %s/%s\n", runtime.GOOS, runtime.GOARCH)
	logMemoryStats()
	analyzeNonHeapMemory()
	runtime.GC()
	analyzeGC()
	analyzeGCPauses()
	gcTuningReport()

	// ワーカー生成前のゴルーチン数を確認する
	initial := runtime.NumGoroutine()
	fmt.Printf("初期ゴルーチン数: %d\n", initial)

	done := make(chan bool)
	for i := 0; i < 10; i++ {
		go func(id int) {
			time.Sleep(2 * time.Second)
			done <- true
		}(i)
	}
	// ワーカー生成後のゴルーチン数を確認する
	afterSpawn := runtime.NumGoroutine()
	fmt.Printf("ワーカー生成後: %d\n", afterSpawn)
	analyzeNonHeapMemory()

	// 全ワーカーの完了を待つ
	for i := 0; i < 10; i++ {
		<-done
	}

	// ランタイムがクリーンアップする時間を少し与える
	time.Sleep(100 * time.Millisecond)

	// 最終数を確認する — 初期値に戻っているはず
	final := runtime.NumGoroutine()
	fmt.Printf("最終ゴルーチン数: %d\n", final)
	analyzeNonHeapMemory()

	// ゴルーチンリークの可能性を検出する
	if final > initial {
		fmt.Printf("警告: ゴルーチンリークの可能性を検出！リーク数: %d\n", final-initial)
	}

	db, err := initDB()
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	s := &server{
		db:                   db,
		adminUser:            getEnv("ADMIN_USER", "admin"),
		adminPassword:        getEnv("ADMIN_PASSWORD", "password"),
		jwtSecret:            []byte(getEnv("JWT_SECRET", "dev-only-secret")),
		pendingVerifications: make(map[string]verificationChallenge),
	}

	if err := http.ListenAndServe(":8080", s.routes()); err != nil {
		log.Fatal(err)
	}
}
