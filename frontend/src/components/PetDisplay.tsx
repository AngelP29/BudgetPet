import { useEffect } from "react";
import { useState } from "react";

import "./PetDisplay.css"
import petImg from "../public/Monetee.png"
import sadState from "../public/Sad Monetee.gif"
import happyState from "../public/Happy Monetee.gif"
import worriedState from "../public/Worried Monetee.gif"

type Pet = {
    level: number;
    exp: number;
    happiness: number;
};

type PetDisplayProps = {
    refreshTrigger: number;
};

function PetDisplay({ refreshTrigger }: PetDisplayProps) {
    const [pet, setPet] = useState<Pet | null>(null);

    const [errorMessage, setErrorMessage] = useState("");
    const [isFetchingPet, setIsFetchingPet] = useState(false);

    useEffect(() => {
        loadPet();
    }, [refreshTrigger]);

    async function loadPet() {
        const token = localStorage.getItem("token");

        if (!token) {
            setErrorMessage("Please log in.");
            return;
        }

        try {
            setIsFetchingPet(true);
            setErrorMessage("");

            const response = await fetch("/api/pets", {
                headers: {
                    Authorization: `Bearer ${token}`
                }
            });
            const data = await response.json();

            if (!response.ok) {
                setErrorMessage(data.error || "Failed to load pet information.");
                return;
            }

            setPet(data);

        } catch (e) {
            setErrorMessage("Unable to retrieve pet information.");
        } finally {
            setIsFetchingPet(false);
        }
    }

    let currState = petImg;
    
    if (pet != null) {
        
            if (pet.happiness > 60) 
            {
                currState = happyState;
            }

            if (pet.happiness >= 40 && pet.happiness <= 60) 
            {
                currState = sadState;
            }

            if (pet.happiness < 40) 
            {
                currState = worriedState;
            }
    }

    return (

        <div className="pet-card">

            {errorMessage && <p className="pet-error-message">{errorMessage}</p>}
            {isFetchingPet && <p className="pet-loading-message">Loading pet...</p>}

            <div className="logo-container">

                <img src={currState} alt="Monetee, the virtual pet with dynamic expressions">
                </img>

            </div>

            <h2>{"Monetee"}</h2>

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