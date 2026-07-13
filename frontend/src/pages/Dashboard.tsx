import "./Dashboard.css";
import { useNavigate } from "react-router-dom";
import { useState } from "react";

import PetDisplay from "../components/PetDisplay";
import Expenses from "../components/Expenses";
import PetChat from "../components/PetChat";
import QuickStats from "../components/QuickStats";

import bg from "../public/BGMain.png"
import "../components/Background.css"

function Dashboard() {
    const username = localStorage.getItem("username") || "User";
    const navigate = useNavigate();

    const [refreshDashboard, setRefreshDashboard] = useState(0);

    function refreshDashboardData(){
        setRefreshDashboard(prev => prev + 1);
    }

    function handleLogout() {
        localStorage.removeItem("userId");
        localStorage.removeItem("token");
        localStorage.removeItem("username");

        navigate("/");
    }

    return (
        <div className="dashboard">

            <div className="background">

                <img src={bg} alt="Background"></img>

            </div>

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
                <PetDisplay refreshTrigger={refreshDashboard} />
            </section>

            {/* Main Dashboard */}
            <section className="dashboard-grid">

                {/* Quick Stats */}
                <QuickStats refreshTrigger={refreshDashboard} />

                {/* AI Coach */}
                <PetChat />

            </section>

            {/* Expense Form */}
            <section className="expense-section">

                <Expenses onExpenseChanged={refreshDashboardData} />

            </section>

        </div>
    );
}


export default Dashboard;