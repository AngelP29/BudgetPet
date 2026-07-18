import "./PetChat.css"
import { useState } from "react";

function PetChat(){
    const [message, setMessage] = useState("");
    const [petReply, setPetReply] = useState(
        "Hey! Ready to float through your finances today?"
    );

    const [errorMessage, setErrorMessage] = useState("");
    const [isLoading, setIsLoading] = useState(false);

    async function petConversation(event: React.FormEvent<HTMLFormElement>){
        event.preventDefault();

        const token = localStorage.getItem("token");

        if (!token) {
            setErrorMessage("Please log in.");
            return;
        }

        setErrorMessage("");

        if (!message.trim()) {
            setErrorMessage("Please enter a message for your pet.");
            return;
        }

        try{
            setIsLoading(true);

            const response = await fetch("/api/chat", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    Authorization: `Bearer ${ token }`
                },
                body: JSON.stringify({
                    message: message.trim(),
                    petName: "BudgetPet"
                })
            });

            const data = await response.json();

            if(!response.ok){
                setErrorMessage(data.error || "Failed to chat with pet. try again soon.");
                return;
            }

            setPetReply(data.reply || "Your pet had nothing to say.");
            setMessage("");

        } catch(e){
            setErrorMessage("Unable to connect to the pet right now");
        } finally {
            setIsLoading(false);
        }
    }

    return (
        <div className="chat-card">
            <h2>Pet Coach</h2>

            <div className="chat-box">
                <p>{petReply}</p>
            </div>

            {errorMessage && (
                <p className="chat-error-message">{errorMessage}</p>
            )}

            <form className="chat-form" onSubmit={petConversation}>
                <input
                    type="text"
                    placeholder="Ask your pet anything..."
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                />

                <button type="submit" disabled={isLoading}>
                    {isLoading ? "Sending..." : "Send"}
                </button>
            </form>
        </div>
    );
}

export default PetChat;
