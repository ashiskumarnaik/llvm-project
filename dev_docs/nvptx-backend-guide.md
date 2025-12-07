# NVPTX Backend Guide - LLVM IR to NVIDIA GPU Code

## Overview

The NVPTX backend is responsible for converting LLVM IR (platform-independent intermediate representation) into PTX (Parallel Thread Execution) assembly code that runs on NVIDIA GPUs. PTX is NVIDIA's virtual instruction set for CUDA programming.

## Location in Codebase

**Main Directory:**
```
/llvm/lib/Target/NVPTX/
```

This directory contains all the code that transforms LLVM IR into NVIDIA PTX assembly.

## Complete File Structure

```
/llvm/lib/Target/NVPTX/
├── NVPTX.h                              # Main header file
├── NVPTX.td                             # Target description (TableGen)
│
├── NVPTXTargetMachine.cpp               # Entry point - Target machine definition
├── NVPTXTargetMachine.h                 # Configures the compilation pipeline
│
├── NVPTXISelLowering.cpp                # Instruction selection lowering (279KB!)
├── NVPTXISelLowering.h                  # Converts LLVM IR ops to target ops
│
├── NVPTXISelDAGToDAG.cpp                # DAG-to-DAG instruction selection
├── NVPTXISelDAGToDAG.h                  # Pattern matching for instructions
│
├── NVPTXAsmPrinter.cpp                  # Assembly output (converts to PTX text)
├── NVPTXAsmPrinter.h                    # Generates human-readable PTX
│
├── NVPTXInstrInfo.cpp                   # Instruction information
├── NVPTXInstrInfo.h                     # Instruction properties
├── NVPTXInstrInfo.td                    # Instruction definitions (TableGen)
├── NVPTXInstrFormats.td                 # Instruction format templates
│
├── NVPTXRegisterInfo.cpp                # Register information
├── NVPTXRegisterInfo.h                  # Register allocation support
├── NVPTXRegisterInfo.td                 # Register definitions (TableGen)
│
├── NVPTXFrameLowering.cpp               # Stack frame management
├── NVPTXFrameLowering.h                 # (minimal for GPU - no stack!)
│
├── NVPTXSubtarget.cpp                   # GPU capability detection
├── NVPTXSubtarget.h                     # SM version, features
│
├── NVPTXIntrinsics.td                   # CUDA intrinsic definitions (277KB!)
│
├── NVPTXTargetTransformInfo.cpp         # Cost model for optimizations
├── NVPTXTargetTransformInfo.h           # GPU-specific optimization hints
│
├── NVPTXUtilities.cpp                   # Helper functions
├── NVPTXUtilities.h                     # Utility code
│
├── NVPTX-specific lowering passes:
├── NVPTXGenericToNVVM.cpp               # Generic LLVM to NVVM transformations
├── NVPTXLowerAlloca.cpp                 # Lower alloca instructions
├── NVPTXLowerArgs.cpp                   # Lower function arguments
├── NVPTXLowerAggrCopies.cpp             # Lower aggregate copies
├── NVPTXLowerUnreachable.cpp            # Handle unreachable code
├── NVPTXAtomicLower.cpp                 # Lower atomic operations
├── NVPTXCtorDtorLowering.cpp            # Lower constructors/destructors
├── NVPTXAllocaHoisting.cpp              # Optimize alloca placement
├── NVPTXProxyRegErasure.cpp             # Remove proxy registers
├── NVPTXPrologEpilogPass.cpp            # Function prologue/epilogue
├── NVPTXPeephole.cpp                    # Peephole optimizations
├── NVPTXReplaceImageHandles.cpp         # Handle texture/surface ops
├── NVPTXImageOptimizer.cpp              # Optimize image operations
├── NVPTXAssignValidGlobalNames.cpp      # Sanitize global names
├── NVPTXAliasAnalysis.cpp               # GPU-specific alias analysis
├── NVPTXTagInvariantLoads.cpp           # Mark invariant memory loads
├── NVPTXForwardParams.cpp               # Forward function parameters
│
├── NVVM Reflection and Range Analysis:
├── NVVMReflect.cpp                      # Handle NVVM reflection
├── NVVMIntrRange.cpp                    # Range information for intrinsics
│
├── Machine Code Layer:
├── MCTargetDesc/                        # MC (Machine Code) layer
│   ├── NVPTXMCAsmInfo.cpp              # Assembly syntax info
│   ├── NVPTXMCTargetDesc.cpp           # MC target descriptor
│   ├── NVPTXInstPrinter.cpp            # Pretty-print instructions
│   ├── NVPTXBaseInfo.h                 # Base definitions
│   └── NVPTXTargetStreamer.cpp         # Stream PTX output
│
├── Target Registration:
└── TargetInfo/
    └── NVPTXTargetInfo.cpp              # Register NVPTX with LLVM
```

