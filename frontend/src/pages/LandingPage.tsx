import "./LandingPage.css"
import PageTitle from "../components/PageTitle";
import Login from "../components/Login";

function LandingPage() {
    return (
        <div className="landing-page">

            <PageTitle />

            <Login />

        </div>
    );
};

export default LandingPage;