# Detailed Analysis: RFSoC_calibration.ipynb

## 📋 Executive Summary

The notebook **RFSoC_calibration.ipynb** performs a **complete end-to-end calibration** that converts input RF signals (dBm) to system digital values (dBFS). It consists of 6 sections that progressively refine the calibration.

### General Flow
```
Pin_gen (dBm) 
  ↓
[Cable] → Pin_adc
  ↓
[ADC→16bit] → BUFFER_ADC → FFT → K_adc = -22.89 dB
  ↓
[PFB ÷64] → BUFFER_PFB → FFT → CAL_CONSTANT = -3.21 dB
  ↓
Pin_recovered = P_digital + CAL_CONSTANT
```

---

## 🔍 Analysis by Section

### **SECTION 1: Cable Attenuation (Lines 16-35)**

**Objective**: Measure RF cable attenuation

**Code**:
```python
with SlabFile('D:\\Morgan\\20260206_cooldown\\data\\' + date + '\\' + file_path, 'r') as f:
    freq = np.array(f['fpts'][:])[0]
    mag_S21 = np.array(f['mags'][:])[0]
```

**Problem**: 🔴 Hardcoded absolute Windows path
- Will not be portable across machines
- File likely does not exist at that location

**Expected output**: `cable_atten_dB` (scalar in dB @ 13.5 MHz)

**Impact**: Required to correct analog attenuation, but currently **not used** in subsequent sections

**Recommended solution**:
```python
from pathlib import Path

DATA_BASE = Path('data')
DATE = '20260327'
file_path = DATA_BASE / DATE / '00000_20260327_RfSoc_Cal_Cable0.01GHzCF_2.0MHzSpan.h5'

if file_path.exists():
    with SlabFile(file_path, 'r') as f:
        freq = np.array(f['fpts'][:])[0]
        mag_S21 = np.array(f['mags'][:])[0]
        cable_atten_dB = np.round(mag_S21[ind], 4)
else:
    print(f"⚠️  Cable attenuation file not found. Using default: 0 dB")
    cable_atten_dB = 0.0
```

---

### **SECTION 2: ADC Functions (Lines 44-96)**

**Objective**: Define ADC LSB → dBm conversion functions

**Function 1: `lsb_to_dBm()`**
- Converts raw ADC code → RMS voltage → dBm power
- Parameters: N=12 bits, Vref=2.0V, R=50Ω
- Assumes sinusoid: V_RMS = V_peak / √2

**Function 2: `signed_adc_to_dBm()`**
- Version for ADC centered at 0 (range: -2^11 to +2^11-1)
- Identical in concept but without DC offset

**Common formula**:
$$P_{\text{dBm}} = 10 \log_{10} \left( \frac{(adc\_code × \frac{V_{ref}}{2^N} / \sqrt{2})^2}{R × 1\text{mW}} \right)$$

**Status**: ✓ Correct and well documented

---

### **SECTION 3: ADC Calibration Data (Lines 108-307)**

**Objective**: Determine the ADC calibration constant (K_adc)

#### 3a. System Parameters
```python
Fs_orig = 4096e6      # Original ADC sampling rate (MHz)
D = 2                 # Decimation factor
Fs = 2048e6           # Effective sampling rate (MHz)
N_bits = 16           # Bits in FPGA (12-bit ADC MSB-aligned)
FS = 2^15 = 32768     # Full-scale reference amplitude
f_tone = 13.5e6       # Test tone frequency
```

**Important note**: ADC is 12-bit but MSB-aligned to 16-bit:
- D₁₆ = D₁₂ × 2⁴ (4-bit left shift)
- FS = 2^15 instead of 2^11

#### 3b. Data Loading and Processing

**21 files** with known powers: [-40, -38, -35, ..., +8, +10] dBm

**For each file**:
1. Extract BUFFER_ADC: xi_adc, xq_adc
2. Form complex signal: x_adc_t = xi_adc + 1j·xq_adc
3. **Hanning window**:
   ```python
   window = np.hanning(N)
   x_windowed = x_adc_t * window
   ```
4. **Normalized complex FFT**:
   ```python
   fft_complex = np.fft.fft(x_windowed) / N
   ```
