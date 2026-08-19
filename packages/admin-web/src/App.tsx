import { Suspense, lazy } from 'react'
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import ProtectedRoute from './components/ProtectedRoute'
import { FlashProvider } from './contexts/FlashContext'
import AdminLayout from './layouts/AdminLayout'
import LoginPage from './pages/LoginPage'

const QuizListPage = lazy(() => import('./pages/QuizListPage'))
const QuizFormPage = lazy(() => import('./pages/QuizFormPage'))
const ArchitecturesPage = lazy(() => import('./pages/ArchitecturesPage'))
const StackShowcase = lazy(() => import('./pages/StackShowcase'))
const NotFoundPage = lazy(() => import('./pages/NotFoundPage'))

function App() {
  const basename = import.meta.env.BASE_URL.replace(/\/$/u, '') || '/'

  return (
    <BrowserRouter basename={basename}>
      <FlashProvider>
        <Suspense fallback={<div className="grid min-h-screen place-items-center text-[#4f5d75]">読み込み中...</div>}>
          <Routes>
            <Route path="/login" element={<LoginPage />} />
            <Route path="/architectures" element={<ArchitecturesPage />} />
            <Route path="/stack" element={<StackShowcase />} />

            <Route element={<ProtectedRoute />}>
              <Route element={<AdminLayout />}>
                <Route index element={<Navigate to="/quizzes" replace />} />
                <Route path="/quizzes" element={<QuizListPage />} />
                <Route path="/quizzes/new" element={<QuizFormPage mode="create" />} />
                <Route path="/quizzes/:id/edit" element={<QuizFormPage mode="edit" />} />
              </Route>
            </Route>

            <Route path="*" element={<NotFoundPage />} />
          </Routes>
        </Suspense>
      </FlashProvider>
    </BrowserRouter>
  )
}

export default App
