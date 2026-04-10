DELETE FROM quizzes WHERE id BETWEEN 128 AND 235;

INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (128, 'セクション53: JavaScript 英語表現', '組み込みオブジェクトの英訳', '`組み込みオブジェクト` を英語で表すものとして最も適切なのはどれですか？', '// JavaScript で Array, Date, Math などを指す文脈', '["built-in object", "embedded property", "internal variable", "default instance"]', 0, '`組み込みオブジェクト` は英語で一般に `built-in object` と表現します。JavaScript では `Array` や `Date` など、言語や実行環境にあらかじめ備わっているオブジェクトを指す文脈で使われます。', 'General JavaScript terminology');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (129, 'セクション54: Go ランタイム メモリ統計', 'runtime.MemStats の Alloc フィールド', '以下のコードで `stats.Alloc` が表す値はどれですか？', 'var stats runtime.MemStats
runtime.ReadMemStats(&stats)
fmt.Printf("Alloc: %s\n", formatBytes(stats.Alloc))', '["OSからGoランタイムに割り当てられた総メモリ量", "現在ヒープに使用中のメモリ量（GCされていないオブジェクト）", "プログラム開始からの累計アロケーション量", "スタック領域の使用量"]', 1, '`Alloc` は現在ヒープ上で生きているオブジェクトが使用中のバイト数です。GCが走るたびに減少します。累計アロケーション量は `TotalAlloc`、OSから取得した総量は `Sys` です。', 'backend/main.go - logMemoryStats() / https://pkg.go.dev/runtime#MemStats');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (130, 'セクション54: Go ランタイム メモリ統計', 'TotalAlloc と Alloc の違い', '`stats.TotalAlloc` と `stats.Alloc` の違いとして正しいものはどれですか？', 'fmt.Printf("Alloc（ヒープ使用中）: %s\n", formatBytes(stats.Alloc))
fmt.Printf("TotalAlloc（累計）: %s\n", formatBytes(stats.TotalAlloc))', '["`TotalAlloc` はGC後に減少し、`Alloc` は単調増加する", "`Alloc` はGC後に減少するが、`TotalAlloc` はプログラム開始からの累計で減少しない", "両者は常に同じ値を返す", "`TotalAlloc` はスタックとヒープの合計、`Alloc` はヒープのみ"]', 1, '`Alloc` はGCが走るとオブジェクトが回収されるため減少します。`TotalAlloc` はプログラム開始から確保されたバイト数の累計で、単調増加のみです。メモリ圧力を測るには `Alloc` を、アロケーション頻度を測るには `TotalAlloc` の変化量を見ます。', 'backend/main.go - logMemoryStats() / https://pkg.go.dev/runtime#MemStats');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (131, 'セクション54: Go ランタイム メモリ統計', 'HeapIdle と HeapInuse', '`HeapIdle` が大きい場合、何を意味しますか？', 'fmt.Printf("HeapIdle: %s\n", formatBytes(stats.HeapIdle))
fmt.Printf("HeapInuse: %s\n", formatBytes(stats.HeapInuse))', '["ヒープのメモリ不足が近い", "Goランタイムが確保しているがオブジェクトに使われていないスパンが多い", "GCが全く動いていない", "スタックが大きく成長している"]', 1, '`HeapIdle` はOSから確保済みだがオブジェクトが入っていないスパンの合計です。大きい場合はメモリをOSに返せる余地があります。`debug.FreeOSMemory()` を呼ぶか、`GOGC` を下げると解放されます。`HeapInuse` は実際にオブジェクトが入っているスパンです。', 'backend/main.go - logMemoryStats() / https://pkg.go.dev/runtime#MemStats');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (132, 'セクション54: Go ランタイム メモリ統計', 'NumGC の意味', '`stats.NumGC` が表す値はどれですか？', 'fmt.Printf("NumGC（GCサイクル数）: %d\n", stats.NumGC)', '["現在実行中のGCゴルーチン数", "プログラム開始からの完了したGCサイクル数", "次のGCが発動するまでの残りサイクル数", "強制GC（runtime.GC()）の呼び出し回数のみ"]', 1, '`NumGC` はプログラム開始から完了したGCサイクルの総数です。自動GC・強制GCどちらもカウントされます。強制GCのみのカウントは `NumForcedGC` が別途あります。', 'backend/main.go - logMemoryStats() / https://pkg.go.dev/runtime#MemStats');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (133, 'セクション54: Go ランタイム メモリ統計', 'StackInuse とゴルーチン数の関係', '以下のコードで平均スタックサイズを計算しているとき、`numGoroutines` が増えると `avgStack` はどうなりますか？', 'numGoroutines := runtime.NumGoroutine()
if numGoroutines > 0 {
    avgStack := stats.StackInuse / uint64(numGoroutines)
    fmt.Printf("Average Stack per Goroutine: %s\n", formatBytes(avgStack))
}', '["numGoroutines が増えると avgStack は増加する", "numGoroutines が増えると avgStack は減少する（分母が増えるため）", "numGoroutines と avgStack は無関係", "StackInuse は変化しないため avgStack は常に一定"]', 1, '`avgStack = StackInuse / numGoroutines` なので、分母の `numGoroutines` が増えると `avgStack` は小さくなります。ただし実際はゴルーチンが増えると `StackInuse` も増加するため、実運用での `avgStack` の変化は必ずしも単調ではありません。', 'backend/main.go - analyzeNonHeapMemory()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (134, 'セクション54: Go ランタイム メモリ統計', 'MSpanInuse とは', '`stats.MSpanInuse` が表すものはどれですか？', 'fmt.Printf("MSpanInuse: %s\n", formatBytes(stats.MSpanInuse))
fmt.Printf("MSpanSys: %s\n", formatBytes(stats.MSpanSys))', '["ヒープオブジェクトのメモリ量", "mspan 構造体（ヒープスパン管理メタデータ）が使用しているメモリ量", "ミューテックスのスピン待機に使われているメモリ量", "OSのメモリマップに使われているメモリ量"]', 1, '`MSpanInuse` はGoランタイムがヒープスパンを管理するための `mspan` 構造体が実際に使用しているメモリ量です。`MSpanSys` はOSから確保した総量で、`MSpanSys - MSpanInuse` がアイドル分になります。', 'backend/main.go - analyzeNonHeapMemory() / https://pkg.go.dev/runtime#MemStats');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (135, 'セクション54: Go ランタイム メモリ統計', 'formatBytes 関数の動作', '以下の `formatBytes` 関数に `1500` を渡した場合の出力はどれですか？', 'func formatBytes(bytes uint64) string {
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
}', '["\"1500 B\"", "\"1.46 KB\"", "\"1.50 KB\"", "\"0.00 MB\""]', 1, '1500 >= 1024 なのでKB換算になります。`1500 / 1024 = 1.46484...` なので `"1.46 KB"` です。ループは `n = 1500/1024 = 1` で `1 < 1024` のため即終了し `exp=0`（K）になります。', 'backend/main.go - formatBytes()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (136, 'セクション54: Go ランタイム メモリ統計', 'BuckHashSys の用途', '`stats.BuckHashSys` が表すものはどれですか？', 'fmt.Printf("BuckHashSys: %s\n", formatBytes(stats.BuckHashSys))', '["バケットソートに使われるメモリ量", "プロファイリング用バケットハッシュテーブルが使用しているメモリ量", "ハッシュマップの全エントリのメモリ量", "GCのマークビットマップに使われているメモリ量"]', 1, '`BuckHashSys` はGoランタイムがpprof等のプロファイリングデータを管理するバケットハッシュテーブルに使用するメモリ量です。通常は数百KB以下で、アプリのメモリ問題の主因にはなりません。', 'backend/main.go - analyzeNonHeapMemory() / https://pkg.go.dev/runtime#MemStats');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (137, 'セクション55: Go GC 統計', 'LastGC の型と変換', '以下のコードで `stats.LastGC` を時刻に変換しているとき、`stats.LastGC` の型はどれですか？', 'if stats.LastGC > 0 {
    lastGCTime := time.Unix(0, int64(stats.LastGC))
    fmt.Printf("Last GC: %s\n", lastGCTime.Format(time.RFC3339))
}', '["time.Time", "int64（Unix秒）", "uint64（Unixナノ秒）", "float64（Unix秒の小数）"]', 2, '`MemStats.LastGC` は `uint64` 型で、最後のGCが完了したUnixナノ秒を表します。`time.Unix(0, int64(stats.LastGC))` で `time.Time` に変換します。`time.Unix(sec, nsec)` の第1引数をゼロにし、第2引数にナノ秒を渡すのがポイントです。', 'backend/main.go - analyzeGC() / https://pkg.go.dev/runtime#MemStats');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (138, 'セクション55: Go GC 統計', 'PauseTotalNs と平均ポーズ時間', '以下のコードで平均GCポーズ時間を計算するとき、`stats.NumGC` がゼロの場合に除算しない理由はどれですか？', 'if stats.NumGC > 0 {
    avgPause := time.Duration(stats.PauseTotalNs / uint64(stats.NumGC))
    fmt.Printf("Average GC Pause: %s\n", avgPause)
}', '["NumGC がゼロだとPauseTotalNsも必ずゼロになるから", "ゼロ除算でパニックが発生するのを防ぐため", "uint64 の除算ではゼロ除算が無視されるから", "NumGC はゼロになり得ないから"]', 1, 'Goでは整数のゼロ除算は実行時パニック（`runtime error: integer divide by zero`）になります。`stats.NumGC > 0` のガードで安全に除算しています。なお `PauseTotalNs` が0でも除算は問題なく0を返すため、ガードは `NumGC` のみで十分です。', 'backend/main.go - analyzeGC()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (139, 'セクション55: Go GC 統計', 'GCCPUFraction の意味', '`stats.GCCPUFraction` が `0.05` のとき、何を意味しますか？', 'fmt.Printf("GC CPU Fraction: %.4f%%\n", stats.GCCPUFraction*100)

// gcTuningReport() より
if stats.GCCPUFraction > 0.05 {
    fmt.Println("WARNING: GC overhead is high (>5%)")
}', '["GCが5%の確率で実行される", "プログラム実行時間の5%をGCが消費している", "ヒープの5%がGC対象になっている", "GCが毎秒5回実行されている"]', 1, '`GCCPUFraction` は直近のGCサイクルでGCがCPU時間の何割を使ったかを表す `float64`（0〜1）です。`0.05` なら5%のCPU時間をGCが使用しています。5%超は高負荷の目安とされ、`GOGC` を上げる（GC頻度を下げる）か、アロケーション量を減らすことが推奨されます。', 'backend/main.go - gcTuningReport() / https://pkg.go.dev/runtime#MemStats');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (140, 'セクション55: Go GC 統計', 'PauseNs 配列とインデックス計算', '以下のコードで最新のGCポーズ時間を取得するインデックス計算の意味はどれですか？', 'idx := int((stats.NumGC - uint32(i) - 1 + 256) % 256)', '["256サイクル分の循環バッファから最新順にインデックスを計算している", "ランダムなサンプリング位置を計算している", "256で割った余りを使って配列の境界外アクセスを防いでいるだけ", "NumGCを256進数に変換している"]', 0, '`PauseNs` は256要素の循環バッファで、インデックスは `NumGC % 256` の位置に最新値が入ります。`(NumGC - i - 1 + 256) % 256` で i=0が最新、i=1が一つ前…と逆順にアクセスできます。`+256` はアンダーフロー防止です。', 'backend/main.go - analyzeGCPauses() / https://pkg.go.dev/runtime#MemStats');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (141, 'セクション55: Go GC 統計', 'パーセンタイル計算（P50/P90/P99）', '以下のP99計算コードで `len(pauses)*99/100` を使う理由はどれですか？', 'sort.Slice(pauses, func(i, j int) bool {
    return pauses[i] < pauses[j]
})

