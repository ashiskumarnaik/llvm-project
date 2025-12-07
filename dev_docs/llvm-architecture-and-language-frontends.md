# LLVM Architecture and Language Frontends

## Overview

This document explains how LLVM transforms the traditional compilation model and how different programming languages use LLVM as their compilation infrastructure.

## Traditional Compilation Model

In a traditional compiler (as taught in most compiler courses), the compilation process follows this pipeline:

```
C Source → Preprocessor → Pure C → Compiler → Assembly → Assembler → Machine Code → Linker → Executable
```

### Internal Compiler Stages

Inside the compiler, there are multiple phases:

```
High-level Language
    ↓
Lexical Analysis (Lexer)
    ↓
Tokens
    ↓
Syntax Analysis (Parser)
    ↓
Parse Tree / Abstract Syntax Tree (AST)
    ↓
Semantic Analysis
    ↓
Semantic Parse Tree
    ↓
Intermediate Code Generator
    ↓
Intermediate Code
    ↓
Code Optimization
    ↓
Optimized Code
    ↓
Target Code Generation
    ↓
Assembly Language
```

## LLVM's Architecture - The Key Innovation

LLVM introduces a **universal intermediate representation (LLVM IR)** that serves as a common language between language frontends and target backends. This is the crucial difference from traditional compilers.

### Three-Phase Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    LANGUAGE FRONTENDS                        │
│  (Different for each language - this is where they differ)  │
├──────────────┬──────────────┬──────────────┬────────────────┤
│    Clang     │    Flang     │   Swift      │  Rust/Julia... │
│  (C/C++/ObjC)│  (Fortran)   │              │                │
└──────┬───────┴──────┬───────┴──────┬───────┴────────┬───────┘
       │              │              │                │
       └──────────────┴──────────────┴────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │      LLVM IR           │ ◄── Common intermediate language
              │  (Platform-independent)│
              └────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │   LLVM Optimizer       │ ◄── Shared optimizations
              │   (Target-independent) │
              └────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │    LLVM Backend        │ ◄── Machine code generation
              │  (Target-specific)     │
              └────────────────────────┘
                           │
       ┌───────────────────┼───────────────────┐
       ▼                   ▼                   ▼
    x86/x64              ARM                 RISC-V...
```

### The Power of This Design

```
Traditional Compiler: M languages × N targets = M×N compilers needed
LLVM Architecture:    M frontends + N backends = M+N components needed
```

This design means:
- Write a frontend once, get all optimizations for free
- Write a frontend once, support all target architectures
- Write a backend once, all languages can use it
- New optimizations benefit all languages automatically

## How C (via Clang) Uses LLVM

Based on the LLVM project structure in `/clang/`, here's how C compilation works:

### Clang Frontend Pipeline

1. **Preprocessor**
   - Handles `#include`, `#define`, `#ifdef`, etc.
   - Expands macros
   - Produces pure C/C++ code

2. **Lexical Analysis (Lexer)**
   - Breaks source into tokens
   - Tokens: keywords, identifiers, operators, literals

3. **Syntax Analysis (Parser)**
   - Creates Abstract Syntax Tree (AST)
   - Represents program structure
   - Handles C/C++ grammar rules

4. **Semantic Analysis**
   - Type checking
   - Name resolution
   - Symbol table management
   - Validates program correctness

5. **Code Generation (CodeGen)**
   - **Converts AST to LLVM IR** ← Key transformation!
   - This is where Clang hands off to LLVM

### LLVM Core Pipeline

6. **Optimization Passes** (in `/llvm/lib/Transforms/`)
   - Works entirely on LLVM IR
   - Examples:
     - Dead code elimination
     - Loop optimizations
     - Inlining
     - Constant propagation
     - Strength reduction
     - And hundreds more...

7. **Code Generation** (in `/llvm/lib/Target/`)
   - LLVM IR → Assembly/Machine code
   - Target-specific optimizations
   - Instruction selection
   - Register allocation
   - Instruction scheduling

## LLVM IR - The Universal Intermediate Representation

LLVM IR is:
- **Platform-independent**: No assumptions about target architecture
- **Typed**: Every value has a type (i32, float, ptr, etc.)
- **SSA-based**: Static Single Assignment form
- **Three forms**: In-memory, bitcode (.bc), human-readable (.ll)

### Example: C Code to LLVM IR

