const User = require("../models/User");
const generateToken = require("../utils/generateToken");

// @desc    Register new user (user / service_provider / admin)
// @route   POST /api/auth/register
// @access  Public
const registerUser = async (req, res, next) => {
  try {
    const { name, email, password, phoneNumber, role } = req.body;

    // Check karo user pehle se to exist nahi karta
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ success: false, message: "User already exists with this email" });
    }

    // Note: Production me "admin" role sirf existing admin hi assign kar sake -
    // isliye niche ek check laga rahe hain taake koi khud ko admin na bana sake
    let finalRole = role || "user";
    if (finalRole === "admin") {
      // Sirf tab allow karo jab request khud already-authenticated admin se aa rahi ho
      if (!req.user || req.user.role !== "admin") {
        finalRole = "user"; // silently downgrade — security best practice
      }
    }

    const user = await User.create({
      name,
      email,
      password,
      phoneNumber,
      role: finalRole,
    });

    const token = generateToken(user._id, user.role);

    res.status(201).json({
      success: true,
      message: "User registered successfully",
      data: {
        id: user._id,
        name: user.name,
        email: user.email,
        phoneNumber: user.phoneNumber,
        role: user.role,
        token,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
const loginUser = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Password explicitly select karna hai kyunke model me select:false hai
    const user = await User.findOne({ email }).select("+password");

    // Email hi exist nahi karta -> register karne ko bolo
    if (!user) {
      return res.status(404).json({
        success: false,
        message: "No account found with this email. Please register first.",
      });
    }

    // Email mila lekin password galat hai
    const isPasswordCorrect = await user.matchPassword(password);
    if (!isPasswordCorrect) {
      return res.status(401).json({
        success: false,
        message: "Incorrect password. Please try again.",
      });
    }

    if (!user.isActive) {
      return res.status(403).json({
        success: false,
        message: "Your account has been deactivated. Contact admin.",
      });
    }

    const token = generateToken(user._id, user.role);

    res.status(200).json({
      success: true,
      message: "Login successful",
      data: {
        id: user._id,
        name: user.name,
        email: user.email,
        phoneNumber: user.phoneNumber,
        role: user.role,
        token,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get logged-in user's profile
// @route   GET /api/auth/me
// @access  Private (any authenticated role)
const getMe = async (req, res, next) => {
  try {
    res.status(200).json({ success: true, data: req.user });
  } catch (error) {
    next(error);
  }
};

module.exports = { registerUser, loginUser, getMe };