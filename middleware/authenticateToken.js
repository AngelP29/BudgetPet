const jwt = require("jsonwebtoken");

const JWT_SECRET = "budgetpet_super_secret_key_12345";

function authenticateToken(req, res, next){
    const authHeader = req.headers.authorization;

    if(!authHeader){
        return res.status(401).json({error:"Missing token"});
    }

    const token = authHeader.split(" ")[1];

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if(err){
            return res.status(403).json({error:"Invalid token"});
        }

        req.user = user;

        next();
    });
}

module.exports = authenticateToken;