**C Source** (`example.c`):
```c
int add(int a, int b) {
    return a + b;
}

int main() {
    int result = add(5, 3);
    return result;
}
```

**Generated LLVM IR** (`example.ll`):
```llvm
; Function definition
define i32 @add(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 %0, ptr %3, align 4
  store i32 %1, ptr %4, align 4
  %5 = load i32, ptr %3, align 4
  %6 = load i32, ptr %4, align 4
  %7 = add nsw i32 %5, %6
  ret i32 %7
}

define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  %3 = call i32 @add(i32 noundef 5, i32 noundef 3)
  store i32 %3, ptr %2, align 4
  %4 = load i32, ptr %2, align 4
  ret i32 %4
}
```

**Key LLVM IR Features:**
- `i32` = 32-bit integer type (platform-independent!)
- `@add`, `@main` = global symbols (functions)
- `%0, %1, %2...` = local virtual registers (SSA form)
- `alloca` = allocate stack memory
- `store` = write to memory
- `load` = read from memory
- `add nsw` = add with no signed wrap
- `ret` = return from function

## How Different Languages Use LLVM

### Similarities Across All LLVM Languages

All languages that use LLVM share these characteristics:

1. **All Produce LLVM IR**
   - This is the crucial commonality
   - Different syntax, same intermediate representation
   - Enables interoperability between languages

2. **Same Optimization Infrastructure**
   - All languages benefit from LLVM's optimization passes
   - Over 200+ optimization passes available
   - Examples:
     - Scalar optimizations (constant folding, DCE, etc.)
     - Loop optimizations (unrolling, vectorization, etc.)
     - Interprocedural optimizations (inlining, IPO, etc.)
     - Link-time optimization (LTO)

3. **Same Backend Code Generation**
   - All compile to the same machine code formats
   - Support for multiple architectures: x86, ARM, RISC-V, PowerPC, etc.
   - Architecture-specific optimizations applied uniformly

4. **Same Tooling Ecosystem**
   - `opt` - LLVM optimizer
   - `llc` - LLVM compiler (IR to assembly)
   - `lli` - LLVM interpreter/JIT
   - `llvm-dis` - Bitcode disassembler
   - `llvm-as` - LLVM assembler
   - `lld` - LLVM linker

5. **Same Debug Information Format**
   - DWARF debugging information
   - Cross-language debugging support

6. **Cross-Language Interoperability**
   - Functions from different languages can call each other
   - Shared ABI (Application Binary Interface)
   - Example: C++ calling Rust, Swift calling C

### Differences - Language-Specific Frontends

Each language has a **different frontend** that handles language-specific features before producing LLVM IR:

#### 1. Clang (C/C++/Objective-C) - `/clang/`

**Language Features:**
- C preprocessor (`#include`, `#define`, `#ifdef`)
- Pointers and manual memory management
- C++ templates, classes, inheritance
- Objective-C message passing

**Frontend Characteristics:**
- Must maintain GCC compatibility
- Complex C++ template instantiation
- Name mangling for C++
- Handles inline assembly

**IR Generation:**
```
C/C++ Source → Preprocessor → Lexer → Parser → AST → Semantic Analysis → LLVM IR
```

#### 2. Flang (Fortran) - `/flang/`

**Language Features:**
- Array operations and slicing
- DO loops and implicit loops
- COMMON blocks and EQUIVALENCE
- Column-major array layout
- Fortran-specific intrinsics

**Frontend Characteristics:**
- Fortran-specific grammar and semantics
- Different array memory layout than C
- Uses FIR (Fortran IR) as an intermediate step

**IR Generation:**
```
Fortran Source → Lexer → Parser → AST → FIR (Fortran IR) → LLVM IR
```

#### 3. Swift (External Project - Apple)

**Language Features:**
- Automatic reference counting (ARC)
- Protocol-oriented programming
- Optionals and pattern matching
- Value types and copy-on-write

**Frontend Characteristics:**
- Swift-specific type system
- Generates Swift Intermediate Language (SIL) first
- Handles ARC memory management

**IR Generation:**
```
Swift Source → Parser → AST → SIL (Swift IR) → LLVM IR
```

#### 4. Rust (External Project - Mozilla/Rust Foundation)

**Language Features:**
- Ownership and borrowing system
- Lifetimes
- Zero-cost abstractions
- Pattern matching

