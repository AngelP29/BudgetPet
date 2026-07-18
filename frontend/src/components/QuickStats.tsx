import { useEffect, useState } from "react";
import "./QuickStats.css"

type QuickStatsProps = {
    refreshTrigger: number;
};

type QuickStatsResponse = {
    monthlyBudget: number;
    monthlySavingsGoal: number;
    totalSpent: number;
    budgetRemaining: number;
};

function QuickStats({ refreshTrigger }: QuickStatsProps){
    const [monthlyBudget, setMonthlyBudget] = useState("");
    const [monthlySavingsGoal, setMonthlySavingsGoal] = useState("");
    const [totalSpent, setTotalSpent] = useState(0);
    const [budgetRemaining, setBudgetRemaining] = useState(0);

    const [errorMessage, setErrorMessage] = useState("");
    const [successMessage, setSuccessMessage] = useState("");
    const [isLoading, setIsLoading] = useState(false);

    useEffect(() => {
        getQuickStats();
    }, [refreshTrigger]);

    async function getQuickStats(){
        const token = localStorage.getItem("token");

        if (!token) {
            setErrorMessage("Please log in.");
            return;
        }

        setErrorMessage("");
        setSuccessMessage("");

        try{
            setIsLoading(true);

            const response = await fetch("/api/dashboard", {
                headers: {
                    Authorization: `Bearer ${ token }`
                }
            });
            const data: QuickStatsResponse | { error: string } = await response.json();

            if (!response.ok) {
                if ("error" in data) {
                    setErrorMessage(data.error);
                } else {
                    setErrorMessage("Failed to load quick stats.");
                }
                return;
            }

            const stats = data as QuickStatsResponse;

            // No need to initialize to zero as they are being casted to a string.
            // Fixes the issue of displaying "0" instead of the placeholder.
            setMonthlyBudget(String(stats.monthlyBudget));
            setMonthlySavingsGoal(String(stats.monthlySavingsGoal));
            // These merit ?? 0 because they are treated as numbers. 
            setTotalSpent(stats.totalSpent ?? 0);
            setBudgetRemaining(stats.budgetRemaining ?? 0);
        } catch(e) {
            setErrorMessage("Unable to load quick stats right now.");
        } finally {
            setIsLoading(false);
        }
    }

    async function updateGoals(event: React.FormEvent<HTMLFormElement>){
        const token = localStorage.getItem("token");

        if (!token) {
            setErrorMessage("Please log in.");
            return;
        }

        event.preventDefault();

        setErrorMessage("");
        setSuccessMessage("");

        if (!monthlyBudget.trim() || !monthlySavingsGoal.trim()) {
            setErrorMessage("Please enter both budget and savings goal.");
            return;
        }

        if (Number(monthlyBudget) < 0 || Number(monthlySavingsGoal) < 0) {
            setErrorMessage("Budget and savings goal must be 0 or greater.");
            return;
        }

        try {
            setIsLoading(true);

            const response = await fetch("/api/dashboard", {
                method: "PUT",
                headers: {
                    "Content-Type": "application/json",
                    Authorization: `Bearer ${ token }`
                },
                body: JSON.stringify({
                    monthlyBudget: Number(monthlyBudget),
                    monthlySavingsGoal: Number(monthlySavingsGoal)
                })
            });

            const data = await response.json();

            if (!response.ok) {
                setErrorMessage(data.error || "Failed to update goals.");
                return;
            }

            setSuccessMessage("Goals updated successfully!");
            await getQuickStats();

        } catch (e) {
            setErrorMessage("Unable to update goals right now.");
        } finally {
            setIsLoading(false);
        }
    }


    return(
        <div className="card stats-card">
            <h2>Quick Stats</h2>

            {errorMessage && <p className="stats-error-message">{errorMessage}</p>}
            {successMessage && <p className="stats-success-message">{successMessage}</p>}

            <div className="stats-grid">
                <div className="stat-box">
                    <h3>${Number(monthlyBudget || 0).toFixed(2)}</h3>
                    <p>Monthly Budget</p>
                </div>

                <div className="stat-box">
                    <h3>${Number(monthlySavingsGoal || 0).toFixed(2)}</h3>
                    <p>Savings Goal</p>
                </div>

                <div className="stat-box">
                    <h3>${Number(totalSpent).toFixed(2)}</h3>
                    <p>Spent This Month</p>
                </div>

                <div className="stat-box">
                    <h3>${Number(budgetRemaining).toFixed(2)}</h3>
                    <p>Budget Remaining</p>
                </div>
            </div>

            <form className="stats-form" onSubmit={updateGoals}>
                <h3>Update Goals</h3>

                <input
                    type="number"
                    value={monthlyBudget}
                    onChange={(e) => setMonthlyBudget(e.target.value)}
                    placeholder="Monthly Budget"
                    min="0"
                    step="0.01"
                />

                <input
                    type="number"
                    value={monthlySavingsGoal}
                    onChange={(e) => setMonthlySavingsGoal(e.target.value)}
                    placeholder="Monthly Savings Goal"
                    min="0"
                    step="0.01"
                />

                <button type="submit" disabled={isLoading}>
                    {isLoading ? "Saving..." : "Save Goals"}
                </button>
            </form>
        </div>
    );
}

export default QuickStats;