import "./ResetPassword.css";
import Background from "../components/Background";
import { useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";


function ResetPassword() {

    const [password, setPassword] = useState("");
    const [confirmPassword, setConfirmPassword] = useState("");
    const [errorMessage, setErrorMessage] = useState("");
    const [successMessage, setSuccessMessage] = useState("");
    const [resetCheck, setIsReset] = useState(false);

    const navigate = useNavigate();
    const [searchParams] = useSearchParams();

    //basic password check requirements 
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$/;

        async function handleReset(event: React.FormEvent<HTMLFormElement>) {
            event.preventDefault();
            setErrorMessage("");
            setSuccessMessage("");

            const token = searchParams.get("token");

            if (!token) {
                setErrorMessage("Invalid token");
                return;
            }


            if (!password || !confirmPassword) {
                setErrorMessage("Please fill in both fields.");
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

            setIsReset(true);

            try {

                const response = await fetch("/api/auth/updatePass", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({
                        token,
                        password
                    })
                });

                const data = await response.json();

                if (!response.ok) {
                    setErrorMessage(data.error || "Couldn't send password update request");
                    return;
                }

                setSuccessMessage("Password reset successful!");
                setTimeout(() => {
                    navigate('/');
                }, 1500);


            } catch (err) {
                setErrorMessage("Unable to connect to the server.");
            } finally {
                setIsReset(false);
            }

        }


    return (
        <div className="reset-page">

            <Background />
            <form className="reset-password-card" onSubmit={handleReset}>

                <h2>Reset your password:</h2>

                <input
                    type="password"
                    placeholder="New password"
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

                <button type="submit" disabled={resetCheck}>
                    {resetCheck ? "Reset Old Password" : "Resetting Password"}
                </button>

            </form>

        </div>
    );
};

export default ResetPassword;