import "./LandingPage.css"
import Logo from "../components/Logo";
import Background from "../components/Background";
import Login from "../components/Login";

function LandingPage() {
    return (
        <div className="landing-page">

            <Logo />
            
            <Background />

            <Login />

        </div>
    );
};

export default LandingPage;