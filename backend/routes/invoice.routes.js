import express from "express";
import Invoice from "../models/invoice.js";
import PDFDocument from "pdfkit";

const router = express.Router();

// -------------------------
// Get all invoices
// -------------------------
router.get("/", async (req, res) => {
  try {
    const invoices = await Invoice.find().sort({ createdAt: -1 });
    res.json(invoices);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// -------------------------
// Create new invoice
// -------------------------
router.post("/", async (req, res) => {
  try {
    const invoice = new Invoice(req.body);
    const savedInvoice = await invoice.save();
    res.status(201).json(savedInvoice);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// -------------------------
// Update invoice
// -------------------------
router.put("/:id", async (req, res) => {
  try {
    const updatedInvoice = await Invoice.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true }
    );

    if (!updatedInvoice)
      return res.status(404).json({ message: "Invoice not found" });

    res.status(200).json(updatedInvoice);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// -------------------------
// Delete invoice
// -------------------------
router.delete("/:id", async (req, res) => {
  try {
    const deletedInvoice = await Invoice.findByIdAndDelete(req.params.id);

    if (!deletedInvoice)
      return res.status(404).json({ message: "Invoice not found" });

    res.status(200).json({ message: "Invoice deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// -------------------------
// Generate PDF for a specific invoice
// -------------------------
router.get("/pdf/:id", async (req, res) => {
  try {
    const invoice = await Invoice.findById(req.params.id);
    if (!invoice) return res.status(404).send("Invoice not found");

    const doc = new PDFDocument({ margin: 50 });
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader(
      "Content-Disposition",
      `inline; filename=invoice-${invoice._id}.pdf`
    );

    doc.pipe(res);

    // Invoice Header
    doc.fontSize(22).text("Invoice", { align: "center", underline: true });
    doc.moveDown();

    // Customer Info
    doc.fontSize(12).text(`Customer: ${invoice.customer}`);
    doc.text(`Phone: ${invoice.phone || "N/A"}`);
    doc.text(`Address: ${invoice.address || "N/A"}`);
    doc.text(`Date: ${invoice.date || new Date().toLocaleDateString()}`);
    doc.moveDown();

    // Items Table
    if (invoice.items?.length > 0) {
      doc.text("Items:", { underline: true });
      invoice.items.forEach((item, index) => {
        doc.text(
          `${index + 1}. ${item.name} - Qty: ${item.qty}, Price: ${item.price}`
        );
      });
      doc.moveDown();
    }

    // Summary
    doc.text(`Subtotal: ${invoice.subtotal ?? 0}`);
    doc.text(`Discount: ${invoice.discount ?? 0}`);
    doc.text(`Amount: ${invoice.amount ?? 0}`);
    doc.text(`Paid: ${invoice.paid ?? 0}`);
    doc.text(`Due: ${invoice.due ?? 0}`);
    doc.text(`Paid Status: ${invoice.isPaid ? "Paid" : "Pending"}`);

    doc.end();
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

export default router;
