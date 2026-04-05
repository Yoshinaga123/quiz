import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import ProtectedRoute from './components/ProtectedRoute'
import AdminLayout from './layouts/AdminLayout'
import LoginPage from './pages/LoginPage'
import QuizFormPage from './pages/QuizFormPage'
import QuizListPage from './pages/QuizListPage'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />

        <Route element={<ProtectedRoute />}>
          <Route element={<AdminLayout />}>
            <Route index element={<Navigate to="/quizzes" replace />} />
            <Route path="/quizzes" element={<QuizListPage />} />
            <Route path="/quizzes/new" element={<QuizFormPage mode="create" />} />
            <Route path="/quizzes/:id/edit" element={<QuizFormPage mode="edit" />} />
          </Route>
        </Route>

        <Route path="*" element={<Navigate to="/quizzes" replace />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
