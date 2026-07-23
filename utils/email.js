const { Resend } = require("resend");

const resend = new Resend(process.env.RESEND_API_KEY);

async function sendVerificationEmail(email, token) {

    const verificationLink = `${process.env.FRONTEND_URL}/verify?token=${token}`;

    try {

        await resend.emails.send({

            from: "BudgetPet <onboarding@resend.dev>",

            to: email,

            subject: "Verify your BudgetPet Account",

            html: `
                <h2>Welcome to BudgetPet!</h2>

                <p>
                    Thanks for creating your account.
                </p>

                <p>
                    Click the button below to verify your email.
                </p>

                <p>
                    <a href="${verificationLink}">
                        Verify Email
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
    sendVerificationEmail
};