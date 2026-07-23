//*****this page is still in progress and should not be linked to anything yet*****
const nodemailer = require("nodemailer");

//neither exists in .env yet
const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

async function sendVerificationEmail(email, token) {

    const verificationLink =
        `linktobeadded=${token}`;

    await transporter.sendMail({

        from: `"BudgetPet" <${process.env.EMAIL_USER}>`,

        to: email,

        subject: "Verify your BudgetPet Account",

        html: `
            <h2>Welcome to BudgetPet!</h2>

            <p>
                Thank you for creating an account.
            </p>

            <p>
                Click the button below to verify your email.
            </p>

            <p>
                <a
                    href="${verificationLink}"
                    style="
                        background:#4CAF50;
                        color:white;
                        padding:12px 20px;
                        text-decoration:none;
                        border-radius:6px;
                    "
                >
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

module.exports = {
    sendVerificationEmail
};