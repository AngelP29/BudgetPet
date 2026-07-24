import "./CheckEmail.css";

import Background from "../components/Background";
import moneteeHappy from "../public/New Sign Up.png" 

import { Link, useLocation } from "react-router-dom";
import { useState } from "react";

function CheckEmail() {
    const location = useLocation();
    const email = location.state?.email ?? " the email address you provided";

    const [message, setMessage] = useState("");
    const [loading, setLoading] = useState(false);

    async function handleResendEmail() {
        setLoading(true);
        setMessage("");

        try{
            const response = await fetch("/api/auth/resend-verification", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    email
                })
            });

            const data = await response.json();

            if(!response.ok){
                setMessage(data.error);
                return;
            }

            setMessage("Verification email has been sent!");
        } catch(e){
            setMessage("Unable to contact the server.");
        } finally{
            setLoading(false);
        }
    }

    return (
        <div className="email-check">

            <div className="logo-container">

                <img src={moneteeHappy} alt="Monetee, the pet">
                </img>

            </div>

            <Background />

            <div className="email-card">

                <h2 className="message">
                    Verify Your Email
                </h2>

                <p className="sent-email">
                    Your BudgetPet account has been created!
                    <br /><br />
                    We've sent a verification email to
                    <strong>{email}</strong>
                    Please click the link in that email to activate your account.
                </p>

                <p className="resend-text">
                    Didn't receive it?
                </p>

                <button
                    className="resend-btn"
                    onClick={handleResendEmail}
                    disabled={loading}
                >
                    {loading
                        ? "Sending..."
                        : "Resend Verification Email"}
                </button>

                {message && (
                    <p className="resend-message">
                        {message}
                    </p>
                )}

                <p className="verified">
                    Already verified?
                    {" "}
                    <Link to="/">Login</Link>
                </p>

            </div>
        </div>
    );
}

export default CheckEmail;
