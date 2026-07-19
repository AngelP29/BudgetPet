import "./CheckEmail.css"
import Logo from "../components/Logo";
import Background from "../components/Background";

function CheckEmail(){
    return(
        <div className="signup-page">

            <Logo />

            <Background />

            <p>
                Your BudgetPet account has been created!

                We've sent a verification email to: example@example.com

                Please click the link in that email to activate your account.

                Didn't receive it? *Resend Verification Email*

                Already verified? *Go to Login*
            </p>

        </div>
    );
}

export default CheckEmail;