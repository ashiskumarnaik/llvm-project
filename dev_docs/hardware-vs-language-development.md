# Hardware Backend vs Language Frontend Development in LLVM

## The Key Distinction You Observed

You made an **excellent and important observation**:

> **Hardware developers** write code **inside the LLVM repository**
>
> **Language developers** create **separate repositories** and import LLVM as a library

This is **absolutely correct**! Let me explain why this asymmetry exists.

---

## Hardware Backend Development (Inside LLVM Repo)

### Where Hardware Code Lives

```
llvm-project/
└── llvm/lib/Target/
    ├── NEWHARDWARE/          ← New backend added HERE
    │   ├── NEWHARDWARETargetMachine.cpp
    │   ├── NEWHARDWAREISelLowering.cpp
    │   ├── NEWHARDWAREAsmPrinter.cpp
    │   └── ... (all backend code)
    ├── X86/
    ├── ARM/
    ├── RISCV/
    └── NVPTX/
```

### Why Backends Must Be Inside LLVM

**Reason 1: Tight Integration Required**
- Backends are **deeply integrated** with LLVM's code generation infrastructure
- They use internal LLVM APIs that change frequently
- They need access to LLVM's private headers and implementation details

**Reason 2: Shared Code Generation Framework**
- All backends share:
  - Register allocation algorithms
  - Instruction scheduling
  - Code optimization passes
  - Machine code layer (MC)
- These are **internal implementation details** of LLVM

**Reason 3: Target Registration System**
- LLVM maintains a **global target registry**
- All targets must be registered at LLVM build time
- The registry is compiled into the LLVM libraries

**Reason 4: Build System Integration**
- Backends are compiled together with LLVM core
- They're not designed to be dynamically loaded plugins
- TableGen (code generator) runs at LLVM build time

### Example: RISC-V Backend Development

The RISC-V backend was added **directly to the LLVM repository**:

```
Commit: Added to llvm-project/llvm/lib/Target/RISCV/
Author: RISC-V developers
Process:
1. Fork llvm-project repository
2. Add code to llvm/lib/Target/RISCV/
3. Submit patches to LLVM project
4. Code review by LLVM community
5. Merged into official LLVM repository
```

**Result:** Now every LLVM installation includes RISC-V support!

### How Hardware Vendors Add Backends

**Process:**
1. **Fork LLVM repository**
   ```bash
   git clone https://github.com/llvm/llvm-project.git
   cd llvm-project
   ```

2. **Create backend directory**
   ```bash
   mkdir llvm/lib/Target/MYHARDWARE
   ```

3. **Write backend code** (inside LLVM repo)
   ```
   llvm/lib/Target/MYHARDWARE/
   ├── CMakeLists.txt
   ├── MYHARDWARETargetMachine.cpp
   ├── MYHARDWAREISelLowering.cpp
   ├── MYHARDWAREInstrInfo.td
   └── ... (30-100+ files)
   ```

4. **Register the target** in LLVM's build system
   ```cmake
   # In llvm/lib/Target/CMakeLists.txt
   add_subdirectory(MYHARDWARE)
   ```

5. **Submit to LLVM project** via patches/pull requests

6. **Merged upstream** - becomes part of official LLVM

**Examples of companies that added backends to LLVM repo:**
- **NVIDIA** - NVPTX backend
- **AMD** - AMDGPU backend
- **SiFive/RISC-V Foundation** - RISCV backend
- **Qualcomm** - Hexagon backend
- **IBM** - PowerPC, SystemZ backends

---

## Language Frontend Development (Separate Repository)

### Where Language Code Lives

```
your-language-project/          ← Your own repository!
├── src/
│   ├── lexer.cpp              ← Your code
│   ├── parser.cpp             ← Your code
│   ├── ast.cpp                ← Your code
│   └── codegen.cpp            ← Uses LLVM APIs
├── CMakeLists.txt
└── dependencies/
    └── llvm/                  ← LLVM as a library (imported)
```

### Why Frontends Can Be Separate

