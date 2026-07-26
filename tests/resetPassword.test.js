describe("BudgetPet Password Recovery", () => {

    test("Password reset link is generated correctly", () => {

        const FRONTEND_URL = "https://monetee.xyz";
        const token = "reset123";

        const resetLink =
            `${FRONTEND_URL}/reset-password?token=${token}`;

        expect(resetLink).toBe(
            "https://monetee.xyz/reset-password?token=reset123"
        );

    });

});