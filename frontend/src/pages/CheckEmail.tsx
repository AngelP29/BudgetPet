import "./CheckEmail.css"
import Logo from "../components/Logo";
import Background from "../components/Background";

import { Link } from "react-router-dom";

function CheckEmail(){
    return(
        <div className="email-check">

            <Logo />

            <Background />

            <h3 className="message">
                Your BudgetPet account has been created!
            </h3>

            <p className="sent-email">
                We've sent a verification email to: example@example.com,
                please click the link in that email to activate your account.
            </p>

            <p className="no-email">
                Didn't receive it? *Resend Verification Email*
            </p>

            <p className="verified">
                Already verified?
                <Link to="/">Login</Link>
            </p>

        </div>
    );
}

export default CheckEmail;