# Deployment Guide - DPI Upscaler

## Quick Deployment Options

### Option 1: GitHub Gist (Fastest - Recommended)
**Time: 2 minutes**

1. Open https://gist.github.com
2. Click "Create gist"
3. Filename: `index.html`
4. Paste entire contents of `index.html`
5. Click "Create public gist" (or private if you prefer)
6. Click the "Raw" button to get the raw link
7. Use this link to access your upscaler (or share it!)

**Share link format:**
```
https://gist.githubusercontent.com/username/gist-id/raw/filename.html
```

**Pro tip:** Use a URL shortener to make it easier to share!

---

### Option 2: GitHub Pages (Permanent - Recommended for frequent use)
**Time: 5 minutes**

1. Create a new GitHub repository (name it `dpi-upscaler`)
2. Clone it locally: `git clone https://github.com/yourusername/dpi-upscaler`
3. Copy `index.html` into the repo
4. Push to GitHub:
   ```bash
   git add index.html
   git commit -m "Add DPI upscaler"
   git push origin main
   ```
5. Go to repository Settings → Pages
6. Select "Deploy from a branch"
7. Choose "main" branch
8. Save
9. Wait 1-2 minutes, then access at:
   ```
   https://yourusername.github.io/dpi-upscaler/
   ```

---

### Option 3: Netlify (Free - Best for custom domain)
**Time: 3 minutes**

1. Create account at https://netlify.com
2. Drag and drop `index.html` to the deploy area
3. Get instant URL like: `https://random-name.netlify.app`
4. (Optional) Connect GitHub repo for auto-updates

---

### Option 4: Vercel (Free - Fastest CDN)
**Time: 3 minutes**

1. Create account at https://vercel.com
2. Create new project
3. Upload `index.html`
4. Get URL at: `https://your-project.vercel.app`

---

### Option 5: Local File (No internet)
1. Save `index.html` to your computer
2. Open with any web browser
3. Works 100% offline!

---

## Advanced: Adding ESRGAN Support

For AI-powered super-resolution (optional):

### Step 1: Enable ESRGAN in index.html
Find this line in the JavaScript:
```javascript
// Uncomment and use this for advanced ESRGAN super-resolution
```

Uncomment the ESRGAN functions:
- `loadESRGANModel()`
- `upscaleWithESRGAN()`

### Step 2: Set up Model Hosting
Models need to be hosted on a CDN. Options:

**Option A: HuggingFace Model Hub**
- Upload model to: https://huggingface.co/models
- Free hosting with CORS support
- Update `ESRGAN_ONNX_URL` in config

**Option B: Cloudinary / Imgix**
- Use their APIs
- Charge per use, but simple integration

**Option C: Self-host on GitHub**
- Commit model weights to repo
- Serve via jsDelivr CDN
- Free but slower initially

### Step 3: Model Conversion (Advanced)
Convert PyTorch model to TensorFlow.js format:

```bash
# Install conversion tools
pip install tensorflow tf2onnx onnx onnx-tf

# Convert PyTorch ESRGAN to ONNX
# (detailed steps depend on model source)

# Convert ONNX to TensorFlow.js
# (use @tensorflow/tfjs-converter)
```

---

## Testing Checklist

After deployment, verify:

- [ ] Page loads without errors (check browser console)
- [ ] Can upload images
- [ ] Scaling slider works (1.5x - 4x)
- [ ] DPI dropdown works
- [ ] Can calculate print dimensions
- [ ] Upscaling completes (takes ~1-2 seconds)
- [ ] Can download PNG
- [ ] Can download JPEG with quality slider
- [ ] Dimensions are correct in output
- [ ] Mobile responsive (open on phone)

---

## Performance Optimization

### Gist Hosting (Reduce load time)
- Keep CSS/JS inline (already done)
- Lazy-load libraries from CDN (already done)
- No build step needed (already optimized)

### GitHub Pages (Increase speed)
- Enable GitHub Pages caching
- CDN automatically caches globally
- Average load time: <1s

### Custom Domain
```
DNS: Add CNAME → yourusername.github.io
Settings → Custom domain → yoursite.com
```

---

## Troubleshooting Deployment

| Problem | Solution |
|---------|----------|
| Page won't load | Check browser console (F12) for errors; verify CDN links work |
| Upload button doesn't work | Check CORS settings; ensure file input permissions |
| Download fails | Try different format; check browser's download settings |
| Slow performance | Close other tabs; check internet speed; try smaller image |
| Gist link doesn't work | Use "Raw" link, not regular Gist page; refresh cache |

---

## File Size Reference

- `index.html`: ~40 KB
- TensorFlow.js (CDN): ~300 KB
- ESRGAN model (CDN, if enabled): ~20-50 MB (lazy-loaded)
- Total page: ~500 KB without model

**Gist limit:** ~100 MB per gist (plenty of space)
**GitHub Pages:** Unlimited

---

## Support for Custom Features

Want to customize? Here's what you can easily change:

1. **Change colors:** Modify CSS color values
2. **Add branding:** Update title/subtitle
3. **Adjust max image size:** Change `CONFIG.MAX_INPUT_SIZE`
4. **Add new DPI presets:** Add options to `<select id="dpiPreset">`
5. **Change scaling range:** Modify slider min/max

---

## Next Steps

1. ✅ Deploy using your chosen method
2. 🧪 Test on desktop and mobile
3. 🔗 Share the URL with friends/colleagues
4. 💬 Give feedback or report issues
5. 🚀 (Optional) Set up custom domain

---

**Happy upscaling! 🚀**
