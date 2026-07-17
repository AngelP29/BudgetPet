import "./Login.css";
import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";

function Login() {
    const navigate = useNavigate();

    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");

    const [errorMessage, setErrorMessage] = useState("");
    const [successMessage, setSuccessMessage] = useState("");
    const [isLoading, setIsLoading] = useState(false);

    async function handleLogin(event: React.FormEvent<HTMLFormElement>){
        event.preventDefault();

        setErrorMessage("");
        setSuccessMessage("");

        if(!username.trim() || !password.trim()){
            setErrorMessage("Please enter both username and password.");
            return; 
        }

        try{
            setIsLoading(true);

            const response = await fetch("/api/auth/login", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    username: username.trim(),
                    password
                })
            });

            const data = await response.json();

            if(!response.ok){
                setErrorMessage(data.error || "Login failed.");
                return;
            }

            localStorage.setItem("token", data.token);
            localStorage.setItem("userId", data.userId);
            localStorage.setItem("username", data.username);

            setSuccessMessage("Login successful.");

            localStorage.setItem("userId", data.userId);
            localStorage.setItem("token", data.token);
            localStorage.setItem("username", data.username);

            setTimeout(() => {
                navigate("/dashboard");
            }, 700);

        } catch(err){
            console.error(err);
            setErrorMessage("Error: Unable to connect to the server.");
        } finally{
            setIsLoading(false);
        }
    }

    return (
        <form className="login-card" onSubmit={handleLogin}>
            <h2>Welcome Back</h2>

            <p className="login-subtitle">
                Sign in to continue your journey.
            </p>

            <input
                type="text"
                placeholder="Username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
            />

            <input
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
            />

            {errorMessage && (
                <p className="form-message error-message">{errorMessage}</p>
            )}

            {successMessage && (
                <p className="form-message success-message">{successMessage}</p>
            )}

            <button type="submit" disabled={isLoading}>
                {isLoading ? "Logging In..." : "Log In"}
            </button>

            <p className="signup-link">
                Don't have an account?
                <Link to="/signup">Create one</Link>
            </p>
        </form>
    );
};

export default Login;
