const express = require("express");
const router = express.Router();

const {
  getCategories,
  addCategory,
  updateCategory,
  deleteCategory,
} = require("../controllers/categoryController");

const { upload } = require("../config/cloudinary");
const { protect, isAdmin } = require("../middleware/authMiddleware");

// ---------- PUBLIC ----------
router.get("/", getCategories);

// ---------- ADMIN ----------
router.post("/admin", protect, isAdmin, upload.single("image"), addCategory);
router.put("/admin/:id", protect, isAdmin, upload.single("image"), updateCategory);
router.delete("/admin/:id", protect, isAdmin, deleteCategory);

module.exports = router;