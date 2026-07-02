import "./Login.css"

function Login() {
    return (

        <div className="login-card">

            <h2>Welcome Back</h2>

            <p className="login-subtitle">
                Sign in to continue your journey.
            </p>

            <input
                type="text"
                placeholder="Username"
            />

            <input
                type="password"
                placeholder="Password"
            />

            <button>

                Log In

            </button>

            <p className="signup-link">

                Don't have an account?

                <a href="/signup">
                    Create one
                </a>

            </p>

        </div>

    );
};

export default Login;