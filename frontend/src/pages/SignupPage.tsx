import "./SignupPage.css";

import PageTitle from "../components/PageTitle";

function SignUp(){

    return(

        <div className="signup-page">

            <PageTitle />

            <div className="signup-card">

                <h2>Create Account</h2>

                <p className="signup-subtitle">
                    Join BudgetPet today!
                </p>

                <input
                    type="text"
                    placeholder="First Name"
                />

                <input
                    type="text"
                    placeholder="Last Name"
                />

                <input
                    type="email"
                    placeholder="Email"
                />

                <input
                    type="password"
                    placeholder="Password"
                />

                <input
                    type="password"
                    placeholder="Confirm Password"
                />

                <button>

                    Create Account

                </button>

                <p className="login-link">

                    Already have an account?

                    <a href="/">
                        Log In
                    </a>

                </p>

            </div>

        </div>

    );
}

export default SignUp;