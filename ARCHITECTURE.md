# Technical Architecture

## System Overview

```
┌─────────────────────────────────────────────┐
│          DPI Upscaler Application           │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │   User Interface (HTML + CSS)        │  │
│  │  - File upload                       │  │
│  │  - Scaling slider (1.5x - 4x)        │  │
│  │  - DPI selector                      │  │
│  │  - Progress feedback                 │  │
│  └──────────────────────────────────────┘  │
│                    ↓                        │
│  ┌──────────────────────────────────────┐  │
│  │   Processing Engine (JavaScript)     │  │
│  │  - Image loading                     │  │
│  │  - Upscaling (Canvas + TensorFlow)   │  │
│  │  - EXIF metadata handling            │  │
│  └──────────────────────────────────────┘  │
│                    ↓                        │
│  ┌──────────────────────────────────────┐  │
│  │   Export Engine                      │  │
│  │  - PNG/JPEG conversion               │  │
│  │  - Metadata injection                │  │
│  │  - Download generation               │  │
│  └──────────────────────────────────────┘  │
│                                             │
└─────────────────────────────────────────────┘
         ↓                              ↑
     Local Browser              User Download
```

---

## Component Architecture

### 1. User Interface Layer

**HTML Structure:**
```
index.html
├── Form Elements
│   ├── File Input (image upload)
│   ├── Scale Slider (1.5x - 4x)
│   ├── DPI Selector (dropdown + custom)
│   └── Upscale Button
├── Display Elements
│   ├── File Info Box
│   ├── Dimensions Calculator
│   ├── Progress Bar
│   └── Preview Canvas
└── Download Section
    ├── Format Selector (PNG/JPEG)
    ├── Quality Slider (JPEG only)
    └── Download Buttons
```

**Styling:**
- Pure CSS (no frameworks)
- Responsive grid layout
- Mobile-first design
- 10KB total CSS

### 2. Processing Engine

**State Management:**
```javascript
state = {
    originalImage: HTMLImageElement,      // Original uploaded image
    originalWidth: number,                 // Original dimensions
    originalHeight: number,
    originalDpi: number,                   // Detected from EXIF or default 72
    originalExif: Object,                  // EXIF metadata
    upscaledCanvas: HTMLCanvasElement,    // Result canvas
    isProcessing: boolean,                 // Lock during processing
    model: Object,                         // TensorFlow model (if loaded)
    modelLoaded: boolean                   // Model cache state
}
```

**Image Upload Pipeline:**
```
User selects image
    ↓
FileReader reads file
    ↓
Image loads to memory
    ↓
EXIF data extracted (original DPI)
    ↓
Dimensions validated
    ↓
Preview displayed
    ↓
Ready for upscaling
```

**Upscaling Pipeline (Canvas Method):**
```
Scale factor selected (1.5x - 4x)
    ↓
Calculate output dimensions
    ↓
Create output canvas
    ↓
Canvas.drawImage() with high-quality smoothing
    ↓
For scales > 2x: Use intermediate 2x pass
    ↓
Output canvas ready for export
```

**Alternative: TensorFlow.js Pipeline:**
```
Model download (first use only)
    ↓
Image → Tensor conversion
    ↓
Preprocessing (normalization)
    ↓
Model inference (ESRGAN)
    ↓
Postprocessing (denormalization)
    ↓
Tensor → Canvas conversion
    ↓
Output ready
```

### 3. EXIF Metadata Handler

**Read EXIF:**
```javascript
EXIF.getData(file, callback)
  ├─ XResolution (DPI)
  ├─ YResolution (DPI)
  ├─ ResolutionUnit (1=no unit, 2=inches, 3=cm)
  ├─ Orientation (rotation flag)
  └─ Camera metadata (optional)
```

**Write EXIF (Simplified):**
```javascript
piexif.dump({
  '0th': {
    282: [selectedDpi, 1],    // XResolution
    283: [selectedDpi, 1],    // YResolution
    296: 2,                    // ResolutionUnit (inches)
    // Additional tags...
  }
})
```

