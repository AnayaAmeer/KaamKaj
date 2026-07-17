const express = require("express");
const router = express.Router();

const { registerUser, loginUser, getMe } = require("../controllers/authController");
const { registerValidation, loginValidation } = require("../validators/authValidator");
const { validate } = require("../middleware/validateMiddleware");
const { protect } = require("../middleware/authMiddleware");

router.post("/register", registerValidation, validate, registerUser);
router.post("/login", loginValidation, validate, loginUser);
router.get("/me", protect, getMe);

module.exports = router;