**Reason 1: Clean Public API**
- LLVM provides **stable public C++ API** for IR generation
- Headers in `llvm/include/llvm/IR/` are designed for external use
- APIs like `IRBuilder`, `Module`, `Function` are public and stable

**Reason 2: Language Independence**
- Your language is independent from LLVM's internals
- You only use LLVM as a library (like using any other library)
- LLVM doesn't need to know about your language

**Reason 3: Distribution Model**
- Users can install your language compiler separately
- Your compiler links against installed LLVM libraries
- No need to modify LLVM source code

**Reason 4: Flexibility**
- You control your language's development pace
- You can update LLVM version independently
- You own your repository and release schedule

### Example: Rust Compiler (rustc)

**Repository:** `https://github.com/rust-lang/rust` (separate!)

**Structure:**
```
rust/                                  ← Rust's own repo
├── compiler/
│   ├── rustc_lexer/                  ← Rust code
│   ├── rustc_parse/                  ← Rust code
│   ├── rustc_ast/                    ← Rust code
│   ├── rustc_codegen_llvm/           ← Uses LLVM (imported)
│   │   └── src/
│   │       └── llvm_mod.rs           ← Calls LLVM APIs
└── build.rs                          ← Links to LLVM libs
```

**How Rust uses LLVM:**
```rust
// In rustc_codegen_llvm/src/llvm_mod.rs
use llvm_sys::*;  // LLVM C API bindings

// Generate LLVM IR
let context = LLVMContextCreate();
let module = LLVMModuleCreateWithName("my_module");
let builder = LLVMCreateBuilder();

// Build IR using LLVM APIs
let function_type = LLVMFunctionType(...);
let function = LLVMAddFunction(module, "my_func", function_type);
```

**Building Rust:**
```bash
# LLVM is a dependency (like any library)
./configure --llvm-root=/usr/local/llvm
make
```

### Example: Swift Compiler

**Repository:** `https://github.com/apple/swift` (separate!)

**Structure:**
```
swift/                                 ← Swift's own repo
├── lib/
│   ├── Parse/                        ← Swift code
│   ├── Sema/                         ← Swift code
│   ├── IRGen/                        ← Generates LLVM IR
│   │   └── IRGen.cpp                 ← Uses LLVM APIs
└── CMakeLists.txt                    ← Links to LLVM
```

**How Swift uses LLVM:**
```cpp
// In lib/IRGen/IRGen.cpp
#include "llvm/IR/Module.h"
#include "llvm/IR/IRBuilder.h"

// Create LLVM IR
llvm::LLVMContext Context;
llvm::Module *TheModule = new llvm::Module("SwiftModule", Context);
llvm::IRBuilder<> Builder(Context);

// Generate code
Builder.CreateAdd(LHS, RHS, "addtmp");
```

### How Language Developers Use LLVM

**Option 1: Link Against Installed LLVM**
```bash
# Install LLVM on your system
apt-get install llvm-dev  # Linux
brew install llvm         # macOS

# Build your compiler
cmake -DLLVM_DIR=/usr/lib/llvm-15 .
make
```

**Option 2: Include LLVM as Submodule**
```bash
# In your language repository
git submodule add https://github.com/llvm/llvm-project.git external/llvm
```

**Option 3: Download Pre-built LLVM**
```cmake
# In your CMakeLists.txt
find_package(LLVM REQUIRED CONFIG)
include_directories(${LLVM_INCLUDE_DIRS})
link_directories(${LLVM_LIBRARY_DIRS})
```

---

## Side-by-Side Comparison

### Hardware Backend Development (In LLVM Repo)

