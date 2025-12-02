import mongoose from "mongoose";

const invoiceSchema = new mongoose.Schema({
  customer: { type: String, required: true },
  phone: { type: String },
  address: { type: String },
  date: { type: String },
  subtotal: { type: Number },
  discount: { type: Number },
  amount: { type: Number },
  paid: { type: Number },
  due: { type: Number },
  items: [{ name: String,  qty: { type: mongoose.Schema.Types.Mixed }, price: Number }],
  isPaid: { type: Boolean, default: false }
}, { timestamps: true });

const Invoice = mongoose.model("Invoice", invoiceSchema);

export default Invoice;