### 4. Export Engine

**PNG Export:**
```
Canvas.toDataURL('image/png')
  ↓
Blob creation
  ↓
EXIF injection (if supported)
  ↓
Download generation
  ↓
Browser download
```

**JPEG Export:**
```
Canvas.toDataURL('image/jpeg', quality)
  ↓
Apply quality slider (0.6 - 1.0)
  ↓
Blob creation
  ↓
EXIF injection (if supported)
  ↓
Download generation
  ↓
Browser download
```

---

## Data Flow Diagram

```
┌─────────┐
│ Browser │
└────┬────┘
     │
     ├─→ Load index.html
     │   (40 KB, self-contained)
     │
     ├─→ Load CDN libraries
     │   ├─ TensorFlow.js (optional)
     │   ├─ exif-js (read EXIF)
     │   └─ piexif.js (write EXIF)
     │
     ├─→ User uploads image
     │   ├─ FileReader API reads file
     │   ├─ Image loads to canvas
     │   └─ EXIF extracted
     │
     ├─→ User configures scaling + DPI
     │   ├─ Dimensions calculated
     │   └─ Preview displayed
     │
     ├─→ Upscaling initiated
     │   ├─ Canvas method (default)
     │   ├─ OR TensorFlow.js + ESRGAN
     │   └─ Output canvas generated
     │
     ├─→ Export settings chosen
     │   ├─ Format (PNG/JPEG)
     │   └─ Quality (if JPEG)
     │
     └─→ Download generated
         ├─ Canvas → Blob
         ├─ EXIF injected
         └─ Browser download triggered
```

---

## Memory Management

### Memory Usage by Component

```
                           Peak Memory Usage
Component                  per 2000×2000px image
─────────────────────────────────────────────────
Original image (canvas)         40 MB
Upscaled canvas (4x)           150 MB
Tensor storage                  50 MB
Intermediate buffers            40 MB
─────────────────────────────────────────────────
TOTAL PEAK                     ~280 MB
```

### Memory Optimization Strategies

1. **Canvas Context Optimization:**
   ```javascript
   ctx.getContext('2d', { willReadFrequently: true })
   // Hint for optimization
   ```

2. **Tensor Disposal:**
   ```javascript
   tensor.dispose() // Free memory after use
   ```

3. **Canvas Reuse:**
   ```javascript
   // Reuse canvas instead of creating new
   canvas.width = newWidth // Reset instead of creating new
   ```

4. **Streaming/Tiling (for large images):**
   ```javascript
   // Process in 512×512 tiles
   // Prevents single large allocation
   ```

---

## Browser API Usage

### Canvas API
```javascript
// Image smoothing for quality
ctx.imageSmoothingEnabled = true
ctx.imageSmoothingQuality = 'high'

// Draw with scaling
ctx.drawImage(img, 0, 0, width, height)

// Get pixel data
const imageData = ctx.getImageData(0, 0, w, h)

// Export image
canvas.toDataURL('image/png')
```

### File API
```javascript
// Read file
const file = input.files[0]
const reader = new FileReader()
reader.readAsArrayBuffer(file)

// Create blob
const blob = new Blob([data], {type: 'image/png'})

// Create download
const url = URL.createObjectURL(blob)
const a = document.createElement('a')
a.href = url
a.download = 'filename.png'
a.click()
```

### Window/Document APIs
```javascript
// Progress indication
requestAnimationFrame(updateProgress)

// Local storage (optional, for settings)
localStorage.setItem('lastDpi', '300')

// Event listeners
element.addEventListener('change', handler)
element.addEventListener('click', handler)
```

---

## Performance Optimizations

### 1. Image Smoothing
```javascript
// Use hardware-accelerated canvas interpolation
ctx.imageSmoothingQuality = 'high'
// Options: 'low', 'medium', 'high'
```

### 2. Intermediate Scaling
```javascript
if (scale > 2) {
    // Do 2x first (faster)
    // Then additional scaling
    // Better quality than single pass
}
```

