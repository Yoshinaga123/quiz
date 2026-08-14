package main

import (
	"fmt"
	"runtime"
	"runtime/debug"
	"sort"
	"time"
)

func formatBytes(bytes uint64) string {
	const unit = 1024
	if bytes < unit {
		return fmt.Sprintf("%d B", bytes)
	}

	div, exp := uint64(unit), 0
	for n := bytes / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}

	return fmt.Sprintf("%.2f %cB", float64(bytes)/float64(div), "KMGTPE"[exp])
}

func logMemoryStats() {
	var stats runtime.MemStats
	runtime.ReadMemStats(&stats)

	fmt.Printf("Alloc（ヒープ使用中）: %s\n", formatBytes(stats.Alloc))
	fmt.Printf("TotalAlloc（累計）: %s\n", formatBytes(stats.TotalAlloc))
	fmt.Printf("Sys（OS取得合計）: %s\n", formatBytes(stats.Sys))
	fmt.Printf("NumGC（GCサイクル数）: %d\n", stats.NumGC)
	fmt.Printf("HeapAlloc: %s\n", formatBytes(stats.HeapAlloc))
	fmt.Printf("HeapSys: %s\n", formatBytes(stats.HeapSys))
	fmt.Printf("HeapIdle: %s\n", formatBytes(stats.HeapIdle))
	fmt.Printf("HeapInuse: %s\n", formatBytes(stats.HeapInuse))
	fmt.Printf("HeapReleased: %s\n", formatBytes(stats.HeapReleased))
	fmt.Printf("HeapObjects: %d\n", stats.HeapObjects)
}

func analyzeNonHeapMemory() {
	var stats runtime.MemStats
	runtime.ReadMemStats(&stats)

	fmt.Println("=== Stack and System Memory ===")
	fmt.Printf("StackInuse: %s\n", formatBytes(stats.StackInuse))
	fmt.Printf("StackSys: %s\n", formatBytes(stats.StackSys))
	fmt.Printf("MSpanInuse: %s\n", formatBytes(stats.MSpanInuse))
	fmt.Printf("MSpanSys: %s\n", formatBytes(stats.MSpanSys))
	fmt.Printf("MCacheInuse: %s\n", formatBytes(stats.MCacheInuse))
	fmt.Printf("MCacheSys: %s\n", formatBytes(stats.MCacheSys))
	fmt.Printf("BuckHashSys: %s\n", formatBytes(stats.BuckHashSys))
	fmt.Printf("GCSys: %s\n", formatBytes(stats.GCSys))
	fmt.Printf("OtherSys: %s\n", formatBytes(stats.OtherSys))

	numGoroutines := runtime.NumGoroutine()
	if numGoroutines > 0 {
		avgStack := stats.StackInuse / uint64(numGoroutines)
		fmt.Printf("Average Stack per Goroutine: %s\n", formatBytes(avgStack))
	}
}

func analyzeGC() {
	var stats runtime.MemStats
	runtime.ReadMemStats(&stats)

	fmt.Println("=== Garbage Collection Statistics ===")
	fmt.Printf("Completed GC Cycles: %d\n", stats.NumGC)
	fmt.Printf("Forced GC Cycles: %d\n", stats.NumForcedGC)

	if stats.LastGC > 0 {
		lastGCTime := time.Unix(0, int64(stats.LastGC))
		fmt.Printf("Last GC: %s\n", lastGCTime.Format(time.RFC3339))
		fmt.Printf("Time Since Last GC: %s\n", time.Since(lastGCTime))
	}

	fmt.Printf("Total GC Pause Time: %s\n", time.Duration(stats.PauseTotalNs))

	if stats.NumGC > 0 {
		avgPause := time.Duration(stats.PauseTotalNs / uint64(stats.NumGC))
		fmt.Printf("Average GC Pause: %s\n", avgPause)
	}

	fmt.Printf("GC CPU Fraction: %.4f%%\n", stats.GCCPUFraction*100)
	fmt.Printf("Next GC Target: %s\n", formatBytes(stats.NextGC))
	fmt.Printf("Total Mallocs: %d\n", stats.Mallocs)
	fmt.Printf("Total Frees: %d\n", stats.Frees)
	fmt.Printf("Live Objects (Mallocs - Frees): %d\n", stats.Mallocs-stats.Frees)
}

