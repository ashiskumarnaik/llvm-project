# LLVM Backend Architectures

## Overview

This document lists all the backend architectures currently implemented in the LLVM codebase. These backends are responsible for translating LLVM IR (the platform-independent intermediate representation) into machine code for specific processor architectures.

## Location in Codebase

All backend implementations are located in:
```
/llvm/lib/Target/
```

Each subdirectory represents a complete backend for a specific architecture.

## Complete List of Backend Architectures

Based on the current codebase (`/llvm/lib/Target/`), LLVM supports the following **27 target architectures**:

### 1. **AArch64** (`/llvm/lib/Target/AArch64/`)
- **Description**: 64-bit ARM architecture
- **Used in**: Apple Silicon (M1/M2/M3/M4), AWS Graviton, ARM server chips
- **Key features**: NEON SIMD, SVE (Scalable Vector Extension)
- **Status**: Tier 1 (production-ready, fully supported)
- **Applications**: Smartphones, tablets, servers, laptops (Apple Mac)

### 2. **AMDGPU** (`/llvm/lib/Target/AMDGPU/`)
- **Description**: AMD Graphics Processing Units
- **Used in**: AMD Radeon GPUs, AMD Instinct accelerators
- **Key features**: Massive parallelism, RDNA/CDNA architectures
- **Status**: Tier 1
- **Applications**: Graphics rendering, HPC, machine learning, cryptocurrency mining

### 3. **ARC** (`/llvm/lib/Target/ARC/`)
- **Description**: Synopsys ARC processors
- **Used in**: Embedded systems, IoT devices, storage controllers
- **Key features**: Configurable 32-bit RISC architecture
- **Status**: Tier 3 (less tested, community maintained)
- **Applications**: Embedded systems, SSD controllers

### 4. **ARM** (`/llvm/lib/Target/ARM/`)
- **Description**: 32-bit ARM architecture (ARMv7 and earlier)
- **Used in**: Older smartphones, embedded systems, Raspberry Pi
- **Key features**: Thumb/Thumb-2 instruction sets, NEON SIMD
- **Status**: Tier 1
- **Applications**: Embedded systems, IoT, legacy mobile devices

### 5. **AVR** (`/llvm/lib/Target/AVR/`)
- **Description**: Atmel AVR 8-bit microcontrollers
- **Used in**: Arduino, embedded systems
- **Key features**: 8-bit architecture, Harvard architecture
- **Status**: Tier 3
- **Applications**: Microcontroller projects, Arduino boards, hobby electronics

### 6. **BPF** (`/llvm/lib/Target/BPF/`)
- **Description**: Berkeley Packet Filter / Extended BPF (eBPF)
- **Used in**: Linux kernel tracing, networking, security
- **Key features**: Virtual ISA for kernel programs, JIT compilation
- **Status**: Tier 2 (well-maintained, widely used)
- **Applications**: Network filtering, performance monitoring, security (Cilium, BCC tools)

### 7. **CSKY** (`/llvm/lib/Target/CSKY/`)
- **Description**: C-SKY processors (Chinese processor architecture)
- **Used in**: Embedded systems, primarily in China
- **Key features**: 32-bit RISC architecture
- **Status**: Tier 3
- **Applications**: Embedded systems, IoT

### 8. **DirectX** (`/llvm/lib/Target/DirectX/`)
- **Description**: DirectX Intermediate Language (DXIL) for GPU shaders
- **Used in**: Microsoft DirectX graphics, Windows gaming
- **Key features**: Shader compilation target
- **Status**: Tier 2
- **Applications**: Game development, GPU computing on Windows

### 9. **Hexagon** (`/llvm/lib/Target/Hexagon/`)
- **Description**: Qualcomm Hexagon DSP
- **Used in**: Qualcomm Snapdragon SoCs
- **Key features**: VLIW architecture, vector processing, neural network acceleration
- **Status**: Tier 1 (Qualcomm-supported)
- **Applications**: Mobile signal processing, AI inference on smartphones

