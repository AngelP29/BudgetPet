import { useEffect } from "react";
import { useState } from "react";

import "./PetDisplay.css"
import petImg from "../public/Monetee.png"

type Pet = {
    name: string;
    level: number;
    exp: number;
    happiness: number;
    health: number;
};

type PetDisplayProps = {
    refreshTrigger: number;
};

function PetDisplay({ refreshTrigger }: PetDisplayProps){
    const [pet, setPet] = useState<Pet | null>(null);

    const [errorMessage, setErrorMessage] = useState("");
    const [isFetchingPet, setIsFetchingPet] = useState(false);

    useEffect(() => {
        loadPet();
    }, [refreshTrigger]);

    async function loadPet(){
        const userId = localStorage.getItem("userId");

        if(!userId){
            setErrorMessage("No logged-in user found.");
            return;
        }

        try {
            setIsFetchingPet(true);
            setErrorMessage("");

            const response = await fetch(`/api/pets/${userId}`);
            const data = await response.json();

            if (!response.ok) {
                setErrorMessage(data.error || "Failed to load pet information.");
                return;
            }

            setPet(data);

        } catch(e) {
            setErrorMessage("Unable to retrieve pet information.");
        } finally {
            setIsFetchingPet(false);
        }
    }

    return(

        <div className="pet-card">

            {errorMessage && <p className="pet-error-message">{errorMessage}</p>}
            {isFetchingPet && <p className="pet-loading-message">Loading pet...</p>}

            <div className="logo-container">
                    
                <img src={petImg} alt="Monetee, the virtual pet">
                </img>
        
            </div>

            <h2>{pet?.name ?? "BudgetPet"}</h2>

            <div className="pet-level">
                ⭐ Level {pet?.level ?? 1}
            </div>

            <p>EXP: {pet?.exp ?? 0}/100</p>

            <p>Happiness: {pet?.happiness ?? 100}%</p>

            <div className="mood-bar">

                <div
                    className="mood-fill"
                    style={{ width: `${pet?.happiness ?? 100}%` }}
                ></div>

            </div>

        </div>

    );
}

export default PetDisplay;