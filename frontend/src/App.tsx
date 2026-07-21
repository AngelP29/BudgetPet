import { BrowserRouter, Routes, Route } from "react-router-dom";

import LandingPage from "./pages/LandingPage";
import SignUp from "./pages/SignupPage"
import Dashboard from "./pages/Dashboard";
import CheckEmail from "./pages/CheckEmail";

function App() {
  return(
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/signup" element={<SignUp />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/check-email" element={<CheckEmail />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App;