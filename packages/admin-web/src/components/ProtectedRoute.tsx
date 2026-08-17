import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { isAuthenticated } from '../auth/session'

function ProtectedRoute() {
  const location = useLocation()

  if (!isAuthenticated()) {
    return (
      <Navigate
        to="/login"
        replace
        state={{ from: `${location.pathname}${location.search}${location.hash}` }}
      />
    )
  }

  return <Outlet />
}

export default ProtectedRoute
