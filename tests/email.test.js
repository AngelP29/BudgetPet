describe("BudgetPet Email Verification", () => {

    test("Verification email link is generated correctly", () => {

        const FRONTEND_URL = "https://monetee.xyz";
        const token = "abcdef123456";

        const verificationLink =
            `${FRONTEND_URL}/verify?token=${token}`;

        expect(verificationLink).toBe(
            "https://monetee.xyz/verify?token=abcdef123456"
        );

    });

});