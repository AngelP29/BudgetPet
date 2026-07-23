import "./Verify.css";
import Logo from "../components/Logo";
import Background from "../components/Background";

import { useEffect, useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";

function Verify() {

    const [searchParams] = useSearchParams();
    const navigate = useNavigate();

    const [message, setMessage] = useState("Verifying your email...");

    useEffect(() => {

        async function verifyEmail() {

            const token = searchParams.get("token");

            if (!token) {
                setMessage("Invalid verification link.");
                return;
            }

            try {

                const response = await fetch(
                    `/api/auth/verify?token=${token}`
                );

                const data = await response.json();

                if (!response.ok) {
                    setMessage(data.error);
                    return;
                }

                setMessage("Email verified successfully! Redirecting to login...");

                setTimeout(() => {
                    navigate("/");
                }, 2500);

            }
            catch {

                setMessage("Unable to verify your email.");

            }

        }

        verifyEmail();

    }, []);

    return (
        <div className="verify-page">

        <Logo />
        <Background />

        <div className="verify-card">

            <h2>Email Verification</h2>

            <p>{message}</p>

        </div>

    </div>
    );

}

export default Verify;