5. **Amplitude in dBFS** (corrected for Coherent Gain=0.5):
   ```python
   mag_linear = np.abs(fft_complex) / 0.5
   mag_dbfs = 20 * np.log10(mag_linear / FS)
   ```
6. **PSD (Power Spectral Density)**:
   ```python
   enbw_hz = 1.5 * (Fs / N)  # Hanning ENBW
   psd_dbfs_hz = mag_dbfs - 10 * np.log10(enbw_hz)
   ```

#### 3c. Linear Calibration

**Measurements**:
- P_dBm: [-40, -38, ..., +10] (known input)
- dBFS_measured: [measured FFT peaks] (ADC output)

**Linear fit**:
```python
K = dBFS_measured[1] - P_dBm[1]  # Calibration constant
dBFS_fit = P_dBm + K
```

**Result**: 
$$\boxed{K_{adc} ≈ -22.89 \text{ dB}}$$

**Interpretation**:
- dBFS = P_dBm - 22.89
- Or equivalently: P_dBm = dBFS + 22.89
- Example: If P_dBm = -10, then dBFS ≈ -32.89

#### 3d. RMS Voltage Conversion

**Full-scale RMS**:
```python
V_FS_RMS = 0.354  # Volts (= 0.5V / sqrt(2))
```

**Measured voltage**:
```python
V_RMS_measured = V_FS_RMS * 10^(dBFS_measured/20)
```

**Status**: ✓ Section well executed, credible results

**Generated plots**:
1. Overlaid spectra (amplitude + PSD)
2. Calibration dBm ↔ dBFS
3. Calibration dBm ↔ RMS Voltage

---

### **SECTION 4: One File Analysis (Lines 313-326)**

**Objective**: Detailed analysis of ONE file (Pin = -10 dBm)

**Problem**: 🟡 Hardcoded path again
```python
with SlabFile('D:\\Morgan\\20260206_cooldown\\data\\' + date + '\\' + ..., 'r') as f:
```

**Status**: Cell executes with error (file missing)

**When it works**, generates:
- Temporal I/Q plot
- DC statistics: mean(I), mean(Q)
- Time and amplitude format

---

### **SECTION 5: PFB Fixed Qout (Lines 448-764)**

**Objective**: Complete PFB calibration from RF input

#### 5a. Theoretical Formulation

**Processing chain**:
```
Pin_gen (dBm)
    ↓ [−cable_atten_dB]
Pin_adc = Pin_gen - cable_atten_dB
    ↓ [ADC conversion]
P_adc_digital (dBFS) = Pin_adc + K_adc
    ↓ [PFB decimation ÷2^QOUT]
P_pfb_digital (dBFS) = P_adc_digital - PFB_SCALING
    ↓ [Combined]
P_pfb_digital = Pin_gen - cable_atten - (−K_adc) - PFB_SCALING
P_pfb_digital = Pin_gen - (cable_atten + PFB_SCALING - K_adc)

Inverting:
Pin_gen = P_pfb_digital + (cable_atten + PFB_SCALING - K_adc)
Pin_gen = P_pfb_digital + CAL_CONSTANT_THEORETICAL
```

Where:
$$CAL\_CONSTANT = PFB\_SCALING + cable\_atten - K_{adc}$$

#### 5b. Empirical Methodology

**To determine CAL_CONSTANT experimentally**:

1. **Load PFB data** from 21 files
2. **Apply FFT** over BUFFER_PFB
3. **Measure digital power** in dBFS
4. **Linear regression**:
   ```python
   Pin_gen_vals = [-40, -38, ..., +10]
   P_pfb_vals = [measured values in dBFS]
   
   coeffs = np.polyfit(P_pfb_vals, Pin_gen_vals, 1)
   slope = coeffs[0]       # Should be ≈ 1.0
   CAL_CONSTANT = coeffs[1]  # Offset in dB
   ```

#### 5c. Compression Point Analysis

Detects at what power the system ceases to be linear:
```python
for i in range(len(Pin_true)):
    if compression >= 1.0:  # 1 dB compression
        print(f"1 dB compression point: {Pin_true[i]} dBm")
```

#### 5d. Generated Plots

**4 subplots**:
1. **Recovered power vs true power** (should be 1:1 line)
2. **Error vs input power** (should be near 0)
3. **PFB digital level vs power** (should be linear)
4. **Error histogram** (distribution in linear region)