## How LLVM IR Becomes NVIDIA PTX Code

### The Transformation Pipeline

```
LLVM IR (from any language)
    ↓
┌─────────────────────────────────────────────────────────┐
│ 1. NVPTXTargetMachine - Pipeline Configuration          │
│    Location: NVPTXTargetMachine.cpp:91-100             │
└─────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────┐
│ 2. NVPTX-Specific IR Passes                            │
│    - NVPTXGenericToNVVM: Generic → NVVM                │
│    - NVPTXLowerAlloca: Handle local memory              │
│    - NVPTXLowerArgs: Handle function arguments          │
│    - NVPTXAtomicLower: Lower atomic ops                │
│    Location: Various NVPTX*.cpp files                   │
└─────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────┐
│ 3. Instruction Selection (ISelLowering)                │
│    - Convert LLVM IR operations to PTX operations       │
│    - Location: NVPTXISelLowering.cpp (279KB!)          │
│    - Example: LLVM 'add' → PTX 'add.s32'               │
└─────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────┐
│ 4. DAG-to-DAG Instruction Selection                     │
│    - Pattern matching for complex instructions          │
│    - Location: NVPTXISelDAGToDAG.cpp:85-100            │
│    - Select optimal PTX instructions                    │
└─────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────┐
│ 5. Register Allocation                                  │
│    - Assign virtual registers to PTX registers          │
│    - Location: NVPTXRegisterInfo.cpp                    │
│    - PTX has unlimited virtual registers!               │
└─────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────┐
│ 6. PTX Assembly Generation                              │
│    - Convert machine instructions to PTX text           │
│    - Location: NVPTXAsmPrinter.cpp:1-100               │
│    - Output human-readable PTX assembly                 │
└─────────────────────────────────────────────────────────┘
    ↓
PTX Assembly (.ptx file)
    ↓
NVIDIA Driver (ptxas)
    ↓
CUDA Binary (CUBIN) - GPU Machine Code
```

## Key Files and Their Roles

### 1. **NVPTXTargetMachine.cpp** - The Entry Point

**Location:** `/llvm/lib/Target/NVPTX/NVPTXTargetMachine.cpp:1-100`

**What it does:**
- Initializes the NVPTX backend
- Registers NVPTX with LLVM's target system
- Configures the compilation pipeline
- Sets up target-specific passes

**Key code (lines 91-100):**
```cpp
extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeNVPTXTarget() {
  // Register the target - this makes NVPTX available to LLVM
  RegisterTargetMachine<NVPTXTargetMachine32> X(getTheNVPTXTarget32());
  RegisterTargetMachine<NVPTXTargetMachine64> Y(getTheNVPTXTarget64());

  // Initialize NVPTX-specific passes
  PassRegistry &PR = *PassRegistry::getPassRegistry();
  initializeNVVMReflectLegacyPassPass(PR);
  initializeNVVMIntrRangePass(PR);
  // ... more passes
}
```

This is called when LLVM starts up, making NVPTX available as a compilation target.

### 2. **NVPTXISelLowering.cpp** - Instruction Selection (THE CORE!)

**Location:** `/llvm/lib/Target/NVPTX/NVPTXISelLowering.cpp:1-100`

**Size:** 279KB (one of the largest files!)

**What it does:**
- **Most important file for LLVM IR → PTX transformation**
- Converts high-level LLVM operations to GPU-specific operations
- Handles calling conventions, memory operations, intrinsics
- Implements GPU-specific optimizations

**Examples of transformations:**
- LLVM `add i32` → PTX `add.s32`
- LLVM `load` → PTX `ld.global` or `ld.shared` (depending on address space)
- LLVM `call` → PTX function call with GPU calling convention
- LLVM atomic operations → PTX `atom.*` instructions

**Key functions:**
- `LowerOperation()` - Main entry point for lowering
- `LowerCall()` - Handle function calls
- `LowerReturn()` - Handle function returns
- `LowerGlobalAddress()` - Handle global variables

### 3. **NVPTXISelDAGToDAG.cpp** - Pattern Matching

**Location:** `/llvm/lib/Target/NVPTX/NVPTXISelDAGToDAG.cpp:85-100`

**What it does:**
- Uses TableGen-generated patterns to select instructions
- Matches complex instruction patterns
- Optimizes instruction selection
- Handles addressing modes

