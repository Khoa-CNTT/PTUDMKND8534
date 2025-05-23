const express = require('express');
const Category = require('../models/category');

const categoryRouter = express.Router();

categoryRouter.post('/api/categories', async (req, res)=>{
    try{
        const {name, image, banner} = req.body;
        const category = new Category({name, image, banner});
        await category.save();
        res.status(201).send(category);
    }catch(e){
        res.status(500).json({error:e.message});
    }
});

categoryRouter.get('/api/categories', async(req,res)=>{
    try{
        const categories = await Category.find();
        res.status(200).json(categories);
    }catch(e){
        res.status(500).json({error:e.message});
    }
});

// xóa category
categoryRouter.delete('/api/categories/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const deleteCategory = await Category.findByIdAndDelete(id);
        if (!deleteCategory) {
            return res.status(404).json({ msg: "Không tìm thấy danh mục" });
        } else {
            return res.status(200).json({ msg: "Danh mục đã xóa" });
        }
    } catch (e) {
        return res.status(500).json({ error: e.message });
    }
});
module.exports = categoryRouter;