**Frontend Characteristics:**
- Borrow checker (ensures memory safety at compile time)
- Multiple IR layers
- Uses LLVM through `rustc_codegen_llvm`

**IR Generation:**
```
Rust Source → Parser → HIR (High-level IR) → MIR (Mid-level IR) → LLVM IR
```

#### 5. Julia (External Project)

**Language Features:**
- Dynamic typing with type inference
- Multiple dispatch
- Just-in-time (JIT) compilation
- Interactive REPL

**Frontend Characteristics:**
- Dynamic language that compiles to LLVM IR at runtime
- Type specialization through JIT
- Can generate specialized code for different type combinations

**IR Generation:**
```
Julia Source → Parser → AST → Julia IR → LLVM IR → JIT Compilation
```

### Comparison Table

| Language | Frontend Location | Preprocessor | Memory Model | Type System | Additional IR Layers | Key Challenge |
|----------|------------------|--------------|--------------|-------------|---------------------|---------------|
| **C/C++** | `/clang/` | Yes (`#define`, `#include`) | Manual (pointers) | Static | None (AST → LLVM IR) | Templates, compatibility |
| **Fortran** | `/flang/` | No | Manual (arrays) | Static | FIR | Array operations |
| **Swift** | External | No | ARC | Static + Protocol-oriented | SIL | Reference counting |
| **Rust** | External | No | Ownership/Borrowing | Static + Lifetime | HIR, MIR | Borrow checker |
| **Julia** | External | No | GC | Dynamic + Inference | Julia IR | JIT compilation |

## Detailed Language Comparison

### Frontend Stages - What's Different

#### Lexical Analysis
- **C/C++**: Must handle preprocessor tokens, trigraphs
- **Fortran**: Fixed-form vs free-form source, different comment styles
- **Swift/Rust**: Simpler, no preprocessor
- **Julia**: REPL-aware tokenization

#### Parsing
- **C/C++**: Complex grammar, especially C++ with templates
- **Fortran**: Column-based syntax (in fixed-form), array syntax
- **Swift**: Protocol-oriented syntax
- **Rust**: Pattern matching, lifetime annotations
- **Julia**: Multiple dispatch syntax

#### Semantic Analysis
- **C/C++**: Type checking, template instantiation, overload resolution
- **Fortran**: Array shape checking, implicit typing rules
- **Swift**: Protocol conformance, ARC insertion
- **Rust**: **Borrow checking** (unique to Rust!), lifetime analysis
- **Julia**: Type inference, multiple dispatch resolution

#### Code Generation (to LLVM IR)
- **C/C++**: Direct mapping, struct layout, vtables for virtual functions
- **Fortran**: Array descriptor generation, different calling conventions
- **Swift**: ARC retain/release calls, witness tables
- **Rust**: Drop glue insertion, move semantics
- **Julia**: Boxing/unboxing for dynamic types

### Backend Stages - What's the Same

Once LLVM IR is generated, **everything is the same**:

1. **Optimization Passes** - Identical for all languages
   - Each pass operates on LLVM IR
   - Language-agnostic transformations
   - Example: Loop unrolling works the same for C loops, Fortran DO loops, and Rust for loops

2. **Code Generation** - Target architecture determines output
   - Register allocation
   - Instruction selection
   - Instruction scheduling
   - All languages get the same quality assembly

3. **Linking** - Can use LLD for all languages
   - Link objects from different languages
   - Link-Time Optimization (LTO) works across languages

## Why This Matters

### For Compiler Developers
- Write a frontend once, get optimizations and targets for free
- Focus on language-specific features
- Don't need to implement backend for every architecture

### For Language Users
- All LLVM-based languages have similar performance characteristics
- Can mix languages in one project
- Same debugging and profiling tools

### For Tool Developers
- Write tools that work on LLVM IR
- Tools work for all LLVM languages
- Example: LLVM sanitizers (ASan, MSan, TSan) work for C, C++, Rust, Swift, etc.

## How to Generate LLVM IR

### From C/C++ (using Clang)
```bash
# Generate LLVM IR in human-readable form
clang -S -emit-llvm source.c -o output.ll

# Generate LLVM bitcode (binary form)
clang -c -emit-llvm source.c -o output.bc

# With optimizations
clang -O2 -S -emit-llvm source.c -o output.ll
```

