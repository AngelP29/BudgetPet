import "./Logo.css";
import logoApp from "../public/MoneteeLogo.png"

function Logo() {
    return (
        <div className="hero">

            <div className="header"> 

                <h1 className="hero-title">BudgetPet</h1>

                <div className="logo-container">
                    
                    <img src={logoApp} alt="Manatee Website Logo">
                    </img>
        
                </div>

            </div>

            <p className="hero-subtitle">
                Build better financial habits alongside your virtual companion Monetee!
            </p>
        </div>
    );
};

export default Logo;