func analyzeGCPauses() {
	var stats runtime.MemStats
	runtime.ReadMemStats(&stats)

	fmt.Println("=== GC Pause Analysis ===")

	if stats.NumGC == 0 {
		fmt.Println("No GC cycles completed yet")
		return
	}

	var pauses []time.Duration
	numPauses := int(stats.NumGC)
	if numPauses > 256 {
		numPauses = 256
	}

	for i := 0; i < numPauses; i++ {
		idx := int((stats.NumGC - uint32(i) - 1 + 256) % 256)
		pause := time.Duration(stats.PauseNs[idx])
		if pause > 0 {
			pauses = append(pauses, pause)
		}
	}

	if len(pauses) == 0 {
		fmt.Println("No pause data available")
		return
	}

	sort.Slice(pauses, func(i, j int) bool {
		return pauses[i] < pauses[j]
	})

	var total time.Duration
	for _, pause := range pauses {
		total += pause
	}

	fmt.Printf("Number of Recorded Pauses: %d\n", len(pauses))
	fmt.Printf("Min Pause: %s\n", pauses[0])
	fmt.Printf("Max Pause: %s\n", pauses[len(pauses)-1])
	fmt.Printf("Avg Pause: %s\n", total/time.Duration(len(pauses)))

	p50 := pauses[len(pauses)*50/100]
	p90 := pauses[len(pauses)*90/100]
	p99 := pauses[len(pauses)*99/100]

	fmt.Printf("P50 Pause: %s\n", p50)
	fmt.Printf("P90 Pause: %s\n", p90)
	fmt.Printf("P99 Pause: %s\n", p99)

	lastPauseEnd := time.Unix(0, int64(stats.PauseEnd[(stats.NumGC+255)%256]))
	fmt.Printf("Last Pause Ended: %s\n", lastPauseEnd.Format(time.RFC3339Nano))
}

func gcTuningReport() {
	var stats runtime.MemStats
	runtime.ReadMemStats(&stats)

	fmt.Println("=== GC Tuning Report ===")

	gcPercent := debug.SetGCPercent(-1)
	debug.SetGCPercent(gcPercent)
	if gcPercent < 0 {
		fmt.Println("GOGC: off (GC disabled)")
	} else {
		fmt.Printf("GOGC: %d%%\n", gcPercent)
	}

	memLimit := debug.SetMemoryLimit(-1)
	const unlimitedMemLimit int64 = 1<<63 - 1
	if memLimit == unlimitedMemLimit {
		fmt.Println("GOMEMLIMIT: not set")
	} else {
		fmt.Printf("GOMEMLIMIT: %s\n", formatBytes(uint64(memLimit)))
	}

	if stats.NumGC > 0 {
		avgHeapBetweenGC := stats.TotalAlloc / uint64(stats.NumGC)
		fmt.Printf("Average Allocation per GC Cycle: %s\n", formatBytes(avgHeapBetweenGC))
	}

	fmt.Printf("GC CPU Overhead: %.2f%%\n", stats.GCCPUFraction*100)
	if stats.GCCPUFraction > 0.05 {
		fmt.Println("WARNING: GC overhead is high (>5%)")
		fmt.Println("Consider: Increasing GOGC or reducing allocation rate")
	}

	if stats.HeapAlloc > 0 && stats.NextGC > 0 {
		growthRatio := float64(stats.NextGC) / float64(stats.HeapAlloc)
		fmt.Printf("Heap Growth Ratio (NextGC/HeapAlloc): %.2fx\n", growthRatio)
	}

	if stats.HeapInuse > 0 {
		retentionRatio := float64(stats.HeapIdle) / float64(stats.HeapInuse)
		fmt.Printf("Idle/Inuse Ratio: %.2f\n", retentionRatio)

		if retentionRatio > 2.0 {
			fmt.Println("INFO: High idle memory ratio")
			fmt.Println("Consider: debug.FreeOSMemory() to release memory to OS")
		}
	}

	if stats.NumGC > 0 {
		avgPause := time.Duration(stats.PauseTotalNs / uint64(stats.NumGC))
		if avgPause > time.Millisecond {
			fmt.Printf(
				"WARNING: Average GC pause (%.2fms) exceeds 1ms\n",
				float64(avgPause)/float64(time.Millisecond),
			)
			fmt.Println("Consider: Reducing heap size or live object count")
		}
	}
}