### From Fortran (using Flang)
```bash
# Generate LLVM IR
flang-new -S -emit-llvm source.f90 -o output.ll
```

### Optimizing LLVM IR
```bash
# Run optimization passes
opt -O2 input.ll -S -o optimized.ll

# Run specific passes
opt -mem2reg -instcombine input.ll -S -o optimized.ll
```

### Compiling LLVM IR to Assembly
```bash
# Generate assembly for target architecture
llc output.ll -o output.s

# Generate object file
llc -filetype=obj output.ll -o output.o
```

## LLVM Project Structure

```
llvm-project/
├── clang/           # C/C++/Objective-C frontend
├── flang/           # Fortran frontend
├── llvm/            # LLVM core libraries
│   ├── lib/
│   │   ├── IR/                  # LLVM IR implementation
│   │   ├── Transforms/          # Optimization passes
│   │   ├── CodeGen/             # Code generation framework
│   │   ├── Target/              # Target-specific backends
│   │   │   ├── X86/            # x86/x64 backend
│   │   │   ├── ARM/            # ARM backend
│   │   │   ├── AArch64/        # ARM64 backend
│   │   │   └── RISCV/          # RISC-V backend
│   │   └── Analysis/           # Analysis passes
│   └── include/llvm/           # LLVM headers
├── lld/             # LLVM linker
├── lldb/            # LLVM debugger
├── compiler-rt/     # Runtime libraries (sanitizers, etc.)
├── libc++/          # C++ standard library
└── mlir/            # Multi-Level IR (for domain-specific languages)
```

## Traditional vs LLVM Model

### Traditional Compiler Model

```
Source Code
    ↓
Frontend (Language-specific)
    ↓
Intermediate Representation (Compiler-specific)
    ↓
Optimizer (Compiler-specific)
    ↓
Backend (Target-specific)
    ↓
Assembly/Machine Code
```

**Problems:**
- Each compiler has its own IR
- Optimizations not reusable across compilers
- Adding new language requires full compiler
- Adding new target requires new backend for each compiler

### LLVM Model

```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│  Language 1 │  │  Language 2 │  │  Language 3 │
│   Frontend  │  │   Frontend  │  │   Frontend  │
└──────┬──────┘  └──────┬──────┘  └──────┬──────┘
       │                │                │
       └────────────────┼────────────────┘
                        ↓
              ┌──────────────────┐
              │    LLVM IR       │ ← Universal
              └──────────────────┘
                        ↓
              ┌──────────────────┐
              │   Optimizer      │ ← Shared
              └──────────────────┘
                        ↓
       ┌────────────────┼────────────────┐
       ↓                ↓                ↓
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│  Backend 1  │  │  Backend 2  │  │  Backend 3  │
│   (x86)     │  │   (ARM)     │  │  (RISC-V)   │
└─────────────┘  └─────────────┘  └─────────────┘
```

**Advantages:**
- Single IR for all languages
- Optimizations written once, benefit all languages
- New language: write frontend only
- New target: write backend only
- M + N components instead of M × N

## Key Takeaways

1. **LLVM IR is the universal language** that all frontends target and all backends consume

2. **Frontend differences** are where languages diverge:
   - Syntax and parsing
   - Type systems
   - Language-specific features
   - Memory management models

3. **Backend similarities** are where languages converge:
   - All use the same optimizer
   - All use the same code generator
   - All get the same performance

4. **The traditional compilation model still applies**, but LLVM splits it:
   ```
   Traditional: Source → Compiler → Assembly
   LLVM:       Source → Frontend → LLVM IR → Backend → Assembly
                        (Differs)   (Common)  (Common)
   ```

5. **This design enables**:
   - Code reuse (optimizations, code generation)
   - Rapid language development (just write a frontend)
   - Cross-language interoperability
   - Consistent tooling across languages

## Further Reading

- LLVM Language Reference: `/llvm/docs/LangRef.rst`
- Clang Documentation: `/clang/docs/`
- Flang Documentation: `/flang/docs/`
- LLVM Programmer's Manual: https://llvm.org/docs/ProgrammersManual.html
- LLVM Tutorial: `/llvm/docs/tutorial/`

## Example Files

- C source: `dev_docs/example.c`
- Generated LLVM IR: `dev_docs/example.ll`
- Fortran source: `dev_docs/example.f90`