| Aspect | Details |
|--------|---------|
| **Repository** | `llvm-project` (LLVM's official repo) |
| **Location** | `llvm/lib/Target/YOURHARDWARE/` |
| **Integration** | Compiled into LLVM itself |
| **APIs Used** | Internal LLVM APIs (private headers) |
| **Build Process** | Built with LLVM core |
| **Distribution** | Included in every LLVM installation |
| **Updates** | Must follow LLVM release cycle |
| **Code Review** | By LLVM community |
| **Examples** | X86, ARM, RISCV, NVPTX (all in LLVM repo) |

### Language Frontend Development (Separate Repo)

| Aspect | Details |
|--------|---------|
| **Repository** | Your own repository |
| **Location** | Anywhere (e.g., `github.com/you/yourlang`) |
| **Integration** | Uses LLVM as external library |
| **APIs Used** | Public LLVM APIs (IRBuilder, Module, etc.) |
| **Build Process** | Your own build system |
| **Distribution** | Independent from LLVM |
| **Updates** | Your own release schedule |
| **Code Review** | Your own process |
| **Examples** | Rust, Swift, Julia (separate repos) |

---

## Why This Asymmetry Exists

### Backends Are Infrastructure

Backends are **part of LLVM's code generation infrastructure**:
- They implement the **last mile** of compilation
- They're tightly coupled to LLVM internals
- They must evolve with LLVM's internal APIs
- They benefit from being in one place (shared testing, CI/CD)

**Think of it like:**
> Backends are **device drivers** in an operating system - they're part of the kernel

### Frontends Are Applications

Frontends are **applications that use LLVM**:
- They use LLVM's **stable public interface**
- They're decoupled from LLVM internals
- They can version LLVM independently
- Each language has its own community/governance

**Think of it like:**
> Frontends are **applications** that use a graphics library - they're separate programs

---

## Real-World Examples

### Example 1: RISC-V Hardware Company

**Scenario:** SiFive develops a new RISC-V processor

**What they do:**
1. Fork LLVM repository
2. Work in `llvm/lib/Target/RISCV/`
3. Add new instructions/features
4. Submit patches to LLVM
5. After merge, available in next LLVM release

**Result:** Every language that uses LLVM (Rust, Swift, Clang, Julia) automatically supports RISC-V!

### Example 2: New Language Developer

**Scenario:** You create a new language called "FooLang"

**What you do:**
1. Create `github.com/yourname/foolang` (your own repo)
2. Write lexer, parser, semantic analysis
3. Use LLVM's IRBuilder to generate IR
4. Link against installed LLVM libraries
5. Distribute your compiler

**Result:** Your compiler can target X86, ARM, RISCV, NVPTX... all 27 backends!

---

## Special Cases

### Case 1: Clang (In LLVM Repo)

**Clang is in llvm-project/clang/** - Why?

- **Historical reasons:** Clang was developed by LLVM team
- **Close relationship:** Shares infrastructure with LLVM
- **Official frontend:** Considered part of LLVM project
- **But:** Uses same public APIs! Could theoretically be separate

### Case 2: Flang (In LLVM Repo)

**Flang is in llvm-project/flang/** - Why?

- **Donated to LLVM:** Originally separate, then moved to LLVM repo
- **Becomes official:** LLVM project adopts it as official Fortran frontend
- **Still uses public APIs:** Even though it's in the repo

### Case 3: Out-of-Tree Backends

**Some vendors maintain out-of-tree backends:**
- **Vendor-specific features** not ready for upstream
- **Proprietary hardware** not yet public
- **Experimental backends** under development

**How they do it:**
- Keep backend code in private repo
- Apply as patches to LLVM when building
- Eventually upstreamed if successful

**Example:** AMD initially had out-of-tree GPU backend, later upstreamed to AMDGPU

---

## The Contract Between Frontends and Backends

### What Frontends Provide
```
Your Language
    ↓
Frontend (your code)
    ↓
LLVM IR (platform-independent)
```

### What Backends Provide
```
LLVM IR (platform-independent)
    ↓
Backend (in LLVM repo)
    ↓
Machine Code (your hardware)
```

### The Interface: LLVM IR

**This is the magic:**
- **Frontends** produce LLVM IR (using public APIs)
- **Backends** consume LLVM IR (part of LLVM infrastructure)
- **They never need to know about each other!**

**Result:**
- M frontends × N backends = M×N combinations
- But only M+N components need to be written!

---

## Practical Implications

### If You're Building a New Language

**Your setup:**
```bash
my-language/
├── CMakeLists.txt
│   # Find LLVM
│   find_package(LLVM REQUIRED CONFIG)
│
│   # Link against LLVM
│   llvm_map_components_to_libnames(llvm_libs core support)
│   target_link_libraries(mylang ${llvm_libs})
│
└── src/
    └── codegen.cpp
        #include "llvm/IR/IRBuilder.h"  // Public API
        #include "llvm/IR/Module.h"      // Public API

        // Your code here - separate from LLVM!
```

**You do NOT need to:**
- ✗ Modify LLVM source code
- ✗ Fork LLVM repository
- ✗ Submit patches to LLVM
- ✗ Understand LLVM internals

**You only need to:**
- ✓ Link to LLVM libraries
- ✓ Use public LLVM APIs
- ✓ Generate valid LLVM IR

### If You're Building Hardware

**Your setup:**
```bash
# Fork LLVM
git clone https://github.com/llvm/llvm-project.git
cd llvm-project

# Add your backend
mkdir llvm/lib/Target/MYHW
# Write code IN the LLVM repository
vim llvm/lib/Target/MYHW/MYHWTargetMachine.cpp

# Submit to LLVM
git commit -m "Add MYHW target"
# Create pull request to llvm-project
```

**You MUST:**
- ✓ Work in LLVM repository
- ✓ Use internal LLVM APIs
- ✓ Follow LLVM coding standards
- ✓ Submit patches to LLVM project
- ✓ Pass LLVM code review
- ✓ Maintain compatibility with LLVM

---

## Why Can't Backends Be Separate?

**Technical reasons:**

1. **Internal APIs Change Frequently**
   - Backend APIs are not stable
   - They change with LLVM internals
   - External backends would break constantly

2. **Tight Coupling**
   - Backends use SelectionDAG, MachineInstr, etc.
   - These are LLVM implementation details
   - Not designed as public APIs

3. **Build-Time Code Generation**
   - TableGen runs during LLVM build
   - Generates C++ code from .td files
   - Must happen during LLVM compilation

4. **Target Registry**
   - Global singleton in LLVM
   - All targets registered at build time
   - Can't dynamically load backends

5. **Performance**
   - Backends are performance-critical
   - Need tight integration with optimization passes
   - Dynamic loading would add overhead

---

## Future: Could This Change?

**There have been discussions about:**
- Making backends loadable plugins
- Stabilizing backend APIs
- Allowing out-of-tree backends

**But challenges remain:**
- Massive engineering effort
- Backward compatibility concerns
- Performance implications
- TableGen integration

**Current consensus:** Backends stay in-tree for foreseeable future

---

## Summary

### The Key Insight

**You observed correctly:**

```
┌─────────────────────────────────────────────────────────┐
│ Hardware Backend Development                            │
│ ────────────────────────────                           │
│ • Code lives IN llvm-project repository                │
│ • Tightly integrated with LLVM internals               │
│ • Uses private/internal APIs                           │
│ • Submitted to and reviewed by LLVM project            │
│ • Becomes part of LLVM distribution                    │
│                                                         │
│ Example: RISC-V backend in llvm/lib/Target/RISCV/     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Language Frontend Development                           │
│ ───────────────────────────                            │
│ • Code lives in YOUR OWN repository                    │
│ • Uses LLVM as external library                        │
│ • Uses only public APIs (IRBuilder, etc.)              │
│ • Independent development and distribution             │
│ • Links against installed LLVM                         │
│                                                         │
│ Example: Rust at github.com/rust-lang/rust            │
└─────────────────────────────────────────────────────────┘
```

### Why This Makes Sense

**For Hardware:**
- Deep integration required
- Benefits from centralization
- One backend → all languages benefit
- Examples: RISC-V backend added → Rust/Swift/Clang/Julia all get RISC-V support!

**For Languages:**
- Independence and flexibility
- Own pace of development
- Clean separation of concerns
- Examples: Rust updates independently from LLVM

### The Magic

**Because of this design:**
- Add 1 backend → all languages get new hardware support
- Add 1 language → all hardware supported automatically
- M + N components → M × N capabilities!

This asymmetry is not a bug - **it's a brilliant design decision** that makes LLVM so powerful! 🎉
