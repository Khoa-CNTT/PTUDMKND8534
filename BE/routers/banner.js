const  express = require('express');
const Banner = require('../models/banner');
const bannerRouter = express.Router();

bannerRouter.post('/api/banner', async(req, res)=>{
    try{
        const {image} =req.body;
        const banner = new Banner({image});
        await banner.save();
        return res.status(201).send(banner);
    }catch(e){
        res.status(500).json({error:e.message});
    }
});

bannerRouter.get('/api/banner', async(req,res)=>{
    try{
       const banners = await Banner.find();
       return res.status(200).send(banners);
    }catch(e){
        res.status(500).json({error:e.message});
    }
});
// xóa banner
bannerRouter.delete('/api/banner/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const deleteBanner = await Banner.findByIdAndDelete(id);
        if (!deleteBanner) {
            return res.status(404).json({ msg: "Không tìm thấy banner" });
        } else {
            return res.status(200).json({ msg: "Banner đã xóa" });
        }
    } catch (e) {
        return res.status(500).json({ error: e.message });
    }
});

module.exports = bannerRouter;