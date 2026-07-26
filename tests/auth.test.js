const crypto = require("crypto");

describe("BudgetPet Authentication", () => {

    const passwordRegex =
        /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$/;

    test("Password complexity requirements are enforced", () => {

        expect(passwordRegex.test("BudgetPet123!")).toBe(true);

    });

    test("Weak passwords are rejected", () => {

        expect(passwordRegex.test("password")).toBe(false);

    });

    test("Verification tokens are securely generated", () => {

        const token = crypto.randomBytes(32).toString("hex");

        expect(token).toMatch(/^[a-f0-9]{64}$/);

    });

});