**Status**: ✓ Excellent structure, well documented

**Expected result**:
$$\boxed{CAL\_CONSTANT ≈ -3.21 \text{ dB}}$$

---

### **SECTION 6: Spectrum Analysis with Calibration (Lines 767-1130)**

**Objective**: Complete system validation with calibration applied

#### 6a. Spectral Processing

**For each input power**:
1. Load BUFFER_PFB
2. Complex FFT
3. Calculate amplitude in dBFS and dBm:
   ```python
   mag_dbm = mag_dbfs + CAL_CONSTANT
   ```
4. Extract tone characteristics:
   - Amplitude (dBm)
   - Phase (degrees)
   - Frequency (Hz)

#### 6b. Quality Analysis

**Amplitude**: Should follow 1:1 relationship with input
- Plot: Pin_input vs Tone_amplitude
- If constant offset: systematic error
- If slope ≠ 1: incorrect gain

**Phase**: Should be approximately constant (independent of power)
- Calculates:
  - std dev of phase
  - Correlation between phase and input
  - If |correlation| > 0.5: I/Q problem

**Frequency**: Should be stable at 13.5 MHz
- Verifies: f_peak = 13.5 ± δ MHz
- If varies significantly: clock reference problem

#### 6c. Generated Plots

**8 subplots**:
1. **Overlaid spectra** (multiple powers)
2. **2D waterfall** (all powers simultaneously)
3. **Amplitude vs input** (linearity)
4. **Phase vs input** (stability)
5. **Frequency vs input** (stability)
6. **Detailed tone zoom** (±10 MHz)
7. **I/Q constellation** (point distribution)
8. **Phase distribution** (histogram)

**Status**: ✓ Very complete, identifies subtle problems

**Detected issue**: 🟡 Around line ~700, there is a bug:
```python
# INCORRECT:
x_highest = xi_adc + 1j*xq_adc
x_highest = np.array(x, dtype=np.complex128)  # ← uses global 'x', not 'x_highest'

# CORRECT:
x_highest = xi_adc + 1j*xq_adc
x_highest = np.array(x_highest, dtype=np.complex128)
```

---

### **SECTION 7: Vary Qout (Lines 1136+)**

**Objective**: Characterize how CAL_CONSTANT changes with QOUT

#### 7a. Variable Parameter

**QOUT** ∈ [0, 1, 2, ..., 11]

Controls PFB gain:
- PFB_SCALING = 20·log₁₀(2^QOUT)
- QOUT=0 → 0 dB
- QOUT=6 → 36.12 dB (reduces power by 64×)
- QOUT=11 → 66.22 dB

#### 7b. Theoretical Prediction

Given that it is a power of 2:
$$\Delta CAL\_CONSTANT = -6.02 \times (\text{QOUT} - \text{QOUT}_{\text{ref}})$$

Example:
- QOUT_ref = 6, C_ref = -3.21 dB
- QOUT = 7: C = -3.21 - 6.02 = -9.23 dB
- QOUT = 5: C = -3.21 + 6.02 = +2.81 dB

#### 7c. Experimental Validation

For each QOUT:
1. Load calibrated data
2. Empirically calculate CAL_CONSTANT
3. Compare with theoretical prediction
4. Tabulate results

**Status**: In progress, clear structure

---

## ⚠️  Problems Identified

### **Critical**

| # | Line | Problem | Impact | Solution |
|----|--------|---------|---------|----------|
| 1 | 16-35 | Absolute Windows path | Cannot execute | Use relative path |
| 2 | 313-326 | Absolute Windows path | Cell with error | Use relative path |
| 3 | ~700 | Variable `x` vs `x_highest` | Incorrect data in I/Q | Correct to `x_highest` |

### **Warnings**

| # | Line | Topic | Note |
|----|--------|------|------|
| 4 | 448 | Variable `K` global | Depends on Section 3 |
| 5 | All | `date` variable | Hardcoded, update manually |
| 6 | 1136+ | Multiple files | Experimental section, incomplete |

---

## ✅ Recommended Execution Flow