### 10. **Lanai** (`/llvm/lib/Target/Lanai/`)
- **Description**: Lanai processor (Google's custom processor)
- **Used in**: Google's internal systems
- **Key features**: 32-bit RISC architecture
- **Status**: Tier 3
- **Applications**: Specialized embedded systems

### 11. **LoongArch** (`/llvm/lib/Target/LoongArch/`)
- **Description**: LoongArch (Chinese RISC architecture by Loongson)
- **Used in**: Loongson processors
- **Key features**: 64-bit RISC, SIMD extensions
- **Status**: Tier 2
- **Applications**: Chinese domestic processors, servers, desktops

### 12. **M68k** (`/llvm/lib/Target/M68k/`)
- **Description**: Motorola 680x0 family
- **Used in**: Legacy systems (Amiga, early Macintosh, Atari)
- **Key features**: CISC architecture, 32-bit
- **Status**: Tier 3
- **Applications**: Retro computing, legacy system maintenance

### 13. **MSP430** (`/llvm/lib/Target/MSP430/`)
- **Description**: Texas Instruments MSP430 microcontroller
- **Used in**: Ultra-low-power embedded systems
- **Key features**: 16-bit RISC, extremely low power consumption
- **Status**: Tier 3
- **Applications**: IoT sensors, battery-powered devices, medical devices

### 14. **Mips** (`/llvm/lib/Target/Mips/`)
- **Description**: MIPS architecture (32-bit and 64-bit)
- **Used in**: Routers, embedded systems, legacy systems
- **Key features**: RISC architecture, load-store
- **Status**: Tier 2
- **Applications**: Networking equipment, embedded systems, PlayStation 1/2

### 15. **NVPTX** (`/llvm/lib/Target/NVPTX/`)
- **Description**: NVIDIA PTX (Parallel Thread Execution)
- **Used in**: NVIDIA GPUs (CUDA programming)
- **Key features**: Virtual ISA for NVIDIA GPUs, massive parallelism
- **Status**: Tier 1 (NVIDIA-supported)
- **Applications**: HPC, deep learning, scientific computing, CUDA development

### 16. **PowerPC** (`/llvm/lib/Target/PowerPC/`)
- **Description**: PowerPC architecture (32-bit and 64-bit)
- **Used in**: IBM Power servers, older Macs, embedded systems
- **Key features**: RISC architecture, AltiVec/VSX SIMD
- **Status**: Tier 1
- **Applications**: IBM Power servers, high-performance computing, legacy Macs

### 17. **RISCV** (`/llvm/lib/Target/RISCV/`)
- **Description**: RISC-V (open-source ISA)
- **Used in**: Emerging processors, SiFive chips, ESP32, research
- **Key features**: Open-source ISA, modular extensions, growing ecosystem
- **Status**: Tier 1 (rapidly growing)
- **Applications**: Embedded systems, IoT, research processors, SiFive boards

### 18. **SPIRV** (`/llvm/lib/Target/SPIRV/`)
- **Description**: SPIR-V (Standard Portable Intermediate Representation for Vulkan)
- **Used in**: Vulkan graphics, OpenCL, compute shaders
- **Key features**: Intermediate representation for GPUs/accelerators
- **Status**: Tier 2
- **Applications**: Cross-platform GPU computing, Vulkan shaders, OpenCL

### 19. **Sparc** (`/llvm/lib/Target/Sparc/`)
- **Description**: SPARC architecture (Scalable Processor Architecture)
- **Used in**: Oracle/Sun servers
- **Key features**: RISC architecture, register windows
- **Status**: Tier 2
- **Applications**: Oracle servers, legacy Unix systems

### 20. **SystemZ** (`/llvm/lib/Target/SystemZ/`)
- **Description**: IBM z/Architecture (mainframes)
- **Used in**: IBM mainframes (z/OS, z/VM, z/Linux)
- **Key features**: 64-bit, SIMD, high reliability features
- **Status**: Tier 1 (IBM-supported)
- **Applications**: Enterprise mainframes, banking systems, critical infrastructure

### 21. **VE** (`/llvm/lib/Target/VE/`)
- **Description**: NEC SX-Aurora TSUBASA Vector Engine
- **Used in**: NEC vector processors for HPC
- **Key features**: Vector processing, high memory bandwidth
- **Status**: Tier 3
- **Applications**: High-performance computing, scientific simulations

### 22. **WebAssembly** (`/llvm/lib/Target/WebAssembly/`)
- **Description**: WebAssembly (Wasm) virtual ISA
- **Used in**: Web browsers, serverless computing, portable applications
- **Key features**: Platform-independent bytecode, sandboxed execution
- **Status**: Tier 1
- **Applications**: Web applications, browser-based computing, WASI (WebAssembly System Interface)

### 23. **X86** (`/llvm/lib/Target/X86/`)
- **Description**: Intel/AMD x86 (32-bit) and x86-64 (64-bit)
- **Used in**: Desktop PCs, laptops, servers (Intel, AMD)
- **Key features**: CISC architecture, SSE/AVX SIMD, most complex backend
- **Status**: Tier 1 (most mature, extensively optimized)
- **Applications**: Desktop/server computing, gaming, data centers

### 24. **XCore** (`/llvm/lib/Target/XCore/`)
- **Description**: XMOS XCore processors
- **Used in**: Real-time embedded systems, audio/video processing
- **Key features**: Multi-core, deterministic timing
- **Status**: Tier 3
- **Applications**: Audio processing, industrial control

### 25. **Xtensa** (`/llvm/lib/Target/Xtensa/`)
- **Description**: Tensilica Xtensa processors
- **Used in**: ESP32/ESP8266 microcontrollers, DSPs
- **Key features**: Configurable architecture, widely used in IoT
- **Status**: Tier 3
- **Applications**: IoT devices, Wi-Fi modules (ESP32), smart home devices

## Architecture Tiers

LLVM categorizes targets into tiers based on support level:

### **Tier 1** - Production Ready
- Actively maintained by LLVM core team or major companies
- Extensive testing in CI/CD
- Used in production by major companies
- Examples: **X86**, **AArch64**, **ARM**, **NVPTX**, **PowerPC**, **SystemZ**, **RISCV**, **WebAssembly**

### **Tier 2** - Well Maintained
- Maintained but may have fewer resources
- Regular testing but not as extensive as Tier 1
- Examples: **BPF**, **DirectX**, **LoongArch**, **Mips**, **SPIRV**, **Sparc**

### **Tier 3** - Community Maintained
- Less active maintenance
- May have missing features or bugs
- Used in niche applications
- Examples: **ARC**, **AVR**, **CSKY**, **Lanai**, **M68k**, **MSP430**, **VE**, **XCore**, **Xtensa**

## Target Backend Components

Each target backend typically consists of:

### Core Files
```
Target/ARCH/
├── ARCHAsmPrinter.cpp          # Convert LLVM IR to assembly text
├── ARCHCallingConv.td          # Calling convention definitions
├── ARCHFrameLowering.cpp       # Stack frame management
├── ARCHISelDAGToDAG.cpp        # Instruction selection (DAG-to-DAG)
├── ARCHISelLowering.cpp        # Target-specific lowering
├── ARCHInstrInfo.cpp           # Instruction information
├── ARCHInstrInfo.td            # Instruction definitions (TableGen)
├── ARCHMCInstLower.cpp         # Lower MachineInstr to MCInst
├── ARCHRegisterInfo.cpp        # Register information
├── ARCHRegisterInfo.td         # Register definitions (TableGen)
├── ARCHSubtarget.cpp           # Subtarget features
├── ARCHTargetMachine.cpp       # Target machine definition
└── MCTargetDesc/               # MC layer (machine code)
    ├── ARCHMCAsmInfo.cpp
    ├── ARCHMCCodeEmitter.cpp   # Emit machine code bytes
    └── ARCHMCTargetDesc.cpp
```

### What Each Backend Does

1. **Instruction Selection**: Convert LLVM IR to target-specific instructions
2. **Register Allocation**: Assign virtual registers to physical registers
3. **Instruction Scheduling**: Reorder instructions for performance
4. **Code Emission**: Generate actual machine code bytes
5. **Assembly Printing**: Output human-readable assembly
6. **Target-Specific Optimizations**: Peephole optimizations, etc.

## Backend Complexity (File Count)

Approximate file counts (`.cpp` + `.h` files):

| Target | Complexity | Notable Characteristics |
|--------|-----------|------------------------|
| **X86** | ~150+ files | Most complex, decades of ISA extensions (SSE, AVX, AVX-512) |
| **AMDGPU** | ~280+ files | Extremely complex due to GPU architecture |
| **ARM/AArch64** | ~120+ files each | Mature, heavily optimized |
| **Hexagon** | ~120+ files | Complex VLIW architecture |
| **RISCV** | ~140+ files | Growing rapidly, modular extensions |
| **PowerPC** | ~100+ files | Mature with AltiVec/VSX |
| **Mips** | ~110+ files | Multiple variants (32/64-bit, DSP) |
| **WebAssembly** | ~85+ files | Relatively simple virtual ISA |
| **BPF** | ~45+ files | Minimal, kernel-focused ISA |
| **AVR** | ~40+ files | Simple 8-bit architecture |

## How Backends Are Used

When you compile code with LLVM:

```bash
# Specify target with -target or --target
clang -target x86_64-linux-gnu mycode.c -o mycode
clang -target aarch64-apple-darwin mycode.c -o mycode  # Apple Silicon
clang -target riscv64-unknown-elf mycode.c -o mycode   # RISC-V

# Or use architecture-specific flags
clang -march=armv8-a mycode.c -o mycode
clang -march=x86-64-v3 mycode.c -o mycode

# For embedded targets
clang -target avr mycode.c -mmcu=atmega328p -o mycode.elf
clang -target msp430 mycode.c -o mycode.elf
```

## Cross-Compilation

LLVM's architecture makes cross-compilation trivial:

```bash
# Compile on x86-64 for ARM
clang -target arm-linux-gnueabihf mycode.c -o mycode

# Compile on macOS for WebAssembly
clang -target wasm32-wasi mycode.c -o mycode.wasm

# Compile for RISC-V from any host
clang -target riscv64-linux-gnu mycode.c -o mycode
```

This is possible because:
1. Frontend generates platform-independent LLVM IR
2. Backend transforms IR to target-specific machine code
3. All backends are available in every LLVM build

## Adding a New Backend

To add support for a new architecture, you need to:

1. **Create target directory**: `/llvm/lib/Target/NEWARCH/`
2. **Define instruction set**: Write `.td` (TableGen) files describing instructions
3. **Implement backend classes**:
   - `NEWARCHTargetMachine`
   - `NEWARCHInstrInfo`
   - `NEWARCHRegisterInfo`
   - `NEWARCHFrameLowering`
   - `NEWARCHISelLowering`
4. **Register target**: Add to LLVM's target registry
5. **Add tests**: Create test cases for the new backend
6. **Document**: Add architecture documentation

Example of a minimal backend: Look at **AVR** or **MSP430** for relatively simple examples.

## Backend Testing

Each backend has extensive test suites in:
```
/llvm/test/CodeGen/ARCH/
```

For example:
- `/llvm/test/CodeGen/X86/` - X86 backend tests
- `/llvm/test/CodeGen/AArch64/` - AArch64 backend tests
- `/llvm/test/CodeGen/RISCV/` - RISC-V backend tests

## Popular Use Cases by Backend

### Most Used (Production)
1. **X86** - Data centers, desktops, laptops (Intel, AMD)
2. **AArch64** - Smartphones, Apple Silicon Macs, AWS Graviton servers
3. **ARM** - Embedded systems, Raspberry Pi, legacy phones
4. **NVPTX** - Deep learning (TensorFlow, PyTorch), HPC
5. **WebAssembly** - Web applications, serverless (Fastly, Cloudflare Workers)

### Specialized
1. **AMDGPU** - Machine learning, cryptocurrency mining
2. **BPF** - Linux kernel tracing and networking (Cilium, eBPF programs)
3. **Hexagon** - Mobile DSP (Qualcomm smartphones)
4. **SystemZ** - Enterprise mainframes

### Emerging
1. **RISCV** - Open hardware, research, embedded
2. **LoongArch** - Chinese processors

### Embedded/IoT
1. **AVR** - Arduino, hobbyist projects
2. **MSP430** - Ultra-low-power sensors
3. **Xtensa** - ESP32 Wi-Fi modules
4. **ARM** - General embedded

### Legacy/Niche
1. **M68k** - Retro computing
2. **Sparc** - Oracle servers
3. **Mips** - Network equipment, legacy embedded

## Conclusion

LLVM supports **27 diverse architectures**, from 8-bit microcontrollers (AVR) to massive mainframes (SystemZ), from CPUs (X86, ARM) to GPUs (NVPTX, AMDGPU), and even virtual machines (WebAssembly, BPF).

This is the power of LLVM's three-phase design:
```
Language Frontend → LLVM IR → Target Backend → Machine Code
```

Once you generate LLVM IR (as explained in the frontend development guide), you can target **any of these 27 architectures** without writing any architecture-specific code!

## Resources

- **Backend Development Guide**: `/llvm/docs/WritingAnLLVMBackend.rst`
- **Target Description Files**: `/llvm/lib/Target/*/README*`
- **Target Tests**: `/llvm/test/CodeGen/*/`
- **TableGen Documentation**: `/llvm/docs/TableGen/`

## Related Documents

- `llvm-frontend-development-guide.md` - How to write language frontends
- `llvm-architecture-and-language-frontends.md` - LLVM architecture overview