p50 := pauses[len(pauses)*50/100]
p90 := pauses[len(pauses)*90/100]
p99 := pauses[len(pauses)*99/100]', '["浮動小数点演算を避けて整数インデックスを求めるため", "配列を256要素に正規化するため", "sort.Sliceが1-basedインデックスを使うため", "99番目の要素だけを取り出すため"]', 0, 'スライスのインデックスは整数なので `int(float64(len)*0.99)` より整数演算 `len*99/100` の方がシンプルです。ソート済み配列の `len*99/100` 番目が99パーセンタイル（下から99%の位置）に相当します。厳密な実装ではなく近似値ですが、GCポーズの傾向把握には十分です。', 'backend/main.go - analyzeGCPauses()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (142, 'セクション55: Go GC 統計', 'debug.SetGCPercent の使い方', '以下のコードで `debug.SetGCPercent(-1)` を呼んだ後に再度 `debug.SetGCPercent(gcPercent)` を呼ぶ理由はどれですか？', 'gcPercent := debug.SetGCPercent(-1)
debug.SetGCPercent(gcPercent)
if gcPercent < 0 {
    fmt.Println("GOGC: off (GC disabled)")
} else {
    fmt.Printf("GOGC: %d%%\n", gcPercent)
}', '["GCを一時的に無効化して値を読み取るため", "`SetGCPercent` は現在値を返すので `-1` で読み取り専用アクセスし、元の値に戻している", "GCを2回トリガーするため", "負の値を渡すとGCが強制実行されるため"]', 1, '`debug.SetGCPercent(n)` は新しい値を設定し**直前の値**を返します。`-1` を渡すとGCが無効化されてしまうため、返ってきた元の値を即座に再設定して副作用を打ち消しています。現在値だけを読み取る専用関数がないため、このパターンが慣用的です。', 'backend/main.go - gcTuningReport() / https://pkg.go.dev/runtime/debug#SetGCPercent');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (143, 'セクション55: Go GC 統計', 'GOMEMLIMIT の未設定検出', '以下のコードで `unlimitedMemLimit` を `1<<63 - 1` と定義している理由はどれですか？', 'memLimit := debug.SetMemoryLimit(-1)
const unlimitedMemLimit int64 = 1<<63 - 1
if memLimit == unlimitedMemLimit {
    fmt.Println("GOMEMLIMIT: not set")
}', '["int64の最大値がGOMEMLIMIT未設定時のデフォルト値だから", "負の値を表現するため", "メモリ上限を1PBに制限するため", "オーバーフローのチェック用マジックナンバーだから"]', 0, '`debug.SetMemoryLimit` はGOMEMLIMITが設定されていない場合に `math.MaxInt64`（= `1<<63 - 1`）を返します。これはGoの仕様で「上限なし」を意味するセンチネル値です。この値と比較することでGOMEMLIMITが明示設定されているかを判定できます。', 'backend/main.go - gcTuningReport() / https://pkg.go.dev/runtime/debug#SetMemoryLimit');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (144, 'セクション55: Go GC 統計', 'NextGC とヒープ成長比率', '`stats.NextGC / stats.HeapAlloc` が `2.0` のとき、何を意味しますか？', 'if stats.HeapAlloc > 0 && stats.NextGC > 0 {
    growthRatio := float64(stats.NextGC) / float64(stats.HeapAlloc)
    fmt.Printf("Heap Growth Ratio (NextGC/HeapAlloc): %.2fx\n", growthRatio)
}', '["次のGCまでにヒープが2倍になると予測されている", "現在のヒープの2倍に達したときに次のGCが発動する", "GCが2サイクル後に実行される", "ヒープ効率が50%である"]', 1, '`NextGC` は次のGCが発動するヒープサイズの目標値です。デフォルトの `GOGC=100` では前回GC後のヒープサイズの2倍が `NextGC` になります。`NextGC/HeapAlloc = 2.0` は「現在の2倍になったらGC」という状態を表し、デフォルト動作です。', 'backend/main.go - gcTuningReport() / https://pkg.go.dev/runtime#MemStats');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (145, 'セクション55: Go GC 統計', 'NumForcedGC の意味', '`stats.NumForcedGC` が `stats.NumGC` より小さい場合、何を意味しますか？', 'fmt.Printf("Completed GC Cycles: %d\n", stats.NumGC)
fmt.Printf("Forced GC Cycles: %d\n", stats.NumForcedGC)', '["強制GCの一部が失敗した", "自動GC（ランタイムによるトリガー）が発生している", "GCが無効化されている", "NumForcedGCのカウントにバグがある"]', 1, '`NumGC` は全GCサイクル数、`NumForcedGC` は `runtime.GC()` 等で明示的に呼んだGCの回数です。`NumForcedGC < NumGC` はランタイムが自動でGCを実行したサイクルが存在することを意味します。通常の運用では `NumForcedGC` はほぼゼロで、`NumGC` の大半は自動GCです。', 'backend/main.go - analyzeGC() / https://pkg.go.dev/runtime#MemStats');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (146, 'セクション56: Go ゴルーチン管理', 'runtime.NumGoroutine の用途', '以下のコードで `initial` と `final` を比較している目的はどれですか？', 'initial := runtime.NumGoroutine()

done := make(chan bool)
for i := 0; i < 10; i++ {
    go func(id int) {
        time.Sleep(2 * time.Second)
        done <- true
    }(i)
}

for i := 0; i < 10; i++ {
    <-done
}

time.Sleep(100 * time.Millisecond)
final := runtime.NumGoroutine()

if final > initial {
    fmt.Printf("警告: ゴルーチンリークの可能性を検出！リーク数: %d\n", final-initial)
}', '["ゴルーチンの実行速度を計測するため", "ゴルーチンリークを検出するため", "チャネルのバッファサイズを確認するため", "OSスレッド数の上限を確認するため"]', 1, 'ゴルーチンが適切に終了していれば、全ワーカー完了後のゴルーチン数は起動前の値に戻るはずです。`final > initial` の場合、いずれかのゴルーチンが終了していない（リーク）可能性を示します。テストでは `goleak` パッケージが同様の検出を行います。', 'backend/main.go - main()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (147, 'セクション56: Go ゴルーチン管理', 'ゴルーチンのクロージャと引数渡し', '以下のコードで `go func(id int) { ... }(i)` のように引数で `i` を渡している理由はどれですか？', 'for i := 0; i < 10; i++ {
    go func(id int) {
        time.Sleep(2 * time.Second)
        done <- true
    }(i)
}', '["goroutineにIDを渡してデバッグログを出力するため", "クロージャがループ変数 i を共有するstale closure問題を避けるため", "time.Sleepに引数として使うため", "done チャネルへの送信順序を制御するため"]', 1, 'クロージャが `i` を直接参照すると、全ゴルーチンが同じ変数を共有しループ終了後の値（10）を見てしまいます（stale closure）。引数 `id int` として値コピーを渡すことで各ゴルーチンが独立した値を持ちます。Go 1.22以降はループ変数のスコープが変わりこの問題が緩和されましたが、明示的な引数渡しは可読性のために推奨されます。', 'backend/main.go - main()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (148, 'セクション56: Go ゴルーチン管理', 'time.Sleep(100 * time.Millisecond) の役割', '全ワーカーの完了を `<-done` で待った後に `time.Sleep(100 * time.Millisecond)` を挟んでいる理由はどれですか？', 'for i := 0; i < 10; i++ {
    <-done
}

