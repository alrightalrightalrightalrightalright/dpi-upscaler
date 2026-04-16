# Advanced Integration Guide - ESRGAN Super-Resolution

This guide explains how to integrate advanced AI-powered upscaling using ESRGAN.

## Why ESRGAN?

**ESRGAN (Enhanced Super-Resolution GAN)** provides:
- ✅ Higher visual quality (9/10 vs 7/10 with canvas)
- ✅ Artifact reduction (fewer halos, better edges)
- ✅ Detail recovery (reconstructs lost information)
- ✅ Color accuracy (minimal color shift)

**Trade-offs:**
- ⏱️ Slower processing (5-10s for 2000×2000px on CPU)
- 💾 Requires model download (20-50 MB, cached after first use)
- ⚙️ More complex setup

---

## Implementation Steps

### 1. Choose Your Model Source

**Option A: HuggingFace Hub (Recommended)**
```
Model: sberbank-ai/Real-ESRGAN
Format: ONNX (requires ONNX Runtime)
Size: ~50 MB
URL: https://huggingface.co/sberbank-ai/Real-ESRGAN
```

**Option B: TensorFlow Hub**
```
Pre-converted TensorFlow.js models
Size: ~30 MB
Faster loading
URL: https://tfhub.dev/
```

**Option C: Build Your Own**
```
1. Download PyTorch model
2. Convert to ONNX
3. Convert to TensorFlow.js format
4. Host on CDN
```

### 2. Install Dependencies

For development (optional, if you want to test locally):

```bash
# Python dependencies for model conversion
pip install torch torchvision
pip install tensorflow tf2onnx
pip install onnx onnx-tensorflow

# Or use pre-built tools
npm install @tensorflow/tfjs
npm install @tensorflow/tfjs-converter
```

### 3. Update index.html Configuration

Find this section:
```javascript
const CONFIG = {
    ESRGAN_ONNX_URL: 'https://huggingface.co/sberbank-ai/Real-ESRGAN/raw/main/RealESRGAN_x4.onnx'
};
```

Replace with your model URL.

### 4. Enable ESRGAN in Code

Uncomment these functions in `index.html`:

```javascript
async function loadESRGANModel() {
    // Implementation for loading model
}

async function upscaleWithESRGAN(scale) {
    // Implementation for ESRGAN inference
}
```

### 5. Model Conversion (If Using PyTorch)

**Convert PyTorch to ONNX:**
```bash
python -c "
import torch
from models import RealESRGAN

model = RealESRGAN()
model.load_state_dict(torch.load('RealESRGAN_x4.pth'))

# Export to ONNX
example_input = torch.randn(1, 3, 64, 64)
torch.onnx.export(
    model, 
    example_input, 
    'model.onnx',
    input_names=['input'],
    output_names=['output']
)
"
```

**Convert ONNX to TensorFlow.js:**
```bash
pip install onnx-tf tensorflow

# Convert
onnx-tf convert -i model.onnx -o ./tf_model

# Then use tfjs-converter
npx tfjs-converter ./tf_model/model.pb model.json
```

### 6. Host Model on CDN

**Option A: GitHub + jsDelivr**
```
1. Commit model to repo
2. jsDelivr automatically serves: 
   https://cdn.jsdelivr.net/gh/user/repo/model.onnx
```

**Option B: HuggingFace Hub**
```
1. Upload to huggingface.co
2. Set to public
3. Use model URL directly
```

**Option C: Cloudflare R2**
```
1. Create R2 bucket
2. Upload model
3. Enable public access
4. Get CDN URL
```

---

## Code Implementation

### Full ESRGAN Implementation Example

```javascript
// Configuration
const ESRGAN_CONFIG = {
    MODEL_URL: 'https://cdn.jsdelivr.net/gh/yourusername/repo/models/esrgan.onnx',
    INPUT_SIZE: 512, // Tile size for memory efficiency
    SCALE_FACTOR: 4  // 4x upscaling
};

let esrganModel = null;

// Load ONNX model (requires ONNX Runtime)
async function loadESRGANModel() {
    try {
        showProgress('Loading ESRGAN model...', 25);
        
        // Option 1: Load ONNX model
        const ort = await import('onnxruntime-web');
        esrganModel = await ort.InferenceSession.create(ESRGAN_CONFIG.MODEL_URL);
        
        console.log('ESRGAN model loaded successfully');
        return true;
    } catch (error) {
        console.error('Failed to load ESRGAN:', error);
        showInfo('Could not load AI model. Using standard upscaling instead.', 'warning');
        return false;
    }
}

// Upscale image with ESRGAN
async function upscaleWithESRGAN(scale) {
    if (!esrganModel) {
        // Load model if not already loaded
        const loaded = await loadESRGANModel();
        if (!loaded) {
            // Fallback to canvas method
            return upscaleWithTensorflow();
        }
    }

    showProgress('Upscaling with ESRGAN AI model...', 40);
    
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d', { willReadFrequently: true });
    
    // Get image data
    const tempCanvas = document.createElement('canvas');
    tempCanvas.width = state.originalWidth;
    tempCanvas.height = state.originalHeight;
    const tempCtx = tempCanvas.getContext('2d');
    tempCtx.drawImage(state.originalImage, 0, 0);
    
    const imageData = tempCtx.getImageData(0, 0, state.originalWidth, state.originalHeight);
    
    try {
        // Normalize to [0, 1]
        const normalized = new Float32Array(imageData.data.length);
        for (let i = 0; i < imageData.data.length; i++) {
            normalized[i] = imageData.data[i] / 255.0;
        }
        
        // Create tensor
        const input = new ort.Tensor('float32', normalized, [1, state.originalHeight, state.originalWidth, 4]);
        
        showProgress('Running inference...', 60);
        
        // Run model
        const outputs = await esrganModel.run({ input });
        const outputTensor = outputs.output;
        
        // Get output data
        const output = await outputTensor.getData();
        
        showProgress('Processing output...', 80);
        
        // Denormalize and create output canvas
        const outputWidth = Math.round(state.originalWidth * scale);
        const outputHeight = Math.round(state.originalHeight * scale);
        
        canvas.width = outputWidth;
        canvas.height = outputHeight;
        
        const outputImageData = ctx.createImageData(outputWidth, outputHeight);
        for (let i = 0; i < output.length; i++) {
            outputImageData.data[i] = Math.round(output[i] * 255);
        }
        
        ctx.putImageData(outputImageData, 0, 0);
        state.upscaledCanvas = canvas;
        
        return true;
    } catch (error) {
        console.error('ESRGAN inference error:', error);
        throw error;
    }
}
```