**Example:**
```cpp
// Select the best PTX instruction for a given LLVM operation
SDNode *NVPTXDAGToDAGISel::Select(SDNode *N) {
  // Pattern matching logic here
  // Example: Match multiply-add patterns to use fma.rn.f32
}
```

### 4. **NVPTXAsmPrinter.cpp** - PTX Text Generation

**Location:** `/llvm/lib/Target/NVPTX/NVPTXAsmPrinter.cpp:1-100`

**What it does:**
- **Final step: Generate human-readable PTX assembly**
- Converts machine instructions to PTX text
- Handles PTX directives (.version, .target, .address_size)
- Emits PTX assembly code

**Output example:**
```ptx
.version 7.0
.target sm_75
.address_size 64

.visible .entry mykernel(
    .param .u64 mykernel_param_0
)
{
    .reg .s32 %r<5>;
    .reg .u64 %rd<3>;

    ld.param.u64 %rd1, [mykernel_param_0];
    add.s32 %r1, %r2, %r3;
    st.global.s32 [%rd1], %r1;
    ret;
}
```

### 5. **NVPTXInstrInfo.td** - Instruction Definitions

**Location:** `/llvm/lib/Target/NVPTX/NVPTXInstrInfo.td`

**What it is:**
- TableGen file (domain-specific language)
- Defines all PTX instructions
- Specifies instruction patterns
- Used to auto-generate C++ code

**Example snippet:**
```tablegen
// Define a PTX add instruction
def ADDi32 : NVPTXInst<
  (outs Int32Regs:$dst),
  (ins Int32Regs:$a, Int32Regs:$b),
  "add.s32 \t$dst, $a, $b;",
  [(set Int32Regs:$dst, (add Int32Regs:$a, Int32Regs:$b))]
>;
```

This defines how LLVM's `add` operation maps to PTX's `add.s32` instruction.

### 6. **NVPTXIntrinsics.td** - CUDA Intrinsics

**Location:** `/llvm/lib/Target/NVPTX/NVPTXIntrinsics.td`

**Size:** 277KB (HUGE!)

**What it does:**
- Defines all CUDA/PTX intrinsic functions
- Maps CUDA built-ins to PTX instructions
- Examples:
  - `__syncthreads()` → `bar.sync`
  - `threadIdx.x` → `mov.u32 %r, %tid.x`
  - `atomicAdd()` → `atom.global.add`

### 7. **NVPTXRegisterInfo.td** - Register Definitions

**Location:** `/llvm/lib/Target/NVPTX/NVPTXRegisterInfo.td`

**What it does:**
- Defines PTX register classes
- PTX has unlimited virtual registers!
- Register types:
  - `.reg .s32` - 32-bit signed integer registers
  - `.reg .u64` - 64-bit unsigned integer registers
  - `.reg .f32` - 32-bit floating point
  - `.reg .f64` - 64-bit floating point
  - `.reg .pred` - Predicate registers (boolean)

## NVPTX-Specific Optimizations

The NVPTX backend includes many GPU-specific optimization passes:

### Memory Optimizations
1. **NVPTXAliasAnalysis.cpp** - GPU memory hierarchy analysis
   - Understands global, shared, local, constant memory
   - Improves alias analysis for GPU memory

2. **NVPTXTagInvariantLoads.cpp** - Mark invariant memory
   - Identifies read-only memory accesses
   - Enables GPU cache optimizations

### Function Handling
3. **NVPTXLowerArgs.cpp** - Optimize function parameters
   - Handles GPU-specific calling conventions
   - Optimizes parameter passing

4. **NVPTXAllocaHoisting.cpp** - Optimize local memory
   - Reduces local memory usage
   - Critical for GPU performance

### CUDA-Specific
5. **NVPTXImageOptimizer.cpp** - Texture/surface optimizations
   - Optimizes texture memory accesses
   - Handles image operations

6. **NVVMReflect.cpp** - NVVM reflection
   - Handles CUDA capability queries
   - Optimizes based on GPU architecture

## Example: Simple Addition

Let's trace how a simple addition goes through the NVPTX backend:

### Input LLVM IR:
```llvm
define i32 @add(i32 %a, i32 %b) {
  %result = add i32 %a, %b
  ret i32 %result
}
```

### Step 1: Instruction Selection (NVPTXISelLowering.cpp)
- LLVM `add i32` is recognized
- Lowered to target-specific add operation
- Calling convention analyzed

### Step 2: Instruction Pattern Matching (NVPTXISelDAGToDAG.cpp)
- Pattern matched to PTX `add.s32` instruction
- Registers allocated: `%r1`, `%r2`, `%r3`