### 3. Lazy Model Loading
```javascript
if (!modelLoaded) {
    // Download model only on first use
    // Cache in browser for subsequent uses
}
```

### 4. Debouncing UI Updates
```javascript
// Prevent excessive reflow
debounce(updateDimensions, 100)
```

### 5. GPU Acceleration
```javascript
// Chrome/Firefox with WebGL support
tf.backend('webgl')
// Can be 10x faster than CPU
```

---

## Error Handling

### Input Validation
```
File upload
  ├─ Check MIME type (image/*)
  ├─ Check file size (<100 MB)
  ├─ Check dimensions (<5000px)
  └─ Show warnings for edge cases
```

### Processing Errors
```
Upscaling
  ├─ Catch out-of-memory errors
  ├─ Fallback to canvas method
  ├─ Graceful degradation
  └─ User-friendly error messages
```

### Export Errors
```
Download
  ├─ Catch Blob creation errors
  ├─ EXIF injection errors (non-fatal)
  ├─ Show success/failure message
  └─ Allow retry
```

---

## Testing Architecture

### Unit Tests (Browser Console)
```javascript
// Test EXIF reading
readExifData(testFile).then(data => console.log(data))

// Test scaling calculation
calculatePrintSize(2000, 2000, 300) // → 6.67" × 6.67"

// Test canvas upscaling
upscaleWithTensorflow(2) // → upscaled canvas
```

### Integration Tests
```javascript
// Full workflow test
1. Upload test image
2. Set scaling = 2x, DPI = 300
3. Upscale
4. Export PNG
5. Verify download
6. Verify EXIF in output
```

### Performance Tests
```javascript
// Measure processing time
console.time('upscale')
await upscaleWithTensorflow(4)
console.timeEnd('upscale')

// Monitor memory
console.memory.usedJSHeapSize
```

---

## Deployment Architecture

### Gist Deployment
```
GitHub Gist
  ├─ Single index.html (40 KB)
  ├─ CDN links for libraries
  └─ 100% client-side processing
  
URL: https://gist.githubusercontent.com/.../raw/index.html
```

### GitHub Pages Deployment
```
GitHub Repository
  ├─ index.html
  ├─ README.md
  ├─ DEPLOYMENT.md
  └─ Documentation files
  
URL: https://yourusername.github.io/repo-name/
```

### Static Host Deployment
```
Any static host (Netlify, Vercel, etc.)
  ├─ index.html
  ├─ Optional: Additional docs
  └─ No backend needed
  
URL: https://your-domain.com/
```

---

## Security Considerations

✅ **Security Features:**
- No server communication (data stays local)
- No cookies or tracking
- HTTPS recommended for deployment
- No sensitive API keys

⚠️ **Considerations:**
- Browser memory limits (design constraint, not security)
- CORS for external model loading (if using ESRGAN)
- File input limitations (browser sandbox)

---

## Future Architecture Improvements

1. **IndexedDB Caching**
   - Cache models locally for offline use
   - Faster repeated access

2. **Service Workers**
   - Enable true offline mode
   - Background processing

3. **Web Workers**
   - Process images off main thread
   - Prevent UI freezing

4. **Tiling Engine**
   - Handle massive images
   - Reduce memory peak

5. **Multi-format Support**
   - WEBP export
   - TIFF for print
   - AVIF for next-gen

---

## Code Statistics

```
Total lines of code:     ~800 lines
  - HTML:                ~150 lines
  - CSS:                 ~300 lines
  - JavaScript:          ~350 lines

Bundle size:             ~40 KB (minified)
With gzip:               ~12 KB
With BROTLI:             ~10 KB

Dependencies:            4 libraries via CDN
Build tools:             None (0 dependencies)
Package manager:         Not needed
```

---

This architecture is designed for:
✅ Simplicity - Easy to understand and modify
✅ Performance - Fast and efficient processing
✅ Reliability - Graceful error handling
✅ Accessibility - Works offline, no backend
✅ Scalability - Can handle 5000×5000px images
✅ Maintainability - Well-documented, modular code
