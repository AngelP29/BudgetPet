import "./SignUp.css";
import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";

function SignUp() {
    const navigate = useNavigate();

    const [firstName, setFirstName] = useState("");
    const [lastName, setLastName] = useState("");
    const [username, setUsername] = useState("");
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [confirmPassword, setConfirmPassword] = useState("");

    const [errorMessage, setErrorMessage] = useState("");
    const [successMessage, setSuccessMessage] = useState("");
    const [isLoading, setIsLoading] = useState(false);

    //basic password check requirements 
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$/;

    async function handleSignup(event: React.FormEvent<HTMLFormElement>) {
        event.preventDefault();

        setErrorMessage("");
        setSuccessMessage("");

        if (!firstName.trim() || !lastName.trim() || !username.trim() || !email.trim() || !password || !confirmPassword) {
            setErrorMessage("Please fill in all fields.");
            return;
        }

        if (password !== confirmPassword) {
            setErrorMessage("Passwords do not match.");
            return;
        }

        if (!passwordRegex.test(password)) {
            setErrorMessage("Password must be at least 8 characters and include uppercase, lowercase, a number, and a special character.");
            return;
        }

        try {
            setIsLoading(true);

            const response = await fetch("/api/auth/register", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    firstName: firstName.trim(),
                    lastName: lastName.trim(),
                    username: username.trim(),
                    email: email.trim(),
                    password
                })
            });

            const data = await response.json();

            if (!response.ok) {
                setErrorMessage(data.error || "Signup failed.");
                return;
            }

            setSuccessMessage("Account created successfully! Redirecting...");

            navigate("/check-email", {
                state: {
                    email
                }
            });

            /*
            localStorage.setItem("token", data.token);
            localStorage.setItem("userId", data.userId);
            localStorage.setItem("username", data.username);

            localStorage.setItem("userId", data.userId);
            localStorage.setItem("token", data.token);
            localStorage.setItem("username", data.username);

            setTimeout(() => {
                navigate("/dashboard");
            }, 700);
            */

        } catch (err) {
            setErrorMessage("Unable to connect to the server.");
        } finally {
            setIsLoading(false);
        }

    }

    return (


        <form className="signup-card" onSubmit={handleSignup}>

            <h2>Create Account</h2>

            <p className="signup-subtitle">
                Join BudgetPet today!
            </p>

            <input
                type="text"
                placeholder="First Name"
                value={firstName}
                onChange={(e) => setFirstName(e.target.value)}
            />

            <input
                type="text"
                placeholder="Last Name"
                value={lastName}
                onChange={(e) => setLastName(e.target.value)}
            />

            <input
                type="text"
                placeholder="Username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
            />

            <input
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
            />

            <input
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
            />

            <input
                type="password"
                placeholder="Confirm Password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
            />

            {errorMessage && (
                <p className="form-message error-message">{errorMessage}</p>
            )}

            {successMessage && (
                <p className="form-message success-message">{successMessage}</p>
            )}

            <button type="submit" disabled={isLoading}>
                {isLoading ? "Creating Account..." : "Create Account"}
            </button>

            <p className="login-link">
                Already have an account?
                <Link to="/">Log In</Link>
            </p>

        </form>


    );
}

export default SignUp;
