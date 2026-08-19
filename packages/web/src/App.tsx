import { Suspense, lazy } from 'react'
import { BrowserRouter, Route, Routes } from 'react-router-dom'
import { HistoryProvider } from './contexts/HistoryContext'
import { MasteryProvider } from './contexts/MasteryContext'
import { MemberSessionProvider } from './contexts/MemberSessionContext'
import AppLayout from './layouts/AppLayout'

const HomePage = lazy(() => import('./pages/HomePage'))
const QuizPlayPage = lazy(() => import('./pages/QuizPlayPage'))
const QuizResultPage = lazy(() => import('./pages/QuizResultPage'))
const HistoryPage = lazy(() => import('./pages/HistoryPage'))
const NotFoundPage = lazy(() => import('./pages/NotFoundPage'))
const MemberRegisterPage = lazy(() => import('./pages/MemberRegisterPage'))
const MemberLoginPage = lazy(() => import('./pages/MemberLoginPage'))
const MemberProfilePage = lazy(() => import('./pages/MemberProfilePage'))
const VerifyEmailPage = lazy(() => import('./pages/VerifyEmailPage'))
const ForgotPasswordPage = lazy(() => import('./pages/ForgotPasswordPage'))
const ResetPasswordPage = lazy(() => import('./pages/ResetPasswordPage'))

function App() {
  return (
    <BrowserRouter>
      <MemberSessionProvider>
        <HistoryProvider>
          <MasteryProvider>
            <Suspense fallback={<div className="grid min-h-screen place-items-center text-[#4f5d75]">読み込み中...</div>}>
              <Routes>
                <Route element={<AppLayout />}>
                  <Route index element={<HomePage />} />
                  <Route path="/play" element={<QuizPlayPage />} />
                  <Route path="/result/:recordId" element={<QuizResultPage />} />
                  <Route path="/history" element={<HistoryPage />} />
                  <Route path="/register" element={<MemberRegisterPage />} />
                  <Route path="/login" element={<MemberLoginPage />} />
                  <Route path="/me" element={<MemberProfilePage />} />
                  <Route path="/verify-email" element={<VerifyEmailPage />} />
                  <Route path="/forgot-password" element={<ForgotPasswordPage />} />
                  <Route path="/reset-password" element={<ResetPasswordPage />} />
                  <Route path="*" element={<NotFoundPage />} />
                </Route>
              </Routes>
            </Suspense>
          </MasteryProvider>
        </HistoryProvider>
      </MemberSessionProvider>
    </BrowserRouter>
  )
}

export default App
