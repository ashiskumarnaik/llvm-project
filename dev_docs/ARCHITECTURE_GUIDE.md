# LLVM Codebase Architecture Guide

A guide to understanding the internal structure and architecture of the LLVM project.

## Table of Contents

1. [High-Level Architecture](#high-level-architecture)
2. [LLVM Core Components](#llvm-core-components)
3. [Clang Architecture](#clang-architecture)
4. [Code Organization](#code-organization)
5. [Key Subsystems](#key-subsystems)
6. [Data Structures and Utilities](#data-structures-and-utilities)
7. [Pass Infrastructure](#pass-infrastructure)
8. [Target Architecture](#target-architecture)

---

## High-Level Architecture

LLVM follows a modular, library-based design. The compilation pipeline typically flows:

```
Source Code
    ↓
[Frontend] (Clang, Flang, etc.)
    ↓
LLVM IR
    ↓
[Optimization Passes]
    ↓
Optimized LLVM IR
    ↓
[Backend/CodeGen]
    ↓
Machine Code
```

### Core Philosophy

- **Library-based design**: Everything is a library that can be reused
- **Three-phase design**: Frontend → Optimizer → Backend
- **Language-agnostic IR**: LLVM IR is independent of source language
- **Target-independent optimization**: Most optimizations work on IR
- **Retargetable**: Easy to add new target architectures

---

## LLVM Core Components

### 1. IR (Intermediate Representation)

**Location**: `llvm/lib/IR/`, `llvm/include/llvm/IR/`

The heart of LLVM. All frontends produce LLVM IR, and all backends consume it.

**Key Classes**:
- `Module`: Top-level container (like a translation unit)
- `Function`: Contains basic blocks
- `BasicBlock`: Contains instructions
- `Instruction`: Individual IR instruction
- `Value`: Base class for anything that produces a value
- `Type`: Represents types in the type system

**Hierarchy**:
```
Module
├── Global Variables
└── Functions
    └── Basic Blocks
        └── Instructions (Values)
```

### 2. Analysis Infrastructure

**Location**: `llvm/lib/Analysis/`, `llvm/include/llvm/Analysis/`

Provides information about the program without modifying it.

**Common Analyses**:
- `DominatorTree`: Dominator information for basic blocks
- `LoopInfo`: Loop structure analysis
- `ScalarEvolution`: Scalar variable evolution in loops
- `AliasAnalysis`: Memory aliasing information
- `CallGraph`: Function call relationships
- `MemorySSA`: Memory dependency analysis

### 3. Transformation Passes

**Location**: `llvm/lib/Transforms/`, `llvm/include/llvm/Transforms/`

Optimize or modify IR.

**Categories**:
- `IPO/`: Inter-procedural optimizations (inlining, dead globals)
- `Scalar/`: Scalar optimizations (DCE, LICM, GVN)
- `InstCombine/`: Instruction combining and simplification
- `Vectorize/`: Auto-vectorization (SLP, Loop vectorizer)
- `Utils/`: Utilities used by other transforms

### 4. Code Generation (Backend)

**Location**: `llvm/lib/CodeGen/`, `llvm/include/llvm/CodeGen/`

Converts LLVM IR to machine code.

**Pipeline**:
1. **Instruction Selection**: IR → SelectionDAG → MachineInstr
2. **Scheduling**: Order instructions optimally
3. **Register Allocation**: Assign virtual registers to physical registers
4. **Code Emission**: Generate final machine code

**Key Concepts**:
- `MachineFunction`: Machine-level representation of a function
- `MachineBasicBlock`: Machine-level basic block
- `MachineInstr`: Machine instruction
- `TargetInstrInfo`: Target-specific instruction information

### 5. Target Descriptions

**Location**: `llvm/lib/Target/`, `llvm/include/llvm/Target/`

Each architecture has its own subdirectory (e.g., `X86/`, `ARM/`, `AArch64/`).

**TableGen Files** (`.td`):
- Define registers, instructions, patterns
- Generate C++ code for instruction selection, etc.

**Key Files per Target**:
- `{Target}InstrInfo.td`: Instruction definitions
- `{Target}RegisterInfo.td`: Register definitions
- `{Target}ISelLowering.cpp`: Lowering IR to SelectionDAG
- `{Target}AsmPrinter.cpp`: Emit assembly/object code

### 6. Support Libraries

**Location**: `llvm/lib/Support/`, `llvm/include/llvm/Support/`

Common utilities used throughout LLVM:
- `CommandLine.h`: Command-line option parsing
- `raw_ostream.h`: Output streams
- `ErrorHandling.h`: Error handling utilities
- `MemoryBuffer.h`: File reading
- File system utilities, threading, etc.

### 7. ADT (Abstract Data Types)

**Location**: `llvm/include/llvm/ADT/`

High-performance data structures:
- `StringRef`: Non-owning string reference
- `SmallVector<T, N>`: Vector optimized for small sizes
- `DenseMap<K, V>`: Hash map
- `SmallPtrSet<T, N>`: Set of pointers
- `APInt`, `APFloat`: Arbitrary-precision integers/floats
- `ArrayRef<T>`: Non-owning array reference
- `Optional<T>`: May or may not contain a value

---

## Clang Architecture

**Location**: `clang/lib/`, `clang/include/clang/`

Clang is the C/C++/Objective-C frontend for LLVM.

### Compilation Pipeline

```
Source File
    ↓
[Lexer] → Tokens
    ↓
[Preprocessor] → Expanded Tokens
    ↓
[Parser] → AST (Abstract Syntax Tree)
    ↓
[Sema] → Checked AST
    ↓
[CodeGen] → LLVM IR
```

### Major Components

#### 1. Lexer & Preprocessor
**Location**: `clang/lib/Lex/`

- Tokenizes source code
- Handles macros, includes, conditional compilation
- Produces tokens for the parser

**Key Classes**:
- `Lexer`: Converts text to tokens
- `Preprocessor`: Expands macros, handles directives
- `Token`: Represents a lexical token

#### 2. Parser
**Location**: `clang/lib/Parse/`

- Recursive descent parser
- Builds Abstract Syntax Tree (AST)
- Syntax analysis only (no type checking yet)

**Key Classes**:
- `Parser`: Main parser class
- Various `Parse*()` methods for different constructs

#### 3. AST (Abstract Syntax Tree)
**Location**: `clang/lib/AST/`, `clang/include/clang/AST/`

Represents the structure of C/C++ code.

**Key Classes**:
- `Decl`: Declarations (functions, variables, classes)
  - `FunctionDecl`, `VarDecl`, `CXXRecordDecl`
- `Stmt`: Statements and expressions
  - `IfStmt`, `ForStmt`, `CallExpr`, `BinaryOperator`
- `Type`: Type system
  - `BuiltinType`, `PointerType`, `FunctionType`
- `ASTContext`: Owns all AST nodes

**Hierarchy Example**:
```
TranslationUnitDecl
└── FunctionDecl: int add(int, int)
    └── CompoundStmt
        ├── DeclStmt: int result
        ├── BinaryOperator: =
        │   ├── DeclRefExpr: result
        │   └── BinaryOperator: +
        │       ├── DeclRefExpr: param1
        │       └── DeclRefExpr: param2
        └── ReturnStmt
            └── DeclRefExpr: result
```

#### 4. Sema (Semantic Analysis)
**Location**: `clang/lib/Sema/`

- Type checking
- Name lookup
- Template instantiation
- Overload resolution
- Builds semantic information into AST

**Key Classes**:
- `Sema`: Main semantic analysis class
- Hundreds of methods for checking different constructs

#### 5. CodeGen
**Location**: `clang/lib/CodeGen/`

- Converts AST to LLVM IR
- Handles C++ features (vtables, RTTI, exceptions)
- Platform-specific ABI details

**Key Classes**:
- `CodeGenModule`: Module-level code generation
- `CodeGenFunction`: Function-level code generation
- `CGExprScalar`, `CGExprComplex`: Expression code generation

#### 6. Clang Tools
**Location**: `clang-tools-extra/`

Tools built on Clang libraries:
- **clang-tidy**: Linter and static analyzer
- **clang-format**: Code formatter
- **clangd**: Language server for IDEs
- **clang-query**: AST query tool

---

## Code Organization

### Header File Organization

```
include/llvm/
├── IR/              # LLVM IR classes
│   ├── Module.h
│   ├── Function.h
│   ├── BasicBlock.h
│   └── Instructions.h
├── Analysis/        # Analysis passes
├── Transforms/      # Transformation passes
├── CodeGen/         # Code generation
├── Target/          # Target-independent interfaces
├── Support/         # Utility classes
├── ADT/             # Data structures
└── Pass*.h          # Pass infrastructure

lib/llvm/
├── IR/              # Implementation of IR
├── Analysis/        # Implementation of analyses
├── Transforms/      # Implementation of transforms
├── CodeGen/         # Implementation of codegen
└── Target/          # Target-specific code
    ├── X86/
    ├── ARM/
    └── ...
```

### Include Path Convention

```cpp
// Public API (for users of LLVM)
#include "llvm/IR/Function.h"

// Internal implementation (within LLVM)
#include "llvm/IR/IRBuilder.h"

// Within same library
#include "LocalFile.h"
```

---

## Key Subsystems

### 1. Pass Manager

**New Pass Manager (NPM)**:
- Modern, cleaner design
- Used by default in LLVM
- Located in: `llvm/include/llvm/Passes/`

**Pass Types**:
- `ModulePass`: Operates on entire module
- `FunctionPass`: Operates on functions (via `FunctionAnalysisManager`)
- `LoopPass`: Operates on loops
- Custom analysis passes

**Example**:
```cpp
class MyPass : public PassInfoMixin<MyPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &AM);
};
```

### 2. Target Machine

Each target implements `TargetMachine`:
- Provides target-specific information
- Creates passes for code generation pipeline
- Examples: `X86TargetMachine`, `ARMTargetMachine`

### 3. Debug Information

**Location**: `llvm/lib/IR/DebugInfo*.cpp`

- Generates DWARF debug information
- Preserves source-level info through optimization
- `DIBuilder`: API for creating debug info

### 4. Linker (LLD)

**Location**: `lld/`

Fast linker:
- `lld/ELF/`: ELF format (Linux)
- `lld/COFF/`: PE/COFF format (Windows)
- `lld/MachO/`: Mach-O format (macOS)
- `lld/wasm/`: WebAssembly

### 5. Sanitizers

**Location**: `compiler-rt/lib/`

Runtime libraries for bug detection:
- `asan/`: AddressSanitizer (memory errors)
- `msan/`: MemorySanitizer (uninitialized reads)
- `tsan/`: ThreadSanitizer (data races)
- `ubsan/`: UndefinedBehaviorSanitizer

---

## Data Structures and Utilities

### LLVM ADT Best Practices

**StringRef**: Use for string parameters (no copying)
```cpp
void processName(StringRef Name) {
  // Name references existing string, no copy
}
```

**SmallVector**: Use when size is usually small
```cpp
SmallVector<Value*, 8> Args;  // No heap allocation if <= 8 elements
```

**ArrayRef/MutableArrayRef**: Use for passing arrays
```cpp
void process(ArrayRef<int> Values) {
  // Non-owning reference to array
}
```

**DenseMap**: Use for pointer keys or integer keys
```cpp
DenseMap<Value*, unsigned> ValueMap;
```

**Expected/Error**: Use for error handling
```cpp
Expected<int> getResult() {
  if (failed)
    return createStringError("Failed");
  return 42;
}
```

---

## Pass Infrastructure

### Writing a Transformation Pass

```cpp
#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"

class MyTransformPass : public PassInfoMixin<MyTransformPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &AM) {
    bool Changed = false;

    for (BasicBlock &BB : F) {
      for (Instruction &I : BB) {
        // Your transformation logic
        if (/* modified I */) {
          Changed = true;
        }
      }
    }

    return Changed ? PreservedAnalyses::none() : PreservedAnalyses::all();
  }
};

// Register the pass
llvm::PassPluginLibraryInfo getMyTransformPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "MyTransformPass", "v0.1",
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
              [](StringRef Name, FunctionPassManager &FPM, ...) {
                if (Name == "my-transform") {
                  FPM.addPass(MyTransformPass());
                  return true;
                }
                return false;
              });
          }};
}
```

### Writing an Analysis Pass

```cpp
class MyAnalysis : public AnalysisInfoMixin<MyAnalysis> {
public:
  using Result = MyAnalysisResult;  // Your result type

  Result run(Function &F, FunctionAnalysisManager &AM) {
    // Compute analysis result
    Result R;
    // ... populate R ...
    return R;
  }

private:
  static AnalysisKey Key;
  friend AnalysisInfoMixin<MyAnalysis>;
};

// Using the analysis in a pass
auto &Result = AM.getResult<MyAnalysis>(F);
```

---

## Target Architecture

### Adding a New Target Backend

Each target needs:

1. **TableGen Definitions** (`.td` files):
   - Register classes
   - Instruction formats
   - Scheduling models
   - Calling conventions

2. **C++ Implementation**:
   - `TargetMachine` subclass
   - `TargetLowering` for IR → SelectionDAG
   - `InstrInfo`, `RegisterInfo`, `FrameLowering`
   - Assembly printer
   - Assembly parser (for assembler)
   - Disassembler

**Minimal Target Structure**:
```
lib/Target/MyTarget/
├── MyTarget.td              # Main TableGen file
├── MyTargetInstrInfo.td     # Instruction definitions
├── MyTargetRegisterInfo.td  # Register definitions
├── MyTargetTargetMachine.h/cpp
├── MyTargetISelLowering.h/cpp
├── MyTargetInstrInfo.h/cpp
├── MyTargetRegisterInfo.h/cpp
└── MyTargetFrameLowering.h/cpp
```

---

## Common Patterns and Idioms

### Iteration Patterns

```cpp
// Iterate over function's basic blocks
for (BasicBlock &BB : F) { ... }

// Iterate over basic block's instructions
for (Instruction &I : BB) { ... }

// Iterate over instruction's operands
for (Use &U : I.operands()) {
  Value *V = U.get();
}

// Safe iteration with modification
for (BasicBlock &BB : make_early_inc_range(F)) {
  // Can delete BB here
}
```

### Casting

```cpp
// Checked cast (returns nullptr if fails)
if (auto *CI = dyn_cast<CallInst>(&I)) {
  // I is a CallInst
}

// Unchecked cast (asserts if wrong type)
CallInst *CI = cast<CallInst>(&I);

// Check type
if (isa<ReturnInst>(&I)) { ... }
```

### Creating Instructions

```cpp
IRBuilder<> Builder(/* insert point */);

// Create instructions
Value *Sum = Builder.CreateAdd(LHS, RHS);
Value *Ptr = Builder.CreateGEP(Ty, BasePtr, Indices);
Value *Loaded = Builder.CreateLoad(Ty, Ptr);
Builder.CreateStore(Val, Ptr);
Builder.CreateRet(RetVal);
```

---

## Further Reading

- **LLVM Programmer's Manual**: https://llvm.org/docs/ProgrammersManual.html
- **Writing an LLVM Pass**: https://llvm.org/docs/WritingAnLLVMPass.html
- **LLVM Language Reference**: https://llvm.org/docs/LangRef.html
- **TableGen**: https://llvm.org/docs/TableGen/
- **Code Generator**: https://llvm.org/docs/CodeGenerator.html

---

## Tips for Navigating the Codebase

1. **Start with examples**: Look at `llvm/examples/` and existing passes
2. **Use git grep**: Find usage examples of APIs
3. **Read unit tests**: Tests show how APIs are used
4. **Follow includes**: Start from a high-level class and follow includes
5. **Use IDE navigation**: Jump to definitions, find usages
6. **Read commit messages**: Git history explains why code exists
7. **Check documentation**: Many classes have good Doxygen comments

---

This guide provides a roadmap to understanding LLVM's architecture. The codebase is large, so focus on the components relevant to your work and expand from there.