```
1. [Run] Cell 1: Imports
   └─ Output: libraries loaded

2. [SKIP] Cell 2: Cable Attenuation
   └─ Problem: file missing. Use cable_atten_dB = 0.0

3. [Run] Cell 3: ADC Functions
   └─ Output: conversion functions defined

4. [Run] Cell 4: ADC Calibration Data
   └─ Output: K_adc ≈ -22.89 dB, plots 1-3
   └─ IMPORTANT: Defines 'K' for Section 4

5. [SKIP or FIX] Cell 5: One File Analysis
   └─ Problem: incorrect path
   └─ Solution: change to relative path or use data from Section 4

6. [Run] Cell 6: PFB Fixed Qout
   └─ Dependency: uses 'K' from Section 4
   └─ Output: CAL_CONSTANT ≈ -3.21 dB, plots 4-7
   └─ IMPORTANT: Defines complete calibration

7. [Run] Cell 7: Spectrum Analysis
   └─ Dependency: uses CAL_CONSTANT from Section 6
   └─ FIX: Change 'x' to 'x_highest' at line ~700
   └─ Output: amplitude, phase, frequency analysis

8. [Experimental] Cell 8: Vary Qout
   └─ Under development
   └─ Verifies theoretical prediction vs experimental
```

---

## 📈 Key Constants Table

| Parameter | Value | Unit | Source | Note |
|-----------|-------|--------|--------|------|
| Fs_orig | 4096 | MHz | ADC | Before decimation |
| Fs | 2048 | MHz | System | With D=2 |
| Fs_pfb | 256 | MHz | PFB | Fs / 8 (D_total) |
| FS | 32768 | - | FPGA | 2^15 full-scale |
| f_tone | 13.5 | MHz | Setup | Test frequency |
| K_adc | -22.89 | dB | Measured Sec.3 | ADC calibration |
| V_FS_RMS | 0.354 | V | ADC Spec | 0.5V / √2 |
| QOUT | 6 | - | Config | PFB scaling factor |
| PFB_SCALING | 36.12 | dB | Calc | 20log10(64) |
| CAL_CONSTANT | -3.21 | dB | Measured Sec.4 | Final calibration |
| Linear range | -40 to +10 | dBm | Measured | Before saturation |

---

## 📊 Summary Formulas

### ADC Level (Section 3)
$$\text{dBFS}_{ADC} = P_{\text{dBm}} + K_{adc}$$
$$\text{where } K_{adc} = -22.89 \text{ dB}$$

### PFB Scaling
$$\text{dBFS}_{PFB} = \text{dBFS}_{ADC} - 20 \log_{10}(2^{QOUT})$$
$$= \text{dBFS}_{ADC} - 6.02 \times QOUT$$

### Input Power Recovery (Section 4)
$$P_{\text{RF (dBm)}} = \text{dBFS}_{PFB} + CAL\_CONSTANT$$
$$\text{where } CAL\_CONSTANT = -3.21 \text{ dB}$$

### Adjustment by QOUT
$$CAL\_CONSTANT(QOUT) = C_{ref} - 6.02 × (QOUT - QOUT_{ref})$$

---

## 🎯 Recommended Next Actions

### 1. Immediate Corrections
- [ ] Change hardcoded paths (Sections 1, 4)
- [ ] Fix variable `x` → `x_highest` (line ~700)
- [ ] Parametrize `date` variable

### 2. Documentation Improvements
- [ ] Add descriptive titles to each section
- [ ] Document explicit dependencies between sections
- [ ] Include summary constants table at the beginning

### 3. Validation
- [ ] Verify that regression slope ≈ 1.0 (linearity)
- [ ] Create robustness test (what if files are missing?)
- [ ] Validate phase stability with quantitative metrics

### 4. Refactoring (Optional)
- [ ] Separate into multiple notebooks (by stage)
- [ ] Create reusable `load_calibration_data()` function
- [ ] Use configuration file (.yaml) for constants

---

## 💡 Conclusion

The notebook **RFSoC_calibration.ipynb** is a **powerful and well-designed tool** that performs complete system calibration. The structure is logical and progressive, with good theoretical documentation.

**Minor issues** (paths, variables) are easy to fix. Once corrected, the notebook should provide reliable and reproducible calibration.

**Recommendation**: Complete the path corrections and re-execute all sections sequentially to obtain fully validated calibration.

