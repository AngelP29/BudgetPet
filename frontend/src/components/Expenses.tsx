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

    //which expense is currently showing manage options
    const [activeExpenseId, setActiveExpenseId] = useState<string | null>(null);

    //which expense is currently in edit mode
    const [editingExpenseId, setEditingExpenseId] = useState<string | null>(null);

    //edit form state
    const [editItem, setEditItem] = useState("");
    const [editAmount, setEditAmount] = useState("");
    const [editDescription, setEditDescription] = useState("");

    async function loadExpenses(){
        const userId = localStorage.getItem("userId");

        if(!userId){
            setErrorMessage("No logged-in user found.");
            return;
        }

        try{
            setIsFetchingExpenses(true);
            setErrorMessage("");

            const response = await fetch(`/api/expenses/${userId}`);
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

    function startEditing(expense: Expense){
        setEditingExpenseId(expense._id);
        setActiveExpenseId(expense._id);

        setEditItem(expense.category);
        setEditAmount(String(expense.amount));
        setEditDescription(expense.description || "");
        setErrorMessage("");
        setSuccessMessage("");
    }

    function cancelEditing(){
        setActiveExpenseId(null);
        setEditingExpenseId(null);
        setEditItem("");
        setEditAmount("");
        setEditDescription("");
        setErrorMessage("");
        setSuccessMessage("");
    }

    async function saveEditedExpense(expenseId: string){
        const userId = localStorage.getItem("userId");

        if(!userId){
            setErrorMessage("No logged-in user found.");
            return;
        }

        if (!editItem.trim() || !editAmount.trim()) {
            setErrorMessage("Please fill in Item and Amount.");
            return;
        }

        if (Number(editAmount) <= 0) {
            setErrorMessage("Amount must be greater than 0.");
            return;
        }

        try{
            setIsLoading(true);
            setErrorMessage("");
            setSuccessMessage("");

            const response = await fetch(`/api/expenses/${expenseId}`, {
                method: "PUT",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    userId,
                    amount: Number(editAmount),
                    category: editItem.trim(),
                    description: editDescription.trim()
                })
            });

            const data = await response.json();

            if(!response.ok){
                setErrorMessage(data.error || "Failed to update expense.");
                return;
            }

            setSuccessMessage("Expense updated successfully!");
            cancelEditing();
            await loadExpenses();

        } catch(e){
            setErrorMessage("Unable to update expense right now.");
        } finally{
            setIsLoading(false);
        }
    }

    async function deleteExpense(expenseId: string){
        const userId = localStorage.getItem("userId");

        if(!userId){
            setErrorMessage("No logged-in user found.");
            return;
        }

        const confirmed = window.confirm("Are you sure you want to delte this expense?");
        if(!confirmed){
            return;
        }

        try{
            setIsLoading(true);
            setErrorMessage("");
            setSuccessMessage("");
            
            const response = await fetch(`api/expenses/${expenseId}`, {
                method: "DELETE",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({ userId })
            });

            const data = await response.json();

            if(!response.ok){
                setErrorMessage(data.error || "Failed to delete expense.");
                return;
            }

            setSuccessMessage("Expense deleted successfully!");
            cancelEditing();
            await loadExpenses();
        } catch(e){
            setErrorMessage("Unable to delete expense right now.");
        } finally{
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

                            {editingExpenseId === expense._id ? (
                                <div className="expense-edit-form">
                                    <input
                                        type="text"
                                        value={editItem}
                                        onChange={(e) => setEditItem(e.target.value)}
                                        placeholder="Item / Category"
                                    />

                                    <input
                                        type="number"
                                        value={editAmount}
                                        onChange={(e) => setEditAmount(e.target.value)}
                                        placeholder="Amount"
                                        min="0"
                                        step="0.01"
                                    />

                                    <input
                                        type="text"
                                        value={editDescription}
                                        onChange={(e) => setEditDescription(e.target.value)}
                                        placeholder="Description"
                                    />

                                    <div className="expense-action-row">
                                        <button
                                            type="button"
                                            className="expense-save-button"
                                            onClick={() => saveEditedExpense(expense._id)}
                                            disabled={isLoading}
                                        >
                                            Save Changes
                                        </button>

                                        <button
                                            type="button"
                                            className="expense-cancel-button"
                                            onClick={cancelEditing}
                                        >
                                            Cancel
                                        </button>
                                    </div>
                                </div>
                            ) : (
                                <>
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

                                    <div className="expense-manage-row">
                                        {activeExpenseId === expense._id ? (
                                            <>
                                                <button
                                                    type="button"
                                                    className="expense-manage-button edit-button"
                                                    onClick={() => startEditing(expense)}
                                                >
                                                    Edit
                                                </button>

                                                <button
                                                    type="button"
                                                    className="expense-manage-button delete-button"
                                                    onClick={() => deleteExpense(expense._id)}
                                                >
                                                    Delete
                                                </button>

                                                <button
                                                    type="button"
                                                    className="expense-manage-button cancel-button"
                                                    onClick={cancelEditing}
                                                >
                                                    Cancel
                                                </button>
                                            </>
                                        ) : (
                                            <button
                                                type="button"
                                                className="expense-manage-button manage-button"
                                                onClick={() => {
                                                    setActiveExpenseId(expense._id);
                                                    setEditingExpenseId(null);
                                                }}
                                            >
                                                Manage
                                            </button>
                                        )}
                                    </div>
                                </>
                            )}
                        </li>
                    ))}
                </ul>
            )}
        </div>
    );
}

export default Expenses;