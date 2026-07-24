import "./Popup.css";
import moneteeHappy from "../public/Monetee.png"
import { useState } from "react";

interface Props {
  onClose: () => void;
}

function Popup({ onClose }: Props) {

  const [isSubmitted, setIsSubmitted] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [email, setEmail] = useState("");
  const [errorMessage, setErrorMessage] = useState("");


  async function resetPassword(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setErrorMessage("");
    setIsLoading(true);

    if (!email.trim()) {
      setErrorMessage("Please fill in your account email.");
      return;
    }

    try {
      const response = await fetch("/api/auth/requestReset", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          email
        })
      });

      await response.json();
      setIsSubmitted(true);

    } catch (err) {
      console.error(err);
      setErrorMessage("Error: Unable to connect to the server.");
    } finally {
      setIsLoading(false);
    }
  }

  return (

    <div className="global-modal-card">

      {isSubmitted ?
        (
          <div className="modal-card">

              <div className="logo-container">

                <img src={moneteeHappy} alt="Monetee, the pet">
                </img>

              </div>

              <p className="notice-email">
                If an account exists under the email:
                <br></br>
                <strong>{email}</strong>
                <br></br>
                We'll send you an email with password reset instructions.
              </p>

              <button className="close" onClick={onClose}>
                Ok!
              </button>
           
          </div>

        ) : (  /*Sent email message*/

          <div className="modal-card">

            <button className="close-modal" onClick={onClose}
              style={{
                backgroundColor: '#56cec0',
                color: 'white',
                marginBottom: '20px',
                border: 'none',
                padding: '10px 20px',
                borderRadius: '5px',
                cursor: 'pointer',
                fontWeight: 'bold'
              }}>
              Log in instead
            </button>

            <form onSubmit={resetPassword} >

              <h2 className="header">
                Reset Your Password
              </h2>

              <p className="enter-email-message">
                Please enter the email related to your account:
              </p>

              <div className="get-email">
                <input
                  type="email"
                  placeholder="Your email address "
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                />
              </div>

              {errorMessage && (
                <p className="form-message error-message">{errorMessage}</p>
              )}

              <button type="submit" disabled={isLoading}>
                {isLoading ? "Loading" : "Reset Password"}
              </button>

            </form >
          </div>

        )
      }

    </div>

  );
};

export default Popup;