### Step 3: PTX Generation (NVPTXAsmPrinter.cpp)
```ptx
.visible .func (.param .s32 func_retval0) add(
    .param .s32 add_param_0,
    .param .s32 add_param_1
)
{
    .reg .s32 %r<4>;

    ld.param.s32 %r1, [add_param_0];
    ld.param.s32 %r2, [add_param_1];
    add.s32 %r3, %r1, %r2;
    st.param.s32 [func_retval0], %r3;
    ret;
}
```

## How to Use the NVPTX Backend

### Compile to PTX:
```bash
# From C/C++ with clang
clang -O2 --cuda-gpu-arch=sm_75 -S -emit-llvm mykernel.cu -o mykernel.ll
llc -march=nvptx64 -mcpu=sm_75 mykernel.ll -o mykernel.ptx

# Or directly
clang -O2 --cuda-gpu-arch=sm_75 mykernel.cu -S -o mykernel.ptx

# For different GPU architectures
clang --cuda-gpu-arch=sm_80 mykernel.cu -o mykernel.ptx  # A100
clang --cuda-gpu-arch=sm_86 mykernel.cu -o mykernel.ptx  # RTX 3090
clang --cuda-gpu-arch=sm_90 mykernel.cu -o mykernel.ptx  # H100
```

### Specify NVPTX Target:
```bash
# 64-bit NVPTX
clang -target nvptx64-nvidia-cuda mycode.c -S -o mycode.ptx

# 32-bit NVPTX (rare)
clang -target nvptx-nvidia-cuda mycode.c -S -o mycode.ptx
```

## PTX Output Format

The NVPTX backend generates PTX (Parallel Thread Execution) assembly, which looks like:

```ptx
.version 7.5          // PTX ISA version
.target sm_75         // GPU compute capability
.address_size 64      // 64-bit addressing

// Global variables
.global .align 4 .u32 myGlobal;

// Kernel definition
.visible .entry myKernel(
    .param .u64 myKernel_param_0
)
{
    // Register declarations
    .reg .s32 %r<10>;
    .reg .u64 %rd<5>;
    .reg .f32 %f<3>;
    .reg .pred %p<2>;

    // Instructions
    ld.param.u64 %rd1, [myKernel_param_0];
    mov.u32 %r1, %tid.x;
    add.s32 %r2, %r1, 42;
    st.global.s32 [%rd1], %r2;
    ret;
}
```

## GPU Compute Capabilities

The NVPTX backend supports various NVIDIA GPU architectures:

| Architecture | Compute Capability | Example GPUs |
|--------------|-------------------|--------------|
| Maxwell | sm_50, sm_52, sm_53 | GTX 900 series |
| Pascal | sm_60, sm_61, sm_62 | GTX 1000 series, P100 |
| Volta | sm_70, sm_72 | V100, Titan V |
| Turing | sm_75 | RTX 2000 series, T4 |
| Ampere | sm_80, sm_86 | A100, RTX 3000 series |
| Hopper | sm_90 | H100 |

Specified via: `-mcpu=sm_XX` or `--cuda-gpu-arch=sm_XX`

## Summary

**The NVPTX backend transforms LLVM IR into NVIDIA GPU code through these key files:**

1. **NVPTXTargetMachine.cpp** - Entry point and pipeline configuration
2. **NVPTXISelLowering.cpp** - Core transformation (LLVM IR → GPU operations)
3. **NVPTXISelDAGToDAG.cpp** - Instruction pattern matching
4. **NVPTXAsmPrinter.cpp** - PTX text generation
5. **NVPTXInstrInfo.td** - Instruction definitions
6. **NVPTXIntrinsics.td** - CUDA intrinsics (threadIdx, atomics, etc.)

**The transformation happens in these stages:**
```
LLVM IR
  → NVPTX IR passes (lowering, optimization)
  → Instruction selection (ISelLowering)
  → Register allocation
  → PTX assembly generation (AsmPrinter)
  → PTX code
```

**Result:** Your high-level code runs on NVIDIA GPUs with thousands of parallel threads!

## Further Exploration

To understand how specific transformations work:

1. **Read:** `NVPTXISelLowering.cpp` - See how operations are lowered
2. **Study:** `NVPTXInstrInfo.td` - See instruction definitions
3. **Trace:** Use `llc -debug` to see transformation steps
4. **Compare:** Compile simple code and examine the PTX output

```bash
# See debug output
llc -march=nvptx64 -debug input.ll -o output.ptx 2>&1 | less
```

This backend is a perfect example of LLVM's power: write your frontend once, and automatically get GPU support!
