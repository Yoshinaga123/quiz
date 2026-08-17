import { Suspense, lazy } from 'react'
import { BrowserRouter, Route, Routes } from 'react-router-dom'
import { HistoryProvider } from './contexts/HistoryContext'
import AppLayout from './layouts/AppLayout'

const HomePage = lazy(() => import('./pages/HomePage'))
const QuizPlayPage = lazy(() => import('./pages/QuizPlayPage'))
const QuizResultPage = lazy(() => import('./pages/QuizResultPage'))
const HistoryPage = lazy(() => import('./pages/HistoryPage'))
const NotFoundPage = lazy(() => import('./pages/NotFoundPage'))

function App() {
  return (
    <BrowserRouter>
      <HistoryProvider>
        <Suspense fallback={<div className="grid min-h-screen place-items-center text-[#4f5d75]">読み込み中...</div>}>
          <Routes>
            <Route element={<AppLayout />}>
              <Route index element={<HomePage />} />
              <Route path="/play" element={<QuizPlayPage />} />
              <Route path="/result/:recordId" element={<QuizResultPage />} />
              <Route path="/history" element={<HistoryPage />} />
              <Route path="*" element={<NotFoundPage />} />
            </Route>
          </Routes>
        </Suspense>
      </HistoryProvider>
    </BrowserRouter>
  )
}

export default App
