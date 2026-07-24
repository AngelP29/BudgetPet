const { Resend } = require("resend");
const resend = new Resend(process.env.RESEND_API_KEY);

async function resetPasswordRequest(email, token) {

    const resetLink = `${process.env.FRONTEND_URL}/reset-password?token=${token}`;

    try {

        await resend.emails.send({

            from: "BudgetPet <no-reply@monetee.xyz>",

            to: email,

            subject: "BudgetPet Password Reset Request",

            html: `
                
                <p>
                    We received a request to reset your BudgetPet account password.
                </p>

                <p>
                    If you wish to continue resetting your account password click below:
                </p>

                <p>
                    <a href="${resetLink}">
                        Reset password.
                    </a>
                </p>

                <p>
                    If you did not create this account,
                    you can safely ignore this email.
                </p>
            `

        });

    }
    catch(err){

        console.error("Email Error:", err);

        throw err;

    }

}

module.exports = {
    resetPasswordRequest
};