time.Sleep(100 * time.Millisecond)
final := runtime.NumGoroutine()', '["次のGCサイクルを発生させるため", "ランタイムがゴルーチンのクリーンアップを完了する時間を与えるため", "チャネルのバッファをフラッシュするため", "OSスレッドのスケジューリングを安定させるため"]', 1, '`done <- true` を送信しても、送信側ゴルーチンがスケジューラによって完全に終了・回収されるまでわずかな時間がかかります。即座に `NumGoroutine()` を呼ぶとまだ終了処理中のゴルーチンがカウントされ誤検知になることがあります。短いスリープでランタイムのクリーンアップを待ちます。', 'backend/main.go - main()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (149, 'セクション56: Go ゴルーチン管理', 'runtime.GOMAXPROCS の意味', '`runtime.GOMAXPROCS(0)` を呼び出したとき何が返りますか？', 'fmt.Printf("GOMAXPROCS: %d\n", runtime.GOMAXPROCS(0))', '["GOMAXPROCSを0に設定して以前の値を返す", "現在のGOMAXPROCS値を変更せず返す", "利用可能なCPUコア数を返す", "実行中のOSスレッド数を返す"]', 1, '`GOMAXPROCS(n)` はn>0なら値を設定して以前の値を返し、n=0なら設定を変更せず現在値を返します。読み取り専用アクセスに `0` を使うのは慣用パターンです。初期値は `runtime.NumCPU()` と同じです。', 'backend/main.go - main() / https://pkg.go.dev/runtime#GOMAXPROCS');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (150, 'セクション56: Go ゴルーチン管理', 'unbuffered channel でのワーカー同期', '以下のコードで `done` チャネルをバッファなし（`make(chan bool)`）にしている場合、ワーカーが `done <- true` を送信するタイミングはどれですか？', 'done := make(chan bool)
for i := 0; i < 10; i++ {
    go func(id int) {
        time.Sleep(2 * time.Second)
        done <- true
    }(i)
}
for i := 0; i < 10; i++ {
    <-done
}', '["受信側が <-done を呼ぶ準備ができるまでワーカーはブロックされる", "ワーカーは done <- true を非同期で送信してすぐ終了する", "バッファなしチャネルへの送信は常にパニックになる", "メインゴルーチンが <-done を呼ぶ前にバッファに積まれる"]', 0, 'バッファなしチャネルは送受信が必ずランデブー（同期）します。送信側（ワーカー）は受信側（メインゴルーチン）が `<-done` を呼ぶまでブロックされます。これにより「10回 `<-done` を受け取る = 10ワーカーが全員完了」という同期が実現します。', 'backend/main.go - main()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (151, 'セクション56: Go ゴルーチン管理', 'ワーカー生成後のゴルーチン数', '以下のコードで `afterSpawn` の値として期待される値はどれですか（初期ゴルーチン数が1の場合）？', 'initial := runtime.NumGoroutine()  // 1

for i := 0; i < 10; i++ {
    go func(id int) {
        time.Sleep(2 * time.Second)
        done <- true
    }(i)
}

afterSpawn := runtime.NumGoroutine()
fmt.Printf("ワーカー生成後: %d\n", afterSpawn)', '["1（ゴルーチンはまだ起動していない）", "10（ワーカーのみ）", "11（メイン + 10ワーカー）", "不定（スケジューラ次第）"]', 2, '`go func()` でゴルーチンを起動すると即座にスケジューラに登録されます。メインゴルーチン(1) + 10ワーカー = 11 が期待値です。ただし `NumGoroutine()` はランタイムの内部ゴルーチン（GC補助など）も含む場合があり、環境によって±数個の誤差がありえます。', 'backend/main.go - main()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (152, 'セクション57: Go JWT 認証', 'jwt.RegisteredClaims の ExpiresAt', '以下のコードで発行されるJWTの有効期限はどれですか？', 'claims := jwt.RegisteredClaims{
    Subject:   s.adminUser,
    IssuedAt:  jwt.NewNumericDate(time.Now()),
    ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
}
token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
return token.SignedString(s.jwtSecret)', '["発行から1時間", "発行から24時間", "発行から7日間", "無期限"]', 1, '`time.Now().Add(24 * time.Hour)` で現在時刻から24時間後を `ExpiresAt` に設定しています。`jwt.NewNumericDate` はGoの `time.Time` をJWT仕様の NumericDate（Unixタイムスタンプ）に変換します。', 'backend/main.go - issueJWT()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (153, 'セクション57: Go JWT 認証', 'Bearer トークンの検証フロー', '以下の `requireAuth` ミドルウェアで `strings.HasPrefix(header, "Bearer ")` を最初に確認する理由はどれですか？', 'header := r.Header.Get("Authorization")
if !strings.HasPrefix(header, "Bearer ") {
    writeError(w, http.StatusUnauthorized, "missing bearer token")
    return
}
tokenString := strings.TrimPrefix(header, "Bearer ")
claims := &jwt.RegisteredClaims{}
token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (any, error) {
    if token.Method != jwt.SigningMethodHS256 {
        return nil, fmt.Errorf("unexpected signing method: %s", token.Method.Alg())
    }
    return s.jwtSecret, nil
})', '["JWTの署名を事前検証するため", "Authorizationヘッダーが存在しない・形式が違う場合を早期リターンするため", "Base64デコードを行うため", "トークンの有効期限を確認するため"]', 1, '`Bearer ` プレフィックスがない場合はJWT自体が存在しないか形式が不正です。`jwt.ParseWithClaims` を呼ぶ前に早期リターンすることで不要なパース処理を省き、エラーメッセージも明確になります。', 'backend/main.go - requireAuth()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (154, 'セクション57: Go JWT 認証', '署名アルゴリズムの検証', '以下のキー関数で署名アルゴリズムを確認している理由はどれですか？', 'func(token *jwt.Token) (any, error) {
    if token.Method != jwt.SigningMethodHS256 {
        return nil, fmt.Errorf("unexpected signing method: %s", token.Method.Alg())
    }
    return s.jwtSecret, nil
}', '["パフォーマンス最適化のため", "alg:none 攻撃など意図しないアルゴリズムによる検証バイパスを防ぐため", "HS256以外ではシークレットキーが不要なため", "jwt.ParseWithClaims がアルゴリズムを自動検出できないため"]', 1, '攻撃者がヘッダーの `alg` を `none` に書き換えると、ライブラリによっては署名検証をスキップします。キー関数内で期待するアルゴリズムを明示的に確認することで、このアルゴリズム混同攻撃を防止します。これはJWT利用時のセキュリティベストプラクティスです。', 'backend/main.go - requireAuth()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (155, 'セクション57: Go JWT 認証', 'http.Handle と requireAuth の合成', '以下のルーティングで `s.requireAuth(http.HandlerFunc(s.handleListQuizzes))` のように2つの型変換を行っている理由はどれですか？', 'mux.Handle(
    "GET /api/admin/quizzes",
    s.requireAuth(http.HandlerFunc(s.handleListQuizzes)),
)', '["s.handleListQuizzes はメソッドなので直接 http.Handler として渡せないため、http.HandlerFunc でラップする", "requireAuth がメソッドを受け取れないため", "mux.Handle が関数ポインタを受け取らないため", "http.HandlerFunc はパフォーマンス最適化のためのラッパー"]', 0, '`s.handleListQuizzes` は `func(http.ResponseWriter, *http.Request)` 型のメソッド値です。`mux.Handle` は `http.Handler` インターフェース（`ServeHTTP` メソッドを持つ型）を要求します。`http.HandlerFunc` は関数を `http.Handler` に変換する型エイリアスで、`ServeHTTP` が定義されています。', 'backend/main.go - routes()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (156, 'セクション57: Go JWT 認証', 'handleLogin での認証情報比較', '以下の認証処理で `payload.Username != s.adminUser || payload.Password != s.adminPassword` の条件が真の場合、HTTPステータスコードはどれですか？', 'if payload.Username != s.adminUser || payload.Password != s.adminPassword {
    writeError(w, http.StatusUnauthorized, "invalid credentials")
    return
}', '["400 Bad Request", "401 Unauthorized", "403 Forbidden", "404 Not Found"]', 1, '認証情報が不正（ユーザー名・パスワードの不一致）は `401 Unauthorized` です。`403 Forbidden` は認証済みだがアクセス権限がない場合、`400 Bad Request` はリクエスト形式が不正な場合に使います。RFC 7235に基づき、認証失敗は401が正しい選択です。', 'backend/main.go - handleLogin()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (157, 'セクション58: Go HTTP & CORS', 'withCORS の Origin 動的設定', '以下の CORS ミドルウェアで `Access-Control-Allow-Origin` を固定値 `*` ではなくリクエストの `Origin` ヘッダーで動的に設定している理由はどれですか？', 'origin := r.Header.Get("Origin")
if origin != "" {
    w.Header().Set("Access-Control-Allow-Origin", origin)
    w.Header().Set("Vary", "Origin")
}', '["* ではCookieや認証ヘッダーを含むリクエストが許可されないため", "* はChromiumブラウザで動作しないため", "動的設定の方がパフォーマンスが高いため", "* はHTTPSでのみ使用できないため"]', 0, '`Access-Control-Allow-Credentials: true` と組み合わせる場合、`Access-Control-Allow-Origin: *` はブラウザに拒否されます。Cookieや `Authorization` ヘッダーを含む認証リクエストでは、オリジンを明示する必要があります。`Vary: Origin` はキャッシュがオリジンごとに別々のレスポンスを保持するよう指示します。', 'backend/main.go - withCORS()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (158, 'セクション58: Go HTTP & CORS', 'OPTIONS プリフライトリクエストの処理', '以下のコードで `OPTIONS` メソッドを特別に処理している理由はどれですか？', 'if r.Method == http.MethodOptions {
    w.WriteHeader(http.StatusNoContent)
    return
}
next.ServeHTTP(w, r)', '["OPTIONS は危険なメソッドなので即座に遮断するため", "ブラウザがCORSプリフライトとして OPTIONS を送るため、本処理前に204を返す必要があるため", "OPTIONSレスポンスはボディを含めてはいけないため", "mux が OPTIONS を認識しないため"]', 1, 'ブラウザはクロスオリジンリクエストの前に `OPTIONS` メソッドでプリフライトリクエストを送り、サーバーが許可しているかを確認します。CORSヘッダーを付けた `204 No Content` を返すことでブラウザに「許可済み」を伝え、本リクエストの送信に進ませます。', 'backend/main.go - withCORS()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (159, 'セクション58: Go HTTP & CORS', 'writeJSON でのエンコード', '以下の `writeJSON` で `json.NewEncoder(w).Encode(payload)` を使う利点はどれですか？', 'func writeJSON(w http.ResponseWriter, status int, payload any) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    if payload == nil {
        return
    }
    if err := json.NewEncoder(w).Encode(payload); err != nil {
        log.Printf("encode response: %v", err)
    }
}', '["`json.Marshal` より高速なため", "メモリに全データをバッファせず `http.ResponseWriter` に直接ストリーム書き込みできるため", "文字コードを自動変換するため", "`any` 型を受け取れるのは `Encoder` だけのため"]', 1, '`json.Marshal` は全データをメモリ上の `[]byte` に一度展開してから書き込みます。`json.NewEncoder(w).Encode` は `io.Writer`（ここでは `http.ResponseWriter`）に直接ストリーム出力するためメモリ効率が良いです。大きなレスポンスで特に有効です。', 'backend/main.go - writeJSON()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (160, 'セクション58: Go HTTP & CORS', 'io.LimitReader によるリクエストボディ制限', '以下のコードで `io.LimitReader(r.Body, 1<<20)` を使う理由はどれですか？', 'decoder := json.NewDecoder(io.LimitReader(r.Body, 1<<20))
decoder.DisallowUnknownFields()', '["JSONのパース速度を向上させるため", "1MB超のリクエストボディによるメモリ枯渇・DoS攻撃を防ぐため", "r.Body をコピーして再利用できるようにするため", "Content-Length ヘッダーの検証をするため"]', 1, '`1<<20` は 1MB（1,048,576バイト）です。制限なしで `r.Body` を読むと、巨大なボディを送りつけるDoS攻撃でサーバーメモリを枯渇させられます。`LimitReader` で上限を設けることで安全にボディを処理できます。', 'backend/main.go - decodeJSON()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (161, 'セクション58: Go HTTP & CORS', 'DisallowUnknownFields の効果', '`decoder.DisallowUnknownFields()` を設定した場合、JSONに未知フィールドが含まれていたときどうなりますか？', 'decoder := json.NewDecoder(io.LimitReader(r.Body, 1<<20))
decoder.DisallowUnknownFields()
if err := decoder.Decode(dst); err != nil {
    return err
}', '["未知フィールドは無視されてデコード成功", "デコードエラーが返される", "未知フィールドのみ別の変数に格納される", "パニックが発生する"]', 1, 'デフォルトでは `json.Decoder` は未知フィールドを無視します。`DisallowUnknownFields()` を呼ぶと、構造体に対応するフィールドが存在しないJSONキーがあった場合にエラーを返します。タイポや意図しないフィールドを早期検出するためのバリデーション手段です。', 'backend/main.go - decodeJSON()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (162, 'セクション58: Go HTTP & CORS', '2回目の Decode で io.EOF を確認', '以下のコードで2回目の `decoder.Decode(&extra)` を行う目的はどれですか？', 'if err := decoder.Decode(dst); err != nil {
    return err
}
var extra json.RawMessage
if err := decoder.Decode(&extra); err != io.EOF {
    return errors.New("request body must contain a single JSON object")
}', '["追加フィールドをキャプチャするため", "リクエストボディに複数のJSONオブジェクトが含まれていないか確認するため", "デコードのキャッシュをクリアするため", "r.Body を閉じるため"]', 1, '1回目の `Decode` 後に `io.EOF` 以外が返る場合、ボディにまだデータが残っています。`{...}{...}` のように複数のJSONオブジェクトを連結して送る攻撃や誤りを検出できます。正常なリクエストなら2回目の `Decode` は `io.EOF` を返します。', 'backend/main.go - decodeJSON()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (163, 'セクション58: Go HTTP & CORS', 'r.PathValue によるパスパラメータ取得', '以下のコードで `r.PathValue("id")` を使っています。これはGoのどのバージョンから使えますか？', 'func (s *server) handleGetQuiz(w http.ResponseWriter, r *http.Request) {
    quizID, err := parseID(r.PathValue("id"))
    if err != nil {
        writeError(w, http.StatusBadRequest, err.Error())
        return
    }
}', '["Go 1.18（Generics導入時）", "Go 1.20", "Go 1.22", "Go 1.19"]', 2, '`http.Request.PathValue` と `ServeMux` のパターンマッチング（`{id}` 記法）はGo 1.22で標準ライブラリに追加されました。それ以前はパスパラメータの取得に `gorilla/mux` や `chi` などサードパーティのルーターが必要でした。', 'backend/main.go - handleGetQuiz() / Go 1.22 release notes');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (164, 'セクション59: Go SQL & JSONB', 'sql.NullString の使い方', '以下のコードで `code` フィールドに `sql.NullString` を使っている理由はどれですか？', 'var item quiz
var code sql.NullString

err := scanner.Scan(
    &item.ID,
    // ...
    &code,
    // ...
)

if code.Valid {
    item.Code = &code.String
}', '["NullStringはStringより高速にスキャンできるため", "DBのNULL値をGoの nil として安全に扱うため", "Stringではマルチバイト文字を扱えないため", "sql.Scanがstring型を直接受け取れないため"]', 1, 'DBのカラムが NULL の場合、`string` に直接スキャンするとエラーになります。`sql.NullString` は `{String string; Valid bool}` を持ち、`Valid=false` のとき NULL を表します。スキャン後に `code.Valid` を確認して `*string`（nil or 値）に変換しています。', 'backend/main.go - scanQuiz()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (165, 'セクション59: Go SQL & JSONB', 'JSONB カラムのスキャン', '以下のコードで `options` を `[]byte` でスキャンしてから `json.Unmarshal` している理由はどれですか？', 'var optionsJSON []byte
err := scanner.Scan(
    // ...
    &optionsJSON,
    // ...
)
json.Unmarshal(optionsJSON, &item.Options)', '["[]stringには直接スキャンできないため、[]byteで受けてからGoの型に変換する", "PostgreSQLのJSONBはバイナリ形式で返されるため", "json.Unmarshalの方がsql.Scanより速いため", "[]stringはsql.Scanでnilになるため"]', 0, '`database/sql` は `[]string` 型への直接スキャンをサポートしていません。PostgreSQLのJSONBカラムをスキャンするには一旦 `[]byte` または `string` で受け取り、`json.Unmarshal` でGoの型に変換するのが標準的なパターンです。', 'backend/main.go - scanQuiz()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (166, 'セクション59: Go SQL & JSONB', 'ON CONFLICT DO NOTHING の使い所', '以下のSQLで `ON CONFLICT (id) DO NOTHING` を指定した場合の動作はどれですか？', 'INSERT INTO quizzes (id, section, title, ...)
VALUES ($1, $2, $3, ...)
ON CONFLICT (id) DO NOTHING;', '["同じidが存在するとエラーが発生する", "同じidが存在する場合は既存行を上書きする", "同じidが存在する場合はINSERTをスキップして正常終了する", "同じidが存在する場合はNULLを挿入する"]', 2, '`ON CONFLICT (id) DO NOTHING` は競合（主キー重複など）が発生した場合にエラーを発生させずスキップします。冪等なシード処理に適しています。上書きしたい場合は `ON CONFLICT DO UPDATE SET ...`（UPSERT）を使います。', 'backend/migrations/002_seed_quizzes.up.sql');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (167, 'セクション59: Go SQL & JSONB', 'RETURNING 句の活用', '以下のINSERT文で `RETURNING` 句を使っている理由はどれですか？', 'item, err := scanQuiz(s.db.QueryRow(`
    INSERT INTO quizzes (...)
    VALUES ($1, $2, ...)
    RETURNING
        id,
        section,
        created_at,
        updated_at
`, ...))', '["INSERTの実行確認のため", "INSERT後にSELECTを別途発行せずに挿入された行のデータを1回のクエリで取得するため", "トランザクションを自動コミットするため", "created_at のデフォルト値を上書きするため"]', 1, '`RETURNING` はINSERT/UPDATE/DELETEで変更された行のカラム値を返すPostgreSQL拡張です。`INSERT ... RETURNING id, created_at` とすることで、DB側で生成された `BIGSERIAL` のIDやデフォルト値 `NOW()` の `created_at` を別途SELECTなしで取得できます。', 'backend/main.go - handleCreateQuiz()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (168, 'セクション59: Go SQL & JSONB', 'rows.Err() の確認', '以下のコードで `rows.Close()` の後に `rows.Err()` を確認している理由はどれですか？', 'rows, err := s.db.Query(`SELECT ...`)
if err != nil { ... }
defer rows.Close()

for rows.Next() {
    // ...
}

if err := rows.Err(); err != nil {
    writeError(w, http.StatusInternalServerError, err.Error())
    return
}', '["rows.Closeのエラーを確認するため", "ループ中に発生したDBエラー（ネットワーク断など）を検出するため", "結果セットが空かどうかを確認するため", "rows.Nextの戻り値を再確認するため"]', 1, '`rows.Next()` がfalseを返した理由は「全行読み終わった」または「エラー発生」の2つです。`rows.Err()` でイテレーション中のエラーを確認しないと、DBサーバーとの通信断などで途中で切れた結果を正常として返してしまうバグが起きます。', 'backend/main.go - handleListQuizzes()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (169, 'セクション59: Go SQL & JSONB', 'sql.ErrNoRows の判定', '以下のコードで `errors.Is(err, sql.ErrNoRows)` を使っている理由はどれですか？', 'item, err := scanQuiz(s.db.QueryRow(`SELECT ... WHERE id = $1`, quizID))
if err != nil {
    if errors.Is(err, sql.ErrNoRows) {
        writeError(w, http.StatusNotFound, "quiz not found")
        return
    }
    writeError(w, http.StatusInternalServerError, err.Error())
    return
}', '["QueryRowは必ずエラーを返すため", "レコードが見つからない場合と内部エラーを区別して適切なHTTPステータスを返すため", "sql.ErrNoRowsはpanicを防ぐためのセンチネル値のため", "errors.Isを使わないと型アサーションが失敗するため"]', 1, '`db.QueryRow` はレコードが0件のとき `sql.ErrNoRows` を返します。これを区別しないと「存在しないID」へのリクエストに `500 Internal Server Error` を返してしまいます。`errors.Is` でエラーの種類を判定し、`404 Not Found` と `500` を正しく使い分けます。', 'backend/main.go - handleGetQuiz()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (170, 'セクション59: Go SQL & JSONB', 'setval でシーケンスをリセット', 'マイグレーションのシードSQL末尾にある以下のSQL文の目的はどれですか？', 'SELECT setval(''quizzes_id_seq'', (SELECT MAX(id) FROM quizzes));', '["シーケンスを1にリセットして最初からIDを採番し直すため", "INSERT後にシーケンスの現在値を最大IDに合わせ、次の自動採番が重複しないようにするため", "quizzes_id_seqテーブルを初期化するため", "MAX(id)の値をログに出力するため"]', 1, '`BIGSERIAL` のシーケンスは通常INSERTのたびにインクリメントされますが、`id` を明示指定したINSERT（シードデータ）ではシーケンスが進みません。このため次の通常INSERTが既存IDと重複する可能性があります。`setval` でシーケンスを `MAX(id)` に合わせることで重複を防ぎます。', 'backend/migrations/002_seed_quizzes.up.sql');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (171, 'セクション60: Go embed & golang-migrate', '//go:embed ディレクティブ', '以下のコードで `//go:embed migrations/*.sql` を使う目的はどれですか？', '//go:embed migrations/*.sql
var migrationsFS embed.FS', '["実行時にファイルシステムからSQLを読み込むため", "ビルド時にSQLファイルをバイナリに埋め込み、デプロイ時に別途ファイルを配置不要にするため", "SQLファイルを暗号化するため", "マイグレーションを自動実行するため"]', 1, '`//go:embed` はビルド時に指定したファイルをGoバイナリに埋め込みます。`migrations/*.sql` をバイナリに含めることで、デプロイ先サーバーにSQLファイルを別途配置する必要がなくなります。`embed.FS` は組み込みファイルへの読み取り専用アクセスを提供します。', 'backend/main.go / https://pkg.go.dev/embed');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (172, 'セクション60: Go embed & golang-migrate', 'migrate.ErrNoChange の処理', '以下のコードで `errors.Is(err, migrate.ErrNoChange)` を無視している理由はどれですか？', 'if err := m.Up(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
    return err
}
return nil', '["ErrNoChange はフォーマットエラーのため無視できる", "全マイグレーション適用済みの場合 ErrNoChange が返り、これはエラーではなく正常状態のため", "ErrNoChange はGoの標準エラーではないため比較できないから", "m.Up() は常にエラーを返すため"]', 1, '`m.Up()` は全マイグレーションが既に適用されている場合（追加変更なし）に `migrate.ErrNoChange` を返します。これはエラーではなく「何もすることがない」という正常な状態です。サーバー再起動のたびに `Up()` を呼ぶ構成ではこの処理が必須です。', 'backend/main.go - runMigrations()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (173, 'セクション60: Go embed & golang-migrate', 'schema_migrations テーブルの役割', 'golang-migrate が自動作成する `schema_migrations` テーブルの役割はどれですか？', '-- golang-migrate が内部で管理するテーブル
SELECT version, dirty FROM schema_migrations;
--  version | dirty
-- ---------+-------
--        2 | f', '["マイグレーションSQLの内容を保存するため", "どのバージョンのマイグレーションまで適用済みかを追跡するため", "ロールバック用にデータのスナップショットを保存するため", "マイグレーションの実行時間を記録するため"]', 1, '`schema_migrations` は適用済みマイグレーションのバージョン番号と `dirty`（失敗フラグ）を管理します。`version=2` なら `002_` までが適用済みを意味します。`dirty=true` はマイグレーション途中で失敗した状態を示し、手動修正が必要になります。', 'backend/main.go - runMigrations() / golang-migrate docs');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (174, 'セクション60: Go embed & golang-migrate', 'iofs.New の第2引数', '以下のコードで `iofs.New(migrationsFS, "migrations")` の第2引数 `"migrations"` は何を意味しますか？', 'srcDriver, err := iofs.New(migrationsFS, "migrations")', '["マイグレーション名のプレフィックス", "embed.FS 内でSQLファイルを探すディレクトリパス", "データベース名", "マイグレーションのバージョン番号"]', 1, '`iofs.New` の第2引数は `embed.FS` 内のどのディレクトリをルートとしてマイグレーションファイルを探すかを指定します。`//go:embed migrations/*.sql` で埋め込んだファイルは `migrations/` ディレクトリ構造で `embed.FS` に入るため、`"migrations"` を指定することで `001_create_tables.up.sql` 等が正しく検出されます。', 'backend/main.go - runMigrations()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (175, 'セクション60: Go embed & golang-migrate', 'up.sql と down.sql の命名規則', 'golang-migrate のファイル命名規則として正しいものはどれですか？', 'migrations/
  001_create_tables.up.sql
  001_create_tables.down.sql
  002_seed_quizzes.up.sql
  002_seed_quizzes.down.sql', '["{version}_{description}.{direction}.sql（バージョンは連番、direction は up または down）", "{description}_{version}.sql（方向はファイル内のコメントで指定）", "{version}.sql と {version}_rollback.sql のペア", "任意のファイル名でよく、ファイル内のコメントで方向を指定"]', 0, 'golang-migrate の標準命名規則は `{version}_{description}.{direction}.sql` です。`version` は数値の連番（`001`, `002`...）、`direction` は `up`（適用）または `down`（ロールバック）です。バージョン番号の順序でマイグレーションが実行されます。', 'backend/migrations/ / golang-migrate docs');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (176, 'セクション61: Go 環境変数 & サーバー構造体', 'getEnv のフォールバックパターン', '以下の `getEnv` 関数で環境変数が空文字列 `""` の場合、`fallback` が返されますか？', 'func getEnv(key, fallback string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return fallback
}', '["はい、空文字列は falsy として扱われ fallback が返る", "いいえ、空文字列は設定済みとして扱われ空文字列が返る", "os.Getenv は空文字列を返さない", "パニックが発生する"]', 0, '`value != ""` の条件なので、環境変数が設定されていても値が空文字列の場合は `fallback` が返ります。`os.Getenv` は未設定・空設定どちらも空文字列を返すため、この実装では「未設定」と「空文字列に設定」を区別しません。区別が必要なら `os.LookupEnv` を使います。', 'backend/main.go - getEnv()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (177, 'セクション61: Go 環境変数 & サーバー構造体', 'server 構造体への依存注入', '以下の `server` 構造体に `db`・`adminUser`・`jwtSecret` 等をフィールドとして持たせている設計上の利点はどれですか？', 'type server struct {
    db            *sql.DB
    adminUser     string
    adminPassword string
    jwtSecret     []byte
}

s := &server{
    db:            db,
    adminUser:     getEnv("ADMIN_USER", "admin"),
    adminPassword: getEnv("ADMIN_PASSWORD", "password"),
    jwtSecret:     []byte(getEnv("JWT_SECRET", "dev-only-secret")),
}', '["グローバル変数より読み書きが速いため", "テスト時にモックDBや異なる設定を注入しやすく、グローバル状態を避けられるため", "Goではメソッドに引数を渡せないため", "フィールドは自動的にgoroutine-safeになるため"]', 1, '依存関係を構造体フィールドに持たせる「依存性注入（DI）」パターンです。グローバル変数と違い、テスト時に `server{db: mockDB}` のように差し替えやすく、並行テストでの競合も避けられます。ハンドラがすべてメソッドとして `*server` に紐づくためコンテキストも明確です。', 'backend/main.go - server struct / main()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (178, 'セクション61: Go 環境変数 & サーバー構造体', 'jwtSecret を []byte で保持する理由', '`jwtSecret` を `string` ではなく `[]byte` で保持している理由はどれですか？', 'jwtSecret: []byte(getEnv("JWT_SECRET", "dev-only-secret")),

// 使用箇所
return token.SignedString(s.jwtSecret)', '["[]byteの方がメモリ効率が良いため", "jwt.SignedStringが[]byteを要求し、文字列より安全にゼロクリアできるため", "環境変数はバイト列で返されるため", "Goではstring型の比較ができないため"]', 1, '`jwt.Token.SignedString` はHMAC系アルゴリズムで `[]byte` を要求します。また `[]byte` はメモリ上でゼロクリア（`for i := range secret { secret[i] = 0 }`）が可能ですが、Goの `string` はイミュータブルなためクリアできません。シークレット情報を `[]byte` で扱うのはセキュリティ上の慣行です。', 'backend/main.go - server struct / issueJWT()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (179, 'セクション61: Go 環境変数 & サーバー構造体', 'defer db.Close() のタイミング', '以下のコードで `defer db.Close()` を呼んでいるとき、`db.Close()` が実行されるタイミングはどれですか？', 'db, err := initDB()
if err != nil {
    log.Fatal(err)
}
defer db.Close()

// ... サーバー起動
if err := http.ListenAndServe(":8080", s.routes()); err != nil {
    log.Fatal(err)
}', '["initDB() の直後", "main() 関数が返るとき（サーバーが停止したとき）", "各HTTPリクエスト処理後", "GCが実行されたとき"]', 1, '`defer` は宣言した関数（ここでは `main`）が返るときに実行されます。`http.ListenAndServe` はサーバーが停止するまでブロックするため、通常は `db.Close()` は呼ばれません。サーバーがシャットダウンしたとき（エラーまたはシグナル）に `main` が返り、`defer db.Close()` が実行されます。', 'backend/main.go - main()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (180, 'セクション61: Go 環境変数 & サーバー構造体', 'log.Fatal の動作', '`log.Fatal(err)` と `log.Print(err); os.Exit(1)` の動作の違いはどれですか？', 'db, err := initDB()
if err != nil {
    log.Fatal(err)
}', '["log.Fatal はパニックを起こすが log.Print はログのみ", "実質同じ動作（ログ出力 + os.Exit(1)）。ただし log.Fatal は defer を実行しない", "log.Fatal は終了コード 0 で終了する", "log.Fatal はゴルーチンをすべて待ってから終了する"]', 1, '`log.Fatal` は内部で `log.Print + os.Exit(1)` を呼びます。`os.Exit` は `defer` を実行せずに即終了します。そのため `defer db.Close()` が登録済みでも `log.Fatal` で終了すると実行されません。グレースフルシャットダウンが必要な場合は `os.Exit` を避け、エラーを上位に返す設計が推奨されます。', 'backend/main.go - main() / https://pkg.go.dev/log#Fatal');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (181, 'セクション62: Go バリデーション & 文字列処理', 'strings.TrimSpace の活用', '以下の `normalizeQuizPayload` で各フィールドに `strings.TrimSpace` を適用している理由はどれですか？', 'func normalizeQuizPayload(payload *quizPayload) error {
    payload.Section = strings.TrimSpace(payload.Section)
    payload.Title = strings.TrimSpace(payload.Title)
    payload.Question = strings.TrimSpace(payload.Question)
    // ...
    if payload.Section == "" {
        return errors.New("section is required")
    }
}', '["SQLインジェクションを防ぐため", "前後の空白のみのデータが「空」として正しく検出されるようにするため", "全角スペースを除去するため", "文字列を小文字に変換するため"]', 1, '`TrimSpace` なしで `"  "`（空白のみ）を `== ""` で比較すると空と判定されません。バリデーション前に `TrimSpace` を適用することで「空白のみ入力」を「空」として検出します。また `payload` はポインタ渡しなので `TrimSpace` 後の値が呼び出し元にも反映されます。', 'backend/main.go - normalizeQuizPayload()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (182, 'セクション62: Go バリデーション & 文字列処理', 'CorrectAnswerIndex の範囲チェック', '以下の範囲チェックで `payload.CorrectAnswerIndex >= len(payload.Options)` を含める理由はどれですか？', 'if payload.CorrectAnswerIndex < 0 || payload.CorrectAnswerIndex >= len(payload.Options) {
    return errors.New("correctAnswerIndex is out of range")
}', '["Goの配列は1始まりのため", "インデックスは0始まりなのでlen(options)はインデックスとして無効な値のため", "len()が負の値を返すことがあるため", "Options が空の場合のみチェックするため"]', 1, 'Goのスライスインデックスは0始まりなので、有効な範囲は `0` 〜 `len-1` です。`CorrectAnswerIndex == len(options)` は1つ外（out of bounds）になります。`< 0` と `>= len` の両方をチェックすることで配列外アクセスによるパニックを防ぎます。', 'backend/main.go - normalizeQuizPayload()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (183, 'セクション62: Go バリデーション & 文字列処理', 'parseID での strconv.ParseInt', '以下の `parseID` で `strconv.ParseInt(raw, 10, 64)` を使っている理由はどれですか？', 'func parseID(raw string) (int64, error) {
    id, err := strconv.ParseInt(raw, 10, 64)
    if err != nil || id <= 0 {
        return 0, errors.New("invalid quiz id")
    }
    return id, nil
}', '["URLパスパラメータは常に16進数のため", "パスパラメータは文字列なので10進整数として安全にパースし、quiz.ID（int64）型に合わせるため", "int32では値が溢れる可能性があるため、パフォーマンスのためにint64を使う", "strconvの方がfmtパッケージより速いため"]', 1, '`r.PathValue` は常に文字列を返すため数値変換が必要です。`ParseInt(raw, 10, 64)` の第2引数 `10` は10進数、第3引数 `64` はビットサイズ（`int64`）を指定します。`quiz.ID` が `int64` 型なので合わせています。また `id <= 0` チェックで負数や0の無効なIDを弾きます。', 'backend/main.go - parseID()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (184, 'セクション62: Go バリデーション & 文字列処理', 'options の空スライス初期化', '以下の `handleListQuizzes` で `make([]quiz, 0)` を使う理由はどれですか？', 'items := make([]quiz, 0)
for rows.Next() {
    item, err := scanQuiz(rows)
    // ...
    items = append(items, item)
}
writeJSON(w, http.StatusOK, items)', '["var items []quiz と全く同じため、どちらでもよい", "var で宣言するとnil スライスになりJSONで null になるが、make([]quiz, 0)は空配列 [] になるため", "make の方がappendのパフォーマンスが良いため", "nil スライスへの append はパニックになるため"]', 1, '`var items []quiz` は `nil` スライスを作るため `json.Marshal` すると `null` になります。`make([]quiz, 0)` は空（長さ0）の非nilスライスを作るため `[]` になります。クイズが0件のとき `null` ではなく `[]` を返す方がAPIクライアントにとって扱いやすいため、`make` を使っています。', 'backend/main.go - handleListQuizzes()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (185, 'セクション62: Go バリデーション & 文字列処理', 'code フィールドの nil 判定', '以下のコードで `payload.Code == ""` のとき `codeValue = nil` にしている理由はどれですか？', 'var codeValue any
if payload.Code == "" {
    codeValue = nil
} else {
    codeValue = payload.Code
}

item, err := scanQuiz(s.db.QueryRow(`
    INSERT INTO quizzes (..., code, ...) VALUES (..., $4, ...)
`, ..., codeValue, ...))', '["空文字列のSQLパラメータはエラーになるため", "DBスキーマでcodeはNULL許容（TEXT, not NOT NULL）なので、コードなしのクイズはNULLを格納するため", "PostgreSQLでは空文字列とNULLは同じ扱いのため", "nil を渡すとPostgreSQLが自動でDEFAULT値を使うため"]', 1, 'DBスキーマで `code TEXT`（`NOT NULL` なし）のため NULL が許容されます。コードブロックがないクイズで空文字列 `""` を格納するよりも `NULL` を格納する方が「値なし」の意味が明確です。Go の `nil` を `any` 型で渡すと `database/sql` が SQL の `NULL` に変換します。', 'backend/main.go - handleCreateQuiz() / handleUpdateQuiz()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (186, 'セクション62: Go バリデーション & 文字列処理', 'RowsAffected による削除確認', '以下の削除処理で `rowsAffected == 0` のとき 404 を返している理由はどれですか？', 'result, err := s.db.Exec(`DELETE FROM quizzes WHERE id = $1`, quizID)
rowsAffected, err := result.RowsAffected()
if rowsAffected == 0 {
    writeError(w, http.StatusNotFound, "quiz not found")
    return
}
writeJSON(w, http.StatusNoContent, nil)', '["DELETEは常に少なくとも1行削除するため0は異常", "存在しないIDへのDELETEはエラーを返さず0行削除するため、404で存在しないことを伝える", "rowsAffectedが0の場合DBエラーが発生するため", "PostgreSQLはrowsAffectedを返さないため"]', 1, '`DELETE WHERE id = $1` は条件に一致する行がなくてもエラーにならず、`RowsAffected()` が `0` を返します。クライアントに「そのIDは存在しなかった」と伝えるため `404 Not Found` を返します。削除成功時は `204 No Content`（ボディなし）がRESTの慣行です。', 'backend/main.go - handleDeleteQuiz()');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (187, 'セクション63: SPA と SEO', 'GoogleボットのJSレンダリング問題', 'Vite + React で構築したSPAをそのまま公開した場合、SEO上の問題として最も正確なものはどれですか？', '// SPAの初期HTML（Vite build 後）
<!DOCTYPE html>
<html>
  <head><title>Quiz App</title></head>
  <body>
    <div id="root"></div>
    <script type="module" src="/assets/index-abc123.js"></script>
  </body>
</html>', '["GoogleボットはJSを一切実行できないため、全コンテンツがインデックスされない", "GoogleボットはJSを実行できるが、クロールキューに入るまで遅延があり、インデックスが遅れたりコンテンツが見逃される可能性がある", "SPAはHTTPSでないとインデックスされない", "Viteのビルド出力はGoogleに対応していない"]', 1, 'GoogleボットはChromiumベースでJSを実行できますが、「第2波クロール」と呼ばれる遅延レンダリングキューに入るため、インデックス反映が数日〜数週間遅れることがあります。また動的に生成されるコンテンツが正しく解釈されない場合もあります。HTMLに最初からコンテンツが含まれているSSR/SSGと比べてSEO上不利です。', 'https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (188, 'セクション63: SPA と SEO', 'SSR と SSG の違い', 'Next.js における SSR（Server-Side Rendering）と SSG（Static Site Generation）の違いとして正しいものはどれですか？', '// SSR: リクエストのたびにサーバーでHTMLを生成
export async function getServerSideProps() {
  const data = await fetchQuizzes()
  return { props: { data } }
}

// SSG: ビルド時にHTMLを生成
export async function getStaticProps() {
  const data = await fetchQuizzes()
  return { props: { data } }
}', '["SSRはビルド時、SSGはリクエスト時にHTMLを生成する", "SSRはリクエスト時にサーバーでHTMLを生成し、SSGはビルド時にHTMLを生成する", "SSRとSSGは同じもので、フレームワークによって名称が異なる", "SSGはJavaScriptを使わない静的サイトのことで、Reactは使えない"]', 1, 'SSRはリクエストのたびにサーバーがHTMLを生成して返すため、常に最新データを返せますがサーバー負荷がかかります。SSGはビルド時に全ページのHTMLを生成するため高速・低コストですが、データ更新にはリビルドが必要です。クイズ一覧のような更新頻度の低いコンテンツはSSGが適しています。', 'https://nextjs.org/docs/pages/building-your-application/rendering');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (189, 'セクション63: SPA と SEO', 'Core Web Vitals とSEO', 'Google検索のランキング要因になっている Core Web Vitals の3指標として正しい組み合わせはどれですか？', '// Lighthouseで計測できる主要指標
// LCP: ページ内の最大コンテンツが表示されるまでの時間
// CLS: レイアウトのズレ（累積レイアウトシフト）
// INP: ユーザー操作に対する応答性（旧FID）', '["FCP・TTI・TBT", "LCP・CLS・INP", "TTFB・FCP・TTI", "SEO・Performance・Accessibility"]', 1, 'Core Web Vitals は LCP（Largest Contentful Paint）・CLS（Cumulative Layout Shift）・INP（Interaction to Next Paint、2024年3月にFIDから移行）の3指標です。Googleは2021年よりこれらを検索ランキングの要因に組み込んでいます。SPAはJSバンドルが大きくなりがちなためLCPが悪化しやすい点に注意が必要です。', 'https://web.dev/articles/vitals');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (190, 'セクション63: SPA と SEO', 'React SPA から Next.js への移行の主なメリット', 'Vite + React SPA を Next.js に移行する最大のSEO上のメリットはどれですか？', '// Before: SPAの初期HTML
<div id="root"></div> // コンテンツなし

// After: Next.js SSGの初期HTML
<h1>Reactの基礎</h1>
<p>以下の問題に答えてください...</p>
// コンテンツがHTMLに含まれる', '["TypeScriptが使えるようになる", "初期HTMLにコンテンツが含まれるためGoogleボットがJSレンダリングを待たずにインデックスできる", "CSSのバンドルサイズが小さくなる", "APIルートが使えるためバックエンドが不要になる"]', 1, 'Next.js のSSR/SSGでは初期レスポンスのHTMLにすでにコンテンツが含まれます。Googleボットはこれを即座にパースしてインデックスできるため、SPAの「遅延レンダリング問題」が解消されます。クイズタイトル・問題文・解説がHTMLに含まれることで、検索結果にコンテンツが反映されやすくなります。', 'https://nextjs.org/docs/pages/building-your-application/rendering/server-side-rendering');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (191, 'セクション63: SPA と SEO', '動的メタタグと og:title', 'クイズ詳細ページ（`/quizzes/123`）でSNSシェア時に正しいタイトルを表示するために必要な対応はどれですか？', '// SPAでは全ページ共通のmetaになってしまう
<meta property="og:title" content="Quiz App" />

// Next.jsではページごとに動的に設定できる
export const metadata = {
  title: quiz.title,
  openGraph: { title: quiz.title }
}', '["JavaScriptでdocument.titleを書き換えれば十分", "SNSクローラーはJSを実行しないため、SSR/SSGでHTMLにog:titleを埋め込む必要がある", "og:titleはGoogleのみが参照するためSEOには影響しない", "React HelmetでSPAでも同じ効果が得られる"]', 1, 'Twitter・Facebook等のSNSクローラーはJavaScriptを実行せず、HTMLのみを解析します。SPAでJSから `og:title` を動的に設定しても、クローラーには初期HTMLの値しか見えません。Next.jsのSSR/SSGでは各ページのHTMLに正しい `og:title` が埋め込まれるため、シェア時に適切なプレビューが表示されます。', 'https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (192, 'セクション63: SPA と SEO', 'sitemap.xml の役割', 'クイズアプリに `sitemap.xml` を設置する目的として正しいものはどれですか？', '<!-- sitemap.xml の例 -->
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://example.com/quizzes/1</loc>
    <lastmod>2026-04-07</lastmod>
  </url>
  <url>
    <loc>https://example.com/quizzes/2</loc>
    <lastmod>2026-04-07</lastmod>
  </url>
</urlset>', '["サイトのデザインをGoogleに伝えるため", "GoogleボットにクロールすべきURLを明示的に伝え、インデックス漏れを防ぐため", "sitemap.xml があるとCore Web Vitalsのスコアが上がるため", "ユーザーへのナビゲーションメニューを提供するため"]', 1, '`sitemap.xml` はGoogleボットにサイト内の全URLを伝えるファイルです。特に内部リンクが少ないページや新しいコンテンツをGoogleに発見させる手助けになります。クイズが100問以上ある場合、全問題ページのURLをsitemapに列挙することで、クロール漏れを防げます。Next.jsでは `next-sitemap` パッケージで自動生成できます。', 'https://developers.google.com/search/docs/crawling-indexing/sitemaps/overview');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (193, 'セクション63: SPA と SEO', '構造化データ（Quiz スキーマ）', 'クイズアプリで以下のような構造化データを設置する目的はどれですか？', '{
  "@context": "https://schema.org",
  "@type": "Quiz",
  "name": "useEffect 依存配列と関数参照",
  "hasPart": [{
    "@type": "Question",
    "text": "以下のコードについて、最も正しい説明はどれですか？",
    "acceptedAnswer": {
      "@type": "Answer",
      "text": "useCallbackでfetchUserを安定化し..."
    }
  }]
}', '["Googleがページをブロックしないようにするため", "Googleがコンテンツの意味を理解しやすくなり、リッチリザルト（検索結果での特別な表示）が得られる可能性があるため", "ページの読み込み速度を向上させるため", "構造化データはアクセシビリティのためのものでSEOとは無関係"]', 1, '構造化データ（JSON-LD形式のschema.org）を設置するとGoogleがコンテンツの種類・意味を機械的に理解できます。QuizやQ&Aスキーマを使うと検索結果ページにリッチリザルト（問題文や回答が直接表示）が表示される可能性があり、クリック率の向上が期待できます。', 'https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (194, 'セクション64: CSR を示すコード読解', 'createRoot はCSRの証拠', '以下の `main.tsx` のコードがCSR（クライアントサイドレンダリング）であることを示す根拠はどれですか？', '// main.tsx
const rootElement = document.getElementById(''root'')
if (!rootElement) throw new Error(''Root element #root not found'')

createRoot(rootElement).render(
  <StrictMode>
    <App />
  </StrictMode>,
)', '["StrictMode を使っているため", "document.getElementById と createRoot によりブラウザのDOMにReactツリーをマウントしており、サーバーではなくブラウザ上でレンダリングが行われるため", "StrictModeはサーバーでは動作しないため", "App コンポーネントをラップしているため"]', 1, '`document.getElementById` は `document` オブジェクトを参照しており、これはブラウザ環境のみに存在します。`createRoot` でブラウザのDOM要素にReactをマウントすることがCSRの本質です。SSRでは `hydrateRoot` を使い、サーバーで生成済みのHTMLにイベントを付与します。', 'admin-web/src/main.tsx');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (195, 'セクション64: CSR を示すコード読解', 'BrowserRouter はCSRのルーター', '以下の `App.tsx` で `BrowserRouter` を使っていることがCSRを示す理由はどれですか？', '// App.tsx
import { BrowserRouter, Navigate, Route, Routes } from ''react-router-dom''

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/quizzes" element={<QuizListPage />} />
        {/* ... */}
      </Routes>
    </BrowserRouter>
  )
}', '["BrowserRouter は React Router v6 以降でしか使えないため", "BrowserRouter は window.history API を使ってブラウザ上でルーティングを管理するため、サーバーではなくブラウザがページ遷移を制御するCSRの仕組み", "Routes コンポーネントはサーバーで動作しないため", "BrowserRouter を使うと自動的にSSRが無効になるため"]', 1, '`BrowserRouter` は `window.history.pushState` を使ってURLを書き換え、ブラウザ側でルーティングを管理します。Next.jsではサーバーが各URLに対応するHTMLを返しますが、SPAではどのURLへのアクセスも同じ `index.html` を返し、その後JavaScriptがURLに応じたコンポーネントを表示します。', 'admin-web/src/App.tsx');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (196, 'セクション64: CSR を示すコード読解', 'useEffect + fetch はCSRのデータ取得', '以下の `ViewCounter.tsx` のデータ取得パターンがCSRであることを示す根拠はどれですか？', '// ViewCounter.tsx
useEffect(() => {
  const fetchViews = async () => {
    const res = await fetch(API_URL)
    const data = await res.json()
    setCount(data.count)
  }
  fetchViews()
}, [])', '["useEffect はサーバーで実行されないため、データ取得がブラウザ上でマウント後に行われる", "fetch はブラウザAPIのため", "async/await はサーバーで使えないため", "setCount はブラウザのみで動作するため"]', 0, '`useEffect` はコンポーネントのマウント後（ブラウザ上）にのみ実行されます。サーバーサイドでは実行されません。このため初期HTMLには `count` の値が含まれず、ブラウザでJSが実行されて初めてデータが表示されます。SSGなら `getStaticProps`、SSRなら `getServerSideProps` でビルド時・リクエスト時にデータを取得してHTMLに埋め込みます。', 'admin-web/src/components/ViewCounter.tsx');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (197, 'セクション64: CSR を示すコード読解', 'window.localStorage はブラウザ専用API', '以下の `session.ts` のコードがCSR環境前提である証拠はどれですか？', '// auth/session.ts
const TOKEN_STORAGE_KEY = ''quiz-admin-token''

export function getAuthToken(): string | null {
  return window.localStorage.getItem(TOKEN_STORAGE_KEY)
}

export function setAuthToken(token: string): void {
  window.localStorage.setItem(TOKEN_STORAGE_KEY, token)
}', '["localStorage は文字列のみ保存できるため", "window.localStorage はブラウザ専用APIであり、Node.js（SSR）環境では window が存在しないためエラーになる", "TOKEN_STORAGE_KEY を定数にしているため", "getAuthToken が null を返す可能性があるため"]', 1, '`window.localStorage` はブラウザ専用のWeb APIです。Next.jsのSSR環境（Node.js）では `window` は未定義のため、このコードをサーバーサイドで実行すると `ReferenceError: window is not defined` が発生します。Next.jsに移行する場合、`typeof window !== ''undefined''` のガードや `useEffect` 内への移動が必要です。', 'admin-web/src/auth/session.ts');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (198, 'セクション64: CSR を示すコード読解', 'isLoading state はCSRのUXパターン', '以下の `QuizListPage.tsx` で `isLoading` state が必要になる根本的な理由はどれですか？', '// QuizListPage.tsx
const [quizzes, setQuizzes] = useState<Quiz[]>([])
const [isLoading, setIsLoading] = useState(true)

// ...
{isLoading ? (
  <div>読み込み中...</div>
) : (
  <table>...</table>
)}', '["useState の初期値に空配列を使っているため", "CSRではページ表示後にブラウザからAPIを叩くため、データ取得中の空白期間が生まれUXのためローディング表示が必要になる", "React の仕様でテーブルは非同期でレンダリングされるため", "APIが遅いため"]', 1, 'CSRではブラウザがJSを実行してからAPIリクエストを送るため、必ずデータ取得前の「空の状態」が存在します。SSGであればビルド時にデータ取得済みのHTMLが返るため、初期表示時にローディング状態が不要になります。`isLoading` の存在自体がCSRのデータ取得パターンの証拠です。', 'admin-web/src/pages/QuizListPage.tsx');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (199, 'セクション64: CSR を示すコード読解', 'ProtectedRoute はクライアント側認証', '以下の `ProtectedRoute` コンポーネントがCSR前提である理由はどれですか？', '// components/ProtectedRoute.tsx
import { Navigate } from ''react-router-dom''
import { getAuthToken } from ''../auth/session''

export default function ProtectedRoute({ children }) {
  if (!getAuthToken()) {
    return <Navigate to="/login" replace />
  }
  return children
}', '["Navigate コンポーネントを使っているため", "getAuthToken() が window.localStorage を参照しており、認証チェックがブラウザ上のJS実行時に行われるため、サーバーでは保護できない", "children props を受け取っているため", "replace オプションを使っているため"]', 1, '`getAuthToken()` は `window.localStorage` を参照するCSRの実装です。SSRでは初期HTMLレスポンス時点でサーバー側が認証状態を確認してリダイレクトできますが、この実装ではブラウザでJSが実行されるまで保護ページのHTMLが一瞬表示される可能性（フラッシュ）があります。Next.jsではMiddlewareやサーバーコンポーネントでサーバー側認証が可能です。', 'admin-web/src/components/ProtectedRoute.tsx');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (200, 'セクション64: CSR を示すコード読解', 'Next.js移行時の window 対応', 'CSRの `session.ts` を Next.js に移行する際、`window.localStorage` が原因でSSRエラーになる場合の正しい対処法はどれですか？', '// 現在のコード（SSR環境でエラー）
export function getAuthToken(): string | null {
  return window.localStorage.getItem(''quiz-admin-token'')
}

// Next.js 移行後の対応例
export function getAuthToken(): string | null {
  if (typeof window === ''undefined'') return null
  return window.localStorage.getItem(''quiz-admin-token'')
}', '["window を global に置き換える", "typeof window === ''undefined'' でサーバー実行時を判定してnullを返す", "localStorage を sessionStorage に置き換える", "useEffect 内でのみ localStorage を使い、それ以外では Cookie を使う"]', 1, '`typeof window === ''undefined''` はサーバーサイド（Node.js）では `true` になります。このガードを追加することでSSRビルドエラーを回避できます。より本格的な対応としては、Cookie-based認証に切り替えてサーバーサイドでもトークンを読めるようにする方法が推奨されます（Next.js の `cookies()` API等）。', 'admin-web/src/auth/session.ts / Next.js migration');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (201, 'セクション65: React Router v7 移行', 'Viteプラグインの変更', '現在のプロジェクトを React Router v7 フレームワークモードに移行するとき `vite.config.ts` の変更として正しいものはどれですか？', '// 移行前
import react from ''@vitejs/plugin-react''
import { defineConfig } from ''vite''

export default defineConfig({
  plugins: [react()]
})

// 移行後
import { reactRouter } from ''@react-router/dev/vite''
import { defineConfig } from ''vite''

export default defineConfig({
  plugins: [reactRouter()]
})', '["@vitejs/plugin-react を残したまま reactRouter() を追加する", "@vitejs/plugin-react を削除し reactRouter() に置き換える", "vite.config.ts は変更不要で package.json のみ変更する", "reactRouter() は vite.config.ts ではなく react-router.config.ts に書く"]', 1, '`reactRouter()` は `@react-router/dev/vite` が提供するViteプラグインで、`@vitejs/plugin-react` の機能を内包しています。両方を同時に使うと競合するため、`@vitejs/plugin-react` を削除して置き換えます。合わせて `npm install -D @react-router/dev` と `npm install @react-router/node` が必要です。', 'https://reactrouter.com/upgrading/component-routes');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (202, 'セクション65: React Router v7 移行', 'createRoot から hydrateRoot への変更', 'React Router v7 フレームワークモードに移行するとき `main.tsx` の変更として正しいものはどれですか？', '// 移行前 (main.tsx)
import { createRoot } from ''react-dom/client''
createRoot(document.getElementById(''root'')!).render(
  <StrictMode><App /></StrictMode>
)

// 移行後 (entry.client.tsx)
import { hydrateRoot } from ''react-dom/client''
import { HydratedRouter } from ''react-router/dom''

hydrateRoot(
  document,
  <StrictMode><HydratedRouter /></StrictMode>
)', '["createRoot のまま App を HydratedRouter に変えるだけでよい", "createRoot を hydrateRoot に変え、App を HydratedRouter に置き換え、マウント対象を document 全体にする", "main.tsx は削除してよく、entry.client.tsx は自動生成される", "hydrateRoot は SSR が有効なときのみ必要で、SPA モードなら createRoot のまま"]', 1, '`hydrateRoot` はサーバーで生成済みのHTMLにReactのイベントを付与（ハイドレーション）します。`createRoot` は空のDOMにゼロからレンダリングするCSRの方式です。マウント対象が `document.getElementById(''root'')` から `document` 全体になる点も重要な変更です。`<HydratedRouter>` がルーティングを管理するため `<App>` は不要になります。', 'https://reactrouter.com/upgrading/component-routes');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (203, 'セクション65: React Router v7 移行', 'BrowserRouter から routes.ts への移行', '現在の `App.tsx` のルート定義を React Router v7 の `routes.ts` に移行したとき、正しい記述はどれですか？', '// 移行前 App.tsx
<Routes>
  <Route path="/quizzes" element={<QuizListPage />} />
  <Route path="/quizzes/new" element={<QuizFormPage mode="create" />} />
  <Route path="/quizzes/:id/edit" element={<QuizFormPage mode="edit" />} />
  <Route path="/login" element={<LoginPage />} />
</Routes>

// 移行後 routes.ts
import { type RouteConfig, route } from ''@react-router/dev/routes''

export default [
  route(''/quizzes'', ''./pages/QuizListPage.tsx''),
  route(''/quizzes/new'', ''./pages/QuizFormPage.tsx''),
  route(''/quizzes/:id/edit'', ''./pages/QuizFormPage.tsx''),
  route(''/login'', ''./pages/LoginPage.tsx''),
] satisfies RouteConfig', '["routes.ts では element プロパティで JSX を直接渡す", "routes.ts ではファイルパスの文字列でルートモジュールを指定し、コンポーネントは各ファイルの default export になる", "routes.ts は JSON 形式で記述する", "BrowserRouter を残したまま routes.ts を追加できる"]', 1, 'React Router v7 の `routes.ts` ではJSXではなくファイルパスの文字列でルートを定義します。各ページファイルが「ルートモジュール」となり、`default export` がコンポーネント、`loader` がデータ取得、`action` がフォーム送信処理を担います。自動コード分割もこの構造によって実現されます。', 'https://reactrouter.com/upgrading/component-routes');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (204, 'セクション65: React Router v7 移行', 'loader によるSSRデータ取得', '現在の `QuizListPage.tsx` の `useEffect` + `fetch` によるデータ取得を React Router v7 の `loader` に移行したとき、SEO上の利点はどれですか？', '// 移行前: CSR（useEffect内でデータ取得）
useEffect(() => {
  void loadQuizzes()
}, [loadQuizzes])

// 移行後: SSR（loaderでサーバー取得）
export async function loader() {
  const quizzes = await listQuizzes()
  return { quizzes }
}

export default function QuizListPage({ loaderData }) {
  const { quizzes } = loaderData
  // isLoading state が不要になる
  return <table>...</table>
}', '["loader は並列実行されるためパフォーマンスが上がる", "初期HTMLにクイズデータが含まれるためGoogleボットがJSを待たずにインデックスでき、isLoading状態も不要になる", "loader はキャッシュが自動で効くためAPIリクエストが減る", "loader はTypeScriptの型推論が強化されるためバグが減る"]', 1, '`loader` はサーバーサイドで実行されるため、レスポンスのHTMLにクイズデータが含まれます。Googleボットはこれを即座にインデックスできます。また `useEffect` でのデータ取得がなくなるため `isLoading` state も不要になり、コードがシンプルになります。', 'https://reactrouter.com/upgrading/component-routes');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (205, 'セクション65: React Router v7 移行', 'react-router.config.ts の ssr オプション', '以下の `react-router.config.ts` で `ssr: false` と `ssr: true` の違いはどれですか？', '// SPA モード（移行初期段階）
export default {
  ssr: false,
} satisfies Config

// SSR モード（本格対応）
export default {
  ssr: true,
  async prerender() {
    return [''/'', ''/quizzes'']
  },
} satisfies Config', '["ssr: false はビルドが速くなるだけで動作は同じ", "ssr: false はCSRのまま（既存SPAと同等）で移行の足がかりになり、ssr: true にするとSSR/SSGが有効になる", "ssr: true にするとReact Server Componentsが使えるようになる", "ssr: false は開発環境のみ有効でプロダクションでは自動でtrueになる"]', 1, '`ssr: false` はSPAモードで、フレームワーク機能（routes.ts、loader等）は使えますがサーバーレンダリングはしません。既存SPAからの段階的移行の足がかりとして使えます。`ssr: true` にするとサーバーレンダリングが有効になります。`prerender` で特定URLを静的HTML生成（SSG相当）することもできます。', 'https://reactrouter.com/upgrading/component-routes');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (206, 'セクション65: React Router v7 移行', 'root.tsx の役割', 'React Router v7 の `root.tsx` に含まれる `<Scripts />` コンポーネントの役割はどれですか？', '// src/root.tsx
import { Links, Meta, Outlet, Scripts, ScrollRestoration } from ''react-router''

export function Layout({ children }) {
  return (
    <html lang="ja">
      <head>
        <Meta />
        <Links />
      </head>
      <body>
        {children}
        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  )
}', '["外部CDNのスクリプトを読み込む", "Viteがバンドルしたクライアント側JavaScriptをHTMLに挿入し、ハイドレーションを可能にする", "Google Analyticsを自動挿入する", "サーバーサイドのスクリプトを実行する"]', 1, '`<Scripts />` はViteがビルドしたJSバンドルを `<script>` タグとして自動挿入するコンポーネントです。これがないとブラウザにJSが読み込まれずインタラクティブなUIが動きません。`<Meta />` はルートの `meta` エクスポート、`<Links />` はCSSリンク、`<ScrollRestoration />` はナビゲーション時のスクロール位置復元を担います。', 'https://reactrouter.com/upgrading/component-routes');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (207, 'セクション65: React Router v7 移行', 'catchall.tsx による段階的移行', '移行初期に `routes.ts` で `route(''*?'', ''catchall.tsx'')` を定義し、`catchall.tsx` で既存の `<App>` を返す理由はどれですか？', '// routes.ts（移行初期）
export default [
  route(''*?'', ''catchall.tsx''),
] satisfies RouteConfig

// catchall.tsx
import App from ''./App''
export default function Component() {
  return <App />
}', '["App.tsx を削除するための準備として使う", "既存の Routes/BrowserRouter をそのまま動かしながらフレームワークモードに移行し、その後ルートを1つずつ routes.ts に移行できる", "catchall は 404 ページ専用の規約のため", "全 URL を App にフォールバックすることでSSRが自動有効になる"]', 1, 'catchall（`*?`）で全URLを既存の `<App>` に委譲することで、フレームワークモードへの移行初日から既存機能を壊さず動かせます。その後 `routes.ts` にルートを1つずつ追加し、`App.tsx` の対応する `<Route>` を削除していく段階的移行が可能です。ドキュメントでも「最初の数ルートが最も大変」と記載されています。', 'https://reactrouter.com/upgrading/component-routes');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (208, 'セクション66: SWR & コード分割', 'SWR のキャッシュキー', '以下の `useQuizzes` カスタムフックで `useSWR` の第1引数 `''/api/admin/quizzes''` が果たす役割はどれですか？', 'export function useQuizzes() {
  const { data, error, isLoading, mutate } = useSWR<Quiz[]>(
    ''/api/admin/quizzes'',
    () => listQuizzes(),
    {
      revalidateOnFocus: false,
      revalidateOnReconnect: true,
    },
  )
  return { quizzes: data ?? [], errorMessage: error instanceof Error ? error.message : null, isLoading, mutate }
}', '["fetch に渡す URL", "SWR がデータをキャッシュ・重複排除するためのキーで、同じキーを使うコンポーネントはキャッシュを共有する", "ローカルストレージの保存キー", "API のエンドポイントを自動検出するための型情報"]', 1, 'SWR の第1引数はキャッシュキーです。同じキーを持つ `useSWR` は複数のコンポーネントから呼ばれてもリクエストが1回に重複排除（dedup）されます。第2引数の fetcher 関数が実際のデータ取得を行うため、キーはURLである必要はありませんが、慣習的にAPIパスを使います。', 'admin-web/src/hooks/useQuizzes.ts / https://swr.vercel.app/docs/getting-started');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (209, 'セクション66: SWR & コード分割', 'revalidateOnFocus: false の効果', '`revalidateOnFocus: false` を指定する理由として最も適切なものはどれですか？', 'useSWR<Quiz[]>(
  ''/api/admin/quizzes'',
  () => listQuizzes(),
  {
    revalidateOnFocus: false,
    revalidateOnReconnect: true,
  },
)', '["フォーカスイベントが発生するたびにフェッチすると入力中のフォームがリセットされるため", "タブ切り替えのたびに不要なAPIリクエストが発生し、管理画面では頻繁な再取得が不要なため", "revalidateOnFocus はモバイルブラウザで動作しないため", "false にしないと SWR のキャッシュが無効になるため"]', 1, 'SWR はデフォルトでブラウザタブにフォーカスが戻るたびにデータを再取得します。管理画面のクイズ一覧ではタブ切り替えのたびにAPIを叩く必要はありません。`revalidateOnReconnect: true` はネットワーク復帰時の再取得で、オフライン→オンラインの遷移では再取得が有用です。', 'admin-web/src/hooks/useQuizzes.ts / https://swr.vercel.app/docs/revalidation');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (210, 'セクション66: SWR & コード分割', 'mutate による楽観的更新', '以下の削除処理で `mutate(filteredData, false)` の第2引数 `false` の意味はどれですか？', 'await deleteQuiz(quizToDelete.id)
await mutate(
  quizzes.filter((quiz) => quiz.id !== quizToDelete.id),
  false
)', '["エラーハンドリングを無効にする", "キャッシュを更新した後にサーバーへの再検証（再フェッチ）をスキップする", "mutate の戻り値を Promise ではなく boolean にする", "削除操作をキャンセルする"]', 1, '`mutate(data, false)` の第2引数は `revalidate` オプションです。`false` にするとローカルキャッシュを更新するだけでサーバーへの再フェッチを行いません。すでに `deleteQuiz` でサーバーの削除は完了しているため、改めてリスト全体を取得し直す必要がなく、UIが即座に反映されます。', 'admin-web/src/pages/QuizListPage.tsx / https://swr.vercel.app/docs/mutation');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (211, 'セクション66: SWR & コード分割', 'SWR 導入で削除されたコード', 'SWR 導入前の `QuizListPage` にあった以下のコードのうち、SWR 導入後に不要になったのはどれですか？', 'const [quizzes, setQuizzes] = useState<Quiz[]>([])
const [isLoading, setIsLoading] = useState(true)
const [errorMessage, setErrorMessage] = useState<string | null>(null)

const loadQuizzes = useCallback(async () => {
  setIsLoading(true)
  setErrorMessage(null)
  try {
    const items = await listQuizzes()
    setQuizzes(items)
  } catch (error) {
    setErrorMessage(getErrorMessage(error))
  } finally {
    setIsLoading(false)
  }
}, [navigate])

useEffect(() => {
  void loadQuizzes()
}, [loadQuizzes])', '["useState の deleteErrorMessage のみ", "quizzes・isLoading・errorMessage の3つの useState と、loadQuizzes の useCallback と、useEffect のすべて", "useEffect のみ", "useState のみ"]', 1, 'SWR は `data`（quizzes）・`isLoading`・`error` を内部で管理し、マウント時の自動フェッチも行います。そのため `useState` x3 + `useCallback` + `useEffect` の計5つのフックが `useQuizzes()` の1行に置き換わりました。削除関連の `deleteErrorMessage`・`quizToDelete`・`isDeleting` は SWR とは無関係なため残ります。', 'admin-web/src/pages/QuizListPage.tsx / admin-web/src/hooks/useQuizzes.ts');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (212, 'セクション66: SWR & コード分割', 'React.lazy によるコード分割', '以下のコードで `lazy(() => import(''./pages/QuizListPage''))` を使ったとき、ビルド出力にどのような変化が起きますか？', '// 変更前: 静的インポート
import QuizListPage from ''./pages/QuizListPage''
import QuizFormPage from ''./pages/QuizFormPage''

// 変更後: 動的インポート
const QuizListPage = lazy(() => import(''./pages/QuizListPage''))
const QuizFormPage = lazy(() => import(''./pages/QuizFormPage''))', '["ビルド出力に変化はない", "QuizListPage と QuizFormPage が別チャンクに分離され、該当ページへの遷移時に初めてダウンロードされる", "全ページが1つのチャンクにまとめられてバンドルサイズが増える", "lazy を使うと開発時のHMRが無効になる"]', 1, '`React.lazy` + 動的 `import()` により Vite がページ単位の別チャンクを生成します。実際のビルド出力では `QuizListPage-xxx.js`（261KB）と `QuizFormPage-xxx.js`（8KB）が分離され、初期バンドル `index-xxx.js`（304KB）には含まれません。ログインページを開いたときにクイズ関連のJSをダウンロードしなくて済み、初期表示が高速化します。', 'admin-web/src/App.tsx');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (213, 'セクション66: SWR & コード分割', 'Suspense の fallback', '以下の `Suspense` の `fallback` が表示されるのはどのタイミングですか？', '<Suspense fallback={<div>読み込み中...</div>}>
  <Routes>
    <Route path="/quizzes" element={<QuizListPage />} />
  </Routes>
</Suspense>', '["QuizListPage が API からデータを取得している間", "React.lazy で分割されたチャンク（QuizListPage の JS ファイル）がダウンロード完了するまで", "React の初回レンダリング中に常に表示される", "エラーが発生したときのフォールバック表示"]', 1, '`Suspense` は `React.lazy` で分割されたコンポーネントのJSチャンクがネットワークからダウンロードされるまでの間に `fallback` を表示します。一度ダウンロードされればキャッシュされるため、2回目以降は fallback は表示されません。APIのデータ取得待ちは SWR の `isLoading` で別途ハンドリングします。', 'admin-web/src/App.tsx / https://react.dev/reference/react/Suspense');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (214, 'セクション66: SWR & コード分割', 'data ?? [] の nullish coalescing', '以下のコードで `data ?? []` を使っている理由はどれですか？', 'const { data, error, isLoading, mutate } = useSWR<Quiz[]>(
  ''/api/admin/quizzes'',
  () => listQuizzes(),
)

return {
  quizzes: data ?? [],
}', '["data が空配列 [] のとき [] に変換するため", "data が undefined（初回フェッチ前）のとき空配列を返すことで、呼び出し側で undefined チェックを不要にするため", "data が null のとき SWR がエラーを投げるのを防ぐため", "TypeScript の型エラーを回避するためのキャスト"]', 1, 'SWR の `data` は初回フェッチが完了するまで `undefined` です。`??`（nullish coalescing）は左辺が `null` または `undefined` のとき右辺を返します。これにより `useQuizzes()` の戻り値 `quizzes` は常に `Quiz[]` 型が保証され、呼び出し側で `quizzes?.map(...)` のようなオプショナルチェーンが不要になります。', 'admin-web/src/hooks/useQuizzes.ts');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (215, 'セクション67: Tailwind CSS レイアウト', 'min-h-screen の役割', '以下の `AdminLayout` で外側の `<div>` に `min-h-screen` を付けている目的はどれですか？', '// AdminLayout.tsx
<div className="min-h-screen">
  <header>ナビゲーション</header>
  <main>
    <Outlet />
  </main>
</div>

// min-h-screen なしの場合:
// ┌──────────────────────┐ ← 画面の上端
// │ header               │
// ├──────────────────────┤
// │ main（短いコンテンツ）│
// ├──────────────────────┤ ← div がここで終わる
// │                      │
// │ （背景色が届かない） │
// │                      │
// └──────────────────────┘ ← 画面の下端
//
// min-h-screen ありの場合:
// ┌──────────────────────┐ ← 画面の上端
// │ header               │
// ├──────────────────────┤
// │ main（短いコンテンツ）│
// │                      │
// │ （div が画面下端まで  │
// │   伸びている）        │
// │                      │
// └──────────────────────┘ ← 画面の下端 = div の下端', '["header を画面上部に固定するため", "コンテンツが少なくても div がビューポート全体の高さを確保し、背景色やレイアウトが画面下端まで適用されるようにするため", "スクロールバーを常に表示するため", "main の幅を画面幅に合わせるため"]', 1, '`min-h-screen` は `min-height: 100vh` に相当し、「この要素の高さは最低でもビューポート（画面）と同じにする」という意味です。クイズが0件など中身が短い場合でも、外側の `<div>` が画面下端まで伸びるため背景色やレイアウトが途切れません。中身が画面より長い場合は自然にスクロールされます。', 'admin-web/src/layouts/AdminLayout.tsx / https://tailwindcss.com/docs/min-height');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (216, 'セクション67: Tailwind CSS レイアウト', 'sticky top-0 の動作', '以下の `header` に付いている `sticky top-0` の動作はどれですか？', '<header className="sticky top-0 z-10 border-b border-[#14213d]/8 bg-[#fffaf0]/78 backdrop-blur-[18px]">
  <!-- ナビゲーション -->
</header>', '["header が常に画面最上部に固定され、コンテンツの上に重なる（position: fixed と同じ）", "スクロールして header が画面上端に達したとき、そこに貼り付いてスクロールに追従する", "header がページの一番上に配置されるだけで固定はされない", "top-0 は header の上部余白を 0 にするだけ"]', 1, '`sticky` は `position: sticky` に相当し、通常のフロー内に配置されますが、スクロールで `top: 0` の位置に達すると画面上端に貼り付きます。`fixed` と違い、最初はコンテンツの流れに沿って配置されるため他の要素を押し出しません。`backdrop-blur-[18px]` で半透明の背景ぼかし効果を加え、下のコンテンツがうっすら透けて見えるデザインになっています。', 'admin-web/src/layouts/AdminLayout.tsx / https://tailwindcss.com/docs/position');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (217, 'セクション67: Tailwind CSS レイアウト', 'mx-auto max-w-[1200px] の組み合わせ', '以下のクラスの組み合わせが実現するレイアウトはどれですか？', '<div className="mx-auto w-full max-w-[1200px] px-4 sm:px-6 lg:px-8">
  <!-- コンテンツ -->
</div>', '["幅 1200px で左寄せされる", "幅が最大 1200px で中央寄せされ、画面幅が狭い場合はレスポンシブに縮む", "常に画面幅いっぱいに広がる", "1200px 未満の画面ではコンテンツが非表示になる"]', 1, '`w-full` で親の幅いっぱいに広がりつつ、`max-w-[1200px]` で上限を制限します。`mx-auto` は左右マージンを auto にして中央寄せします。`px-4 sm:px-6 lg:px-8` はブレークポイントごとにパディングを変えるレスポンシブ対応です。この3点セットは中央寄せコンテナの定型パターンです。', 'admin-web/src/layouts/AdminLayout.tsx / https://tailwindcss.com/docs/max-width');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (218, 'セクション67: Tailwind CSS レイアウト', 'backdrop-blur の効果', '`backdrop-blur-[18px]` と `bg-[#fffaf0]/78` を組み合わせた header の視覚効果はどれですか？', '<header className="sticky top-0 z-10 bg-[#fffaf0]/78 backdrop-blur-[18px]">
  <!-- ナビゲーション -->
</header>', '["header の文字がぼやけて読みにくくなる", "header の背景が半透明（78%不透明度）で、背後のコンテンツが18pxのぼかしで透けて見えるすりガラス効果", "header の影が18pxぼかされる", "header の下のコンテンツが非表示になる"]', 1, '`bg-[#fffaf0]/78` は背景色を78%の不透明度で適用し、`backdrop-blur-[18px]` は要素の背後にある領域を18pxぼかします。スクロール時に下のコンテンツがすりガラス越しにうっすら見える効果が生まれます。`z-10` で他のコンテンツより前面に表示されることが保証されます。', 'admin-web/src/layouts/AdminLayout.tsx / https://tailwindcss.com/docs/backdrop-blur');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (219, 'セクション67: Tailwind CSS レイアウト', 'NavLink の isActive による動的クラス', '以下の `NavLink` で `className` に関数を渡している理由はどれですか？', '<NavLink
  className={({ isActive }) =>
    isActive
      ? `${navLinkBaseClassName} bg-linear-to-br from-[#1768ac] to-[#0f4c81] text-white`
      : `${navLinkBaseClassName} border border-[#14213d]/12 bg-white/80 text-[#14213d]`
  }
  end
  to="/quizzes"
>
  一覧
</NavLink>', '["React Router が className に文字列を受け取れないため", "現在のURLと NavLink の to が一致（アクティブ）しているかどうかで、スタイルを動的に切り替えるため", "アニメーションのために関数が必要なため", "TypeScript の型推論のため"]', 1, 'React Router の `NavLink` は `className` に関数を渡すと `{ isActive, isPending }` を引数で受け取れます。現在の URL が `/quizzes` なら `isActive: true` になり青いグラデーション背景が適用され、そうでなければ白い背景のスタイルが適用されます。`end` プロパティは完全一致のみアクティブにする指定で、`/quizzes/new` のとき「一覧」がアクティブにならないようにします。', 'admin-web/src/layouts/AdminLayout.tsx / https://reactrouter.com/components/nav-link');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (220, 'セクション67: Tailwind CSS レイアウト', 'Outlet コンポーネントの役割', '以下の `<Outlet />` が表示する内容はどれですか？', '// AdminLayout.tsx
<div className="min-h-screen">
  <header>...</header>
  <main>
    <Outlet />
  </main>
</div>

// App.tsx のルート定義
<Route element={<AdminLayout />}>
  <Route path="/quizzes" element={<QuizListPage />} />
  <Route path="/quizzes/new" element={<QuizFormPage />} />
</Route>', '["AdminLayout 自身を再帰的にレンダリングする", "URL に応じた子ルートのコンポーネント（/quizzes なら QuizListPage、/quizzes/new なら QuizFormPage）を表示する", "常に全子ルートを同時に表示する", "404 ページのフォールバックを表示する"]', 1, '`<Outlet />` は React Router のネストされたルート構造で、現在の URL に一致する子ルートのコンポーネントを描画する「穴」です。`AdminLayout` は header + main の共通レイアウトを提供し、`<Outlet />` の部分だけがページ遷移で入れ替わります。これにより header のナビゲーションは再レンダリングされず、ページコンテンツだけが切り替わります。', 'admin-web/src/layouts/AdminLayout.tsx / admin-web/src/App.tsx');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (221, 'セクション68: CSS テーブルレイアウト', 'table-fixed と table-auto の違い', '以下のテーブルに `table-fixed` を追加した場合の動作変化はどれですか？', '// 変更前: 列幅がセル内容で自動決定
<table className="min-w-full border-collapse">

// 変更後: 列幅が th の width 指定で固定
<table className="min-w-full border-collapse table-fixed">', '["テーブルの高さが固定される", "列幅の計算方法が「セル内容の長さベース」から「th の width 指定ベース」に変わり、長いテキストは改行される", "テーブルがスクロール不可になる", "border-collapse が無効になる"]', 1, '`table-fixed` は `table-layout: fixed` に相当します。デフォルトの `table-layout: auto` はセル内容の長さに応じて列幅が決まりますが、`fixed` では最初の行（通常 `<th>`）の `width` 指定で列幅が決まります。長いテキスト（例:「セクション52: Claude Code アップデート案内」）は列幅に収まるよう自動改行されます。', 'admin-web/src/pages/QuizListPage.tsx / https://tailwindcss.com/docs/table-layout');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (222, 'セクション68: CSS テーブルレイアウト', 'w-1/6 で均等列幅', '6列のテーブルで各 `<th>` に `w-1/6` を指定した場合、各列の幅はどうなりますか？', '<table className="min-w-full border-collapse table-fixed">
  <thead>
    <tr>
      <th className="w-1/6">タイトル</th>
      <th className="w-1/6">セクション</th>
      <th className="w-1/6">出典</th>
      <th className="w-1/6">作成日時</th>
      <th className="w-1/6">更新日時</th>
      <th className="w-1/6">操作</th>
    </tr>
  </thead>
</table>', '["各列が 1/6（約16.67%）で均等幅になる", "最初の列だけが 1/6 で残りは自動調整される", "w-1/6 は 6px を意味するため非常に狭くなる", "table-fixed がないと w-1/6 は無視される"]', 0, '`w-1/6` は `width: 16.666667%` に相当します。6列 × 16.67% = 100% で均等に分割されます。`table-fixed` と組み合わせることで、セル内容の長さに関係なく列幅が固定されます。`table-fixed` がなくても `w-1/6` は適用されますが、セル内容が長いと `auto` レイアウトに上書きされることがあります。', 'admin-web/src/pages/QuizListPage.tsx / https://tailwindcss.com/docs/width');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (223, 'セクション68: CSS テーブルレイアウト', 'table-layout: fixed のパフォーマンス', '`table-layout: fixed` が `table-layout: auto` よりレンダリングが速い理由はどれですか？', '// auto: 全セルの内容を読んでから列幅を計算
<table className="border-collapse"> <!-- table-layout: auto -->

// fixed: 最初の行だけ見て列幅を決定
<table className="border-collapse table-fixed">', '["fixed はブラウザキャッシュを使うため", "fixed は最初の行の幅情報だけで列幅を確定でき、全行のセル内容を先読みする必要がないため", "fixed は CSS を省略できるため", "fixed はテーブルの行数を制限するため"]', 1, '`table-layout: auto` はブラウザが全行の全セルを読み込んでから最適な列幅を計算するため、行数が多いとレンダリングが遅くなります。`table-layout: fixed` は最初の行（`<th>`）の `width` だけで列幅を確定するため、残りの行は逐次描画できます。クイズ一覧のように行数が多いテーブルでは体感速度の差が出ます。', 'https://developer.mozilla.org/docs/Web/CSS/table-layout');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (224, 'セクション69: React Fragments', 'Fragments が導入された歴史的動機', 'React 公式ドキュメントの Fragments の説明で、Fragments が導入された動機として最も適切なものはどれですか？', 'function Table() {
  return (
    <table>
      <tr>
        <Columns />
      </tr>
    </table>
  )
}

function Columns() {
  return (
    <div>
      <td>Hello</td>
      <td>World</td>
    </div>
  )
}', '["コンポーネントから複数要素を返したいが、`div` で包むと `table > tr > td` のような正しい HTML 構造を壊すため", "React が `div` 要素を将来的に廃止する予定だったため", "JSX では `td` 要素を2つ以上書けない仕様だったため", "Fragments は DOM ノード数を常に 0 にし、イベント処理も完全に無効化するため"]', 0, 'React の旧公式 Fragments ドキュメントでは、余計なラッパー要素を入れると表のような文脈で不正な HTML になることが導入の動機として説明されています。Fragments は複数要素をグループ化しつつ、DOM に不要なラッパーノードを追加しないため、この問題を避けられます。現行の react.dev でも、Fragment は wrapper node なしで要素をまとめる手段として説明されています。', 'https://legacy.reactjs.org/docs/fragments.html / https://react.dev/reference/react/Fragment');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (225, 'セクション70: Googlebot と JavaScript レンダリング', 'Googlebot の JS レンダリング ファイルサイズ制限の変更', 'Googlebot が JavaScript をレンダリングする際、2026年2月に変更されたファイルサイズ制限は何 MB から何 MB になりましたか？', NULL, '["10MB から 20MB", "15MB から 50MB", "50MB から 100MB", "制限なしから 15MB に新設された"]', 1, '2026年2月、Google は Web Rendering Service (WRS) のリソースサイズ上限を従来の 15MB から 50MB に引き上げました。これにより、大規模な SPA バンドルでもレンダリング対象に入りやすくなりましたが、レンダリングキューの遅延（数時間〜数日）は依然として存在するため、SEO が重要なページでは SSR/SSG が推奨されます。', 'https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (226, 'セクション70: Googlebot と JavaScript レンダリング', 'ダイナミックレンダリングの代替手法', 'Google 公式ドキュメントで、ダイナミックレンダリング（User-Agent によるサーバー側切替）の代わりに推奨されている3つの手法の組み合わせとして正しいものはどれですか？', NULL, '["SSR（サーバーサイドレンダリング）、SSG（静的サイト生成）、ハイドレーション", "CSR（クライアントサイドレンダリング）、ISR（インクリメンタル静的再生成）、Edge Functions", "プリレンダリング、AMP、Service Worker キャッシュ", "Headless Chrome、Puppeteer、Lighthouse CI"]', 0, 'Google の JavaScript SEO ドキュメントでは、ダイナミックレンダリングは「回避策 (workaround)」であり長期的な解決策ではないとされています。代わりに SSR（サーバーサイドレンダリング）、SSG（静的サイト生成）、ハイドレーション（SSR で生成した HTML にクライアント側で JS を接続する手法）の3つが推奨されています。', 'https://developers.google.com/search/docs/crawling-indexing/javascript/dynamic-rendering');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (227, 'セクション71: SWR（stale-while-revalidate）', 'SWR の名前の由来', 'SWR という名前の由来となった HTTP キャッシュ戦略の正式名称はどれですか？', NULL, '["stale-while-revalidate", "service-worker-refresh", "synchronous-web-request", "server-wide-replication"]', 0, 'SWR は HTTP の Cache-Control ヘッダーで使われる `stale-while-revalidate` 戦略に由来します。RFC 5861 で定義されたこの戦略は、キャッシュが stale（期限切れ）でもまず古いデータを返し（stale）、バックグラウンドで最新データを取得（revalidate）するというものです。Vercel の SWR ライブラリはこの考え方をクライアント側データフェッチに応用しています。', 'https://swr.vercel.app/');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (228, 'セクション71: SWR（stale-while-revalidate）', 'SEO と SWR の相性', 'SEO が重要なコンテンツに SWR（CSR でのデータフェッチ）を使うべきでない理由として最も適切なものはどれですか？', NULL, '["SWR はデータを暗号化するため、検索エンジンがコンテンツを読めなくなる", "SWR は初回レンダリング時に HTML が空であり、Googlebot の JS レンダリングキューに依存するためインデックスが遅延する", "SWR はサーバーサイドでしか動作しないため、ブラウザに HTML が届かない", "SWR のキャッシュ戦略が robots.txt と競合するため"]', 1, 'SWR を CSR で使う場合、初期 HTML は `<div id="root"></div>` のような空の状態でブラウザに届きます。コンテンツは JavaScript 実行後に描画されるため、Googlebot は JS レンダリングキュー（数時間〜数日の遅延）を経由してからでないとコンテンツを認識できません。また、Twitter や Slack 等のクローラーは JS を実行しないため、OGP タグも機能しません。ただし、ログイン必須の管理画面のように SEO が不要な画面では SWR + CSR で問題ありません。', 'https://swr.vercel.app/ / https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (229, 'セクション72: CSS position: sticky と関連プロパティ', 'top: 0 の 0 に単位は必要か', 'Tailwind CSS の `top-0` は `top: 0px` を生成します。CSS の仕様上、`top: 0` と `top: 0px` の違いについて MDN Web Docs の記述に基づく正しい説明はどれですか？', '/* Tailwind が生成する CSS */
.top-0 {
  top: 0px;
}

/* 手書きでも有効な CSS */
.header {
  top: 0;
}', '["`top: 0` は無効な CSS であり、必ず `top: 0px` のように単位を付けなければならない", "`0` は次元を持たない特別な値なので単位を省略でき、`top: 0` と `top: 0px` は同じ意味になる", "`top: 0` は `top: 0%` と解釈されるため、`top: 0px` とは異なる", "`top: 0` は `top: auto` のエイリアスとして扱われる"]', 1, 'MDN Web Docs によると、CSS の `<length>` 値には通常単位が必要ですが、値が `0` の場合は例外です。0 はどの単位でも同じ距離（ゼロ）を表すため、単位を省略できます。したがって `top: 0` と `top: 0px` は完全に等価です。Tailwind CSS は明示的に `0px` を生成しますが、手書き CSS では `top: 0` で問題ありません。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/top');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (230, 'セクション72: CSS position: sticky と関連プロパティ', 'z-index の値は相対的か絶対的か', '管理画面のヘッダーに `z-10`（`z-index: 10`）が設定されています。これを `z-5`（`z-index: 5`）に変更しても問題ないかを判断するために、MDN Web Docs の z-index の説明に基づく正しい理解はどれですか？', '/* 現在の設定 */
header { z-index: 10; }

/* 変更案 */
header { z-index: 5; }', '["z-index の数値は CSS 仕様で用途ごとに予約されており、ヘッダーには必ず 10 以上を使わなければならない", "z-index は同一スタッキングコンテキスト内での相対的な順序を決めるだけなので、他の要素より大きければ 5 でも 10 でも結果は同じ", "z-index: 5 は z-index: 10 の半分の透明度で描画される", "z-index は 0〜9 の範囲しか有効でないため、10 は実質 0 と同じ扱いになる"]', 1, 'MDN Web Docs によると、z-index はスタッキングコンテキスト内での要素の重なり順を決める整数値であり、数値自体に絶対的な意味はありません。重要なのは同じスタッキングコンテキスト内の他の要素との相対的な大小関係です。ヘッダーより前面に出る要素がなければ z-index: 5 でも z-index: 10 でも視覚的な結果は同じです。ただし、将来モーダル（z-40）やドロップダウンメニュー（z-20）を追加する可能性を考慮して、ヘッダーに z-10 程度の余裕を持たせるのが一般的な慣習です。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/z-index');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (231, 'セクション72: CSS position: sticky と関連プロパティ', 'position: sticky が機能する条件', 'MDN Web Docs によると、`position: sticky` を指定した要素が「張り付く」動作をするために必須の条件はどれですか？', '/* パターン A: 動作する */
header {
  position: sticky;
  top: 0;
}

/* パターン B: 動作しない */
header {
  position: sticky;
  /* top, right, bottom, left いずれも未指定 */
}', '["z-index を 1 以上に設定する", "top, right, bottom, left のうち少なくとも1つを auto 以外の値に設定する", "親要素に overflow: hidden を設定する", "display: flex または display: grid を親要素に設定する"]', 1, 'MDN Web Docs には「少なくとも1つの inset プロパティ（top, right, bottom, left 等）を auto 以外の値に設定する必要がある。両方の inset プロパティが auto の場合、その軸では sticky ではなく relative として振る舞う」と明記されています。つまり `position: sticky` だけ書いても、top 等の閾値を指定しなければ張り付き動作は発生しません。管理画面の `sticky top-0` は top: 0 を指定しているため正しく機能します。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/position');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (232, 'セクション72: CSS position: sticky と関連プロパティ', 'z-index: auto と z-index: 0 の違い', 'MDN Web Docs によると、`z-index: auto`（デフォルト値）と `z-index: 0` の違いとして正しいものはどれですか？', NULL, '["まったく同じであり、どちらもスタッキングコンテキストを生成する", "auto はスタッキングコンテキストを生成しないが、0 は新しいスタッキングコンテキストを生成する", "auto はスタック順が 0 になるが、0 はスタック順が -1 になる", "auto は positioned 要素にのみ有効で、0 は static 要素にも有効"]', 1, 'MDN Web Docs によると、z-index: auto のスタックレベルは 0 ですが、新しいスタッキングコンテキストは生成しません。一方 z-index: 0（整数値）はスタックレベルが 0 であると同時に、新しいローカルスタッキングコンテキストを生成します。この違いは子要素の重なり順に影響します。auto の場合、子要素の z-index は親の外側の要素と直接比較されますが、0 の場合は新しいスタッキングコンテキスト内に閉じ込められます。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/z-index');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (233, 'セクション72: CSS position: sticky と関連プロパティ', 'position: static で top が効かない理由', '次の CSS で `.box` が 30px 下にずれない理由として、MDN Web Docs の記述に基づく正しい説明はどれですか？', '.box {
  /* position 未指定 → デフォルトは static */
  top: 30px;
  left: 20px;
}', '["top と left を同時に指定しているため、値が打ち消し合ってゼロになる", "position が static（デフォルト）の場合、top / right / bottom / left プロパティは効果を持たない", "px 単位は position と併用できず、% 単位でなければならない", "top: 30px は構文エラーであり、ブラウザに無視される"]', 1, 'MDN Web Docs の top プロパティのページでは、position の値ごとの効果が明記されています。position: static の場合、top プロパティは「has no effect（効果なし）」です。top / right / bottom / left が機能するのは position が relative, absolute, fixed, sticky のいずれかの場合に限られます。CSS として記述すること自体は有効ですが、static 要素に対しては完全に無視されます。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/top');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (234, 'セクション72: CSS position: sticky と関連プロパティ', 'position: relative の実務上の主な用途', '`position: relative` を指定しつつ top / left 等を指定しないケースが実務では多く見られます。この場合の主な目的として最も適切なものはどれですか？', '/* 親 */
.card {
  position: relative; /* top 等は指定しない */
}

/* 子 */
.badge {
  position: absolute;
  top: 0;
  right: 0;
}', '["relative を指定すると要素の描画が GPU アクセラレーションされ、パフォーマンスが向上するため", "子要素の position: absolute の基準点（containing block）にするため", "スクロール時に要素が画面上部に固定されるようにするため", "要素のデフォルトの margin と padding をリセットするため"]', 1, 'MDN Web Docs によると、position: absolute の要素は最寄りの positioned 祖先（static 以外の position を持つ祖先）を基準に配置されます。親に position: relative を指定することで、absolute な子要素の基準点（containing block）として機能させるのが実務上最も一般的な用途です。relative 自体は top 等を指定しなければ見た目に変化はなく、ドキュメントフローにも影響しません。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/position');
INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source) VALUES (235, 'セクション73: Dart late と null safety', 'late がコンパイル時ではなくランタイムで制約を強制する意味', 'Dart 公式 docs では `late` について “enforce this variable''s constraints at runtime instead of at compile time” と説明されています。次の宣言に対する理解として最も正しいものはどれですか？', 'late SharedPreferences sharedPref;', '["宣言と同時に `SharedPreferences.getInstance()` が自動実行され、`sharedPref` に即座に値が入る", "コンパイル時の definite assignment チェックの代わりに、未初期化のまま読み出したときにランタイムで検査される", "`late` を付けると変数自体が存在しなくなり、初回代入時までメモリは一切使われない", "`late` を付けた変数は暗黙に nullable になり、未代入時は常に `null` を返す"]', 1, '`late` は「あとで必ず初期化する」という前提で、コンパイル時の初期化保証を緩め、その代わりに実行時チェックへ回す仕組みです。このため `late SharedPreferences sharedPref;` という宣言だけでは `SharedPreferences` の取得処理は走りません。実際の値は後で代入する必要があり、代入前に読み出すと `LateInitializationError` になります。', 'https://dart.dev/null-safety/understanding-null-safety / https://dart.dev/language/variables');

SELECT setval('quizzes_id_seq', (SELECT MAX(id) FROM quizzes));
