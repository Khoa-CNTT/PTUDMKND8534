const express = require('express');
const mongoose = require('mongoose');
const Order = require('../models/order');
const { auth, vendorAuth } = require('../middlewares/auth');

const orderRouter = express.Router();

// Tạo đơn hàng mới
orderRouter.post('/api/orders', auth, async (req, res) => {
  try {
    const {
      fullName, email, address, phone,
      productName, productPrice, quantity,
      category, image, vendorId, buyerId,
    } = req.body;
    const createdAt = Date.now();
    const order = new Order({
      fullName, email, address, phone,
      productName, productPrice, quantity,
      category, image, vendorId, buyerId,
      createdAt
    });

    await order.save();
    return res.status(201).json(order);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});


// Lấy đơn hàng theo buyerId
orderRouter.get('/api/orders/:buyerId', async (req, res) => {
  try {
    const { buyerId } = req.params;
    const orders = await Order.find({ buyerId });
    return res.status(200).json(orders); // ✅ trả về [] nếu không có đơn
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Xóa đơn hàng
orderRouter.delete('/api/orders/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const deleteOrder = await Order.findByIdAndDelete(id);
    if (!deleteOrder) {
      return res.status(404).json({ msg: "Không tìm thấy đơn hàng" });
    } else {
      return res.status(200).json({ msg: "Đơn hàng đã xóa" });
    }
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// Lấy đơn hàng theo vendorId
orderRouter.get('/api/orders/vendor/:vendorId', async (req, res) => {
  try {
    const { vendorId } = req.params;
    const orders = await Order.find({ vendorId });
    return res.status(200).json(orders); 
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

// Cập nhật đơn hàng thành Delivered
orderRouter.patch('/api/orders/:id/delivered', async (req, res) => {
  try {
    const { id } = req.params;
    const updatedOrder = await Order.findByIdAndUpdate(
      id,
      { delivered: true, processing: false },
      { new: true }
    );

    if (!updatedOrder) {
      return res.status(404).json({ msg: "Không thấy đơn hàng" });
    } else {
      return res.status(200).json(updatedOrder);
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Cập nhật đơn hàng thành Processing
orderRouter.patch('/api/orders/:id/processing', async (req, res) => {
  try {
    const { id } = req.params;
    const updatedOrder = await Order.findByIdAndUpdate(
      id,
      { processing: false, delivered: false },
      { new: true }
    );

    if (!updatedOrder) {
      return res.status(404).json({ msg: "Không thấy đơn hàng" });
    } else {
      return res.status(200).json(updatedOrder);
    }
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Lấy tất cả đơn hàng
orderRouter.get('/api/orders', async (req, res) => {
  try {
    const orders = await Order.find();
    return res.status(200).json(orders); 
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

module.exports = orderRouter;
