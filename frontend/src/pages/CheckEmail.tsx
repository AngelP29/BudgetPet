import "./CheckEmail.css"
import Logo from "../components/Logo";
import Background from "../components/Background";
import moneteeHappy from "../public/New Sign Up.png" 

import { Link, useLocation } from "react-router-dom";

function CheckEmail() {
    const location = useLocation();
    const email = location.state?.email ?? " the email address you provided";

    function handleResendEmail() {

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
                >
                    Resend Verification Email
                </button>

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