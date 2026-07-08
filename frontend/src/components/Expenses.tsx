import "./Expenses.css"
import { useEffect, useState } from "react";

type Expense = {
    _id : string;
    userId: string;
    amount: number;
    category: string;
    description: string;
    date: string
};

function Expenses(){
    const [item, setItem] = useState("");
    const [amount, setAmount] = useState("");
    const [description, setDescription] = useState("");

    const [expenses, setExpenses] = useState<Expense[]>([]);
    
    const [errorMessage, setErrorMessage] = useState("");
    const [successMessage, setSuccessMessage] = useState("");
    const [isLoading, setIsLoading] = useState(false);
    const [isFetchingExpenses, setIsFetchingExpenses] = useState(false);

    async function loadExpenses(){
        const userId = localStorage.getItem("userId");

        if(!userId){
            setErrorMessage("No logged-in user found.");
            return;
        }

        if(!item || !amount){
            setErrorMessage("Please fill in Item and Amount.");
            return;
        }

        try{
            setIsFetchingExpenses(true);
            setErrorMessage("");

            const response = await fetch("/api/expenses/:userId");
            const data = await response.json();

            if (!response.ok) {
                setErrorMessage(data.error || "Failed to load expenses.");
                return;
            }

            setExpenses(data);
        } catch(e) {
            setErrorMessage("Unable to load expenses right now. Try again later.");
        } finally {
            setIsFetchingExpenses(false);
        }
    }

    useEffect(() => {
        loadExpenses();
    }, []);

    async function addExpense(event: React.FormEvent<HTMLFormElement>) {
        event.preventDefault();

        setErrorMessage("");
        setSuccessMessage("");

        const userId = localStorage.getItem("userId");

        if (!userId) {
            setErrorMessage("No logged-in user found.");
            return;
        }

        if (!item.trim() || !amount.trim()) {
            setErrorMessage("Please fill in Item and Amount.");
            return;
        }

        if (Number(amount) <= 0) {
            setErrorMessage("Amount must be greater than 0.");
            return;
        }

        try {
            setIsLoading(true);

            const response = await fetch("/api/expenses/add", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    userId,
                    amount: Number(amount),
                    category: item.trim(),
                    description: description.trim()
                })
            });

            const data = await response.json();

            if (!response.ok) {
                setErrorMessage(data.error || "Failed to add expense. Try again soon.");
                return;
            }

            setSuccessMessage("Expense added successfully!");

            setItem("");
            setAmount("");
            setDescription("");

            await loadExpenses();

        } catch (e) {
            setErrorMessage("Unable to add expense right now.");
        } finally {
            setIsLoading(false);
        }
    }

    return (
        <div className="expense-card">
            <h2>Add Expense</h2>

            {errorMessage && <p className="expense-error-message">{errorMessage}</p>}
            {successMessage && <p className="expense-success-message">{successMessage}</p>}

            <form onSubmit={addExpense}>
                <input
                    type="text"
                    placeholder="Item / Category"
                    value={item}
                    onChange={(e) => setItem(e.target.value)}
                />

                <input
                    type="number"
                    placeholder="Amount"
                    value={amount}
                    onChange={(e) => setAmount(e.target.value)}
                    min="0"
                    step="0.01"
                />

                <input
                    type="text"
                    placeholder="Description"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                />

                <button type="submit" disabled={isLoading}>
                    {isLoading ? "Adding..." : "Add Expense"}
                </button>
            </form>

            <hr />

            <h3>Recent Expenses</h3>

            {isFetchingExpenses ? (
                <p>Loading expenses...</p>
            ) : expenses.length === 0 ? (
                <p>No expenses logged yet.</p>
            ) : (
                <ul className="expense-list">
                    {expenses.slice(0, 5).map((expense) => (
                        <li key={expense._id} className="expense-item">
                            <div className="expense-item-top">
                                <span className="expense-category">{expense.category}</span>
                                <span className="expense-amount">
                                    ${Number(expense.amount).toFixed(2)}
                                </span>
                            </div>

                            <div className="expense-item-bottom">
                                <span className="expense-description">
                                    {expense.description || "No description"}
                                </span>

                                {expense.date && (
                                    <span className="expense-date">
                                        {new Date(expense.date).toLocaleDateString()}
                                    </span>
                                )}
                            </div>
                        </li>
                    ))}
                </ul>
            )}
        </div>
    );
}

export default Expenses;