### Simplified TensorFlow.js Alternative

```javascript
// If you want to use TensorFlow.js instead of ONNX Runtime
async function upscaleWithTFJS() {
    showProgress('Loading TensorFlow.js model...', 25);
    
    try {
        // Load a pre-trained super-resolution model
        // Example: Using a custom or publicly available model
        const model = await tf.loadLayersModel(
            'https://cdn.jsdelivr.net/gh/yourusername/repo/tfjs_model/model.json'
        );
        
        showProgress('Running inference...', 50);
        
        // Convert image to tensor
        const input = tf.browser.fromPixels(state.originalImage);
        
        // Normalize
        const normalized = input.div(255.0).expandDims(0);
        
        // Run model
        const output = model.predict(normalized);
        
        // Convert back to canvas
        const scale = parseFloat(elements.scaleSlider.value);
        const outputWidth = Math.round(state.originalWidth * scale);
        const outputHeight = Math.round(state.originalHeight * scale);
        
        const canvas = document.createElement('canvas');
        canvas.width = outputWidth;
        canvas.height = outputHeight;
        
        await tf.browser.toPixels(output.squeeze(), canvas);
        
        state.upscaledCanvas = canvas;
        
        // Cleanup
        input.dispose();
        normalized.dispose();
        output.dispose();
        
        return true;
    } catch (error) {
        console.error('TensorFlow.js error:', error);
        throw error;
    }
}
```

---

## Model Comparison Table

| Model | Quality | Speed | Size | Browser Support |
|-------|---------|-------|------|-----------------|
| Real-ESRGAN-x4 | 9/10 | 3-5s (CPU) | 50MB | All |
| SRVGGCompact | 8/10 | 1-2s (CPU) | 20MB | All |
| BSRGAN | 8.5/10 | 2-4s (CPU) | 35MB | All |
| Canvas Lanczos | 7/10 | <500ms | 0MB | All |
| TF.js Generic SR | 7.5/10 | 5-10s (CPU) | 30MB | All |

---

## Performance Optimization Tips

### 1. Tiling (For Large Images)
```javascript
// Process image in tiles to avoid memory exhaustion
async function upscaleWithTiling(tileSize = 512) {
    const tiles = [];
    const overlap = 10; // pixels
    
    for (let y = 0; y < state.originalHeight; y += tileSize - overlap) {
        for (let x = 0; x < state.originalWidth; x += tileSize - overlap) {
            const tw = Math.min(tileSize, state.originalWidth - x);
            const th = Math.min(tileSize, state.originalHeight - y);
            tiles.push({x, y, width: tw, height: th});
        }
    }
    
    // Process each tile with ESRGAN
    // Then stitch together with overlap blending
}
```

### 2. Progressive Loading
```javascript
// Show upscaling progress incrementally
async function progressiveUpscale() {
    for (let step = 0; step < 4; step++) {
        await upscaleTile(step);
        updateProgressBar((step + 1) / 4 * 100);
        // Allow UI to update
        await new Promise(r => setTimeout(r, 10));
    }
}
```

### 3. GPU Acceleration
```javascript
// Force GPU usage
tf.backend('webgl');
// or
tf.backend('wasm');
```

---

## Testing ESRGAN

### Manual Testing
```javascript
// Test in browser console:
await loadESRGANModel();
await upscaleWithESRGAN(4);

// Check output
console.log(state.upscaledCanvas);
state.upscaledCanvas.toDataURL(); // View in DevTools
```

### Quality Metrics
```javascript
// After upscaling, measure quality:
function measureQuality(original, upscaled) {
    // PSNR calculation
    // SSIM calculation
    // Visual comparison
}
```

---

## Troubleshooting ESRGAN

| Problem | Solution |
|---------|----------|
| Model won't download | Check CORS headers; verify URL |
| ONNX Runtime error | Install `onnxruntime-web` package |
| Out of memory | Use tiling; reduce input size |
| Slow inference | Enable WebGL/GPU acceleration |
| Model not found | Check CDN URL; verify bucket permissions |

---

## Resources

- [Real-ESRGAN GitHub](https://github.com/xinntao/Real-ESRGAN)
- [ONNX Runtime Web](https://onnxruntime.ai/docs/get-started/with-javascript.html)
- [TensorFlow.js Models](https://github.com/tensorflow/tfjs-models)
- [Model Conversion Guide](https://www.tensorflow.org/js/guide/conversion)

---

## Next Steps

1. ✅ Choose model and source
2. ✅ Convert or download model
3. ✅ Host on CDN
4. ✅ Update config URL
5. ✅ Enable in code
6. ✅ Test thoroughly
7. ✅ Deploy and share!

---

**Quality comes at a cost, but it's worth it! 🚀**
