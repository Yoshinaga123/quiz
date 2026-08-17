import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App'

const rootElement = document.getElementById('root')
if (!rootElement) {
  throw new Error('Root element #root not found (index.html に <div id="root"> を追加してください)')
}

createRoot(rootElement).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
