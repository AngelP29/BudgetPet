import "./Dashboard.css";
import { useNavigate } from "react-router-dom";

import PetDisplay from "../components/PetDisplay";
import Expenses from "../components/Expenses";
import PetChat from "../components/PetChat";

function Dashboard() {
    const username = localStorage.getItem("username") || "User";
    const navigate = useNavigate();

    function handleLogout() {
        localStorage.removeItem("userId");
        localStorage.removeItem("token");
        localStorage.removeItem("username");

        navigate("/");
    }

    return (
        <div className="dashboard">

            <header className="dashboard-header">

                <div className="logo">
                    🐾 <span>BudgetPet</span>
                </div>

                <div className="header-right">
                    <div className="profile-button">
                        {username} 👤
                    </div>

                    <button className="logout-button" onClick={handleLogout}>
                        Logout
                    </button>
                </div>

            </header>

            <h2 className="welcome-message">
                Welcome back, {username}!
            </h2>

            {/* Pet Home */}
            <section className="pet-home">
                <PetDisplay />
            </section>

            {/* Main Dashboard */}
            <section className="dashboard-grid">

                {/* Quick Stats */}
                <div className="card stats-card">

                    <h2>Quick Stats</h2>

                    <div className="stats-grid">

                        <div className="stat-box">
                            <h3>$235</h3>
                            <p>Total Saved</p>
                        </div>

                        <div className="stat-box">
                            <h3>$87</h3>
                            <p>Total Spent</p>
                        </div>

                        <div className="stat-box">
                            <h3>$500</h3>
                            <p>Monthly Budget</p>
                        </div>

                        <div className="stat-box">
                            <h3>6 Days</h3>
                            <p>Saving Streak</p>
                        </div>

                    </div>

                </div>

                {/* AI Coach */}
                <PetChat />

            </section>

            {/* Expense Form */}
            <section className="expense-section">

                <Expenses />

            </section>

        </div>
    );
}


export default Dashboard;