# LLVM Frontend Development Guide

## What Language Developers Use to Generate LLVM IR

This document explains exactly what parts of LLVM language developers use to create frontends that generate LLVM IR, and what happens after IR generation.

## Your Question Answered

**Q: What specific parts of LLVM do language developers use to generate LLVM IR?**

**A:** Language developers use the **LLVM C++ API** located in `/llvm/include/llvm/IR/`. The most important classes are:

1. **`LLVMContext`** - Context that owns core LLVM data structures
2. **`Module`** - Top-level container for all IR (functions, globals)
3. **`IRBuilder<>`** - Helper for creating LLVM instructions
4. **`Function`** - Represents a function
5. **`BasicBlock`** - Represents a basic block of instructions
6. **`Type`** - Type system (IntegerType, FunctionType, etc.)
7. **`Value`** - Base class for all values (SSA values)

**Q: After generating LLVM IR, do language developers need to do anything else?**

**A:** **No!** Once you've generated valid LLVM IR:
- You just use LLVM's existing tools
- The optimizer, code generator, and linker are all provided by LLVM
- You don't write any backend code
- Everything downstream is handled by LLVM

## The Key LLVM APIs for Frontend Developers

### Location in the Codebase

All the APIs you need are in: **`/llvm/include/llvm/IR/`**

```
/llvm/include/llvm/IR/
├── LLVMContext.h       # Context object
├── Module.h            # Module container
├── IRBuilder.h         # IR construction helper (MOST IMPORTANT!)
├── Function.h          # Function representation
├── BasicBlock.h        # Basic block
├── Type.h              # Type system
├── DerivedTypes.h      # Complex types (arrays, structs, pointers)
├── Constants.h         # Constant values
├── Instructions.h      # Instruction classes
├── Value.h             # SSA value base class
└── Verifier.h          # IR validation
```

### The Core Classes

#### 1. **LLVMContext** - The Container

```cpp
#include "llvm/IR/LLVMContext.h"

std::unique_ptr<LLVMContext> TheContext = std::make_unique<LLVMContext>();
```

**What it does:**
- Owns type and constant value tables
- Thread-local context for LLVM operations
- You typically create ONE context per compilation unit

**From tutorial** (`llvm/docs/tutorial/MyFirstLanguageFrontend/LangImpl03.rst:86-89`):
> "TheContext is an opaque object that owns a lot of core LLVM data structures,
> such as the type and constant value tables. We don't need to understand it in
> detail, we just need a single instance to pass into APIs that require it."

#### 2. **Module** - The Top-Level Container

```cpp
#include "llvm/IR/Module.h"

std::unique_ptr<Module> TheModule =
    std::make_unique<Module>("my_module", *TheContext);
```

**What it does:**
- Contains all functions and global variables
- Represents a single compilation unit
- Owns the memory for all IR you generate

**From Module.h** (`llvm/include/llvm/IR/Module.h:56-66`):
> "A Module instance is used to store all the information related to an LLVM
> module. Modules are the top level container of all other LLVM Intermediate
> Representation (IR) objects. Each module directly contains a list of globals
> variables, a list of functions, a list of libraries (or other modules) this
> module depends on, a symbol table, and various data about the target's
> characteristics."

#### 3. **IRBuilder<>** - The IR Construction Helper (MOST IMPORTANT!)

```cpp
#include "llvm/IR/IRBuilder.h"

std::unique_ptr<IRBuilder<>> Builder =
    std::make_unique<IRBuilder<>>(*TheContext);
```

**What it does:**
- Provides convenient methods to create LLVM instructions
- Keeps track of where to insert new instructions
- Makes IR generation much easier

**From IRBuilder.h** (`llvm/include/llvm/IR/IRBuilder.h:9-11`):
> "This file defines the IRBuilder class, which is used as a convenient way
> to create LLVM instructions with a consistent and simplified interface."

**Key methods in IRBuilder:**

```cpp
// Arithmetic operations
Value *CreateAdd(Value *LHS, Value *RHS, const Twine &Name = "")
Value *CreateFAdd(Value *LHS, Value *RHS, const Twine &Name = "")  // Float add
Value *CreateSub(Value *LHS, Value *RHS, const Twine &Name = "")
Value *CreateMul(Value *LHS, Value *RHS, const Twine &Name = "")

// Comparison operations
Value *CreateICmpEQ(Value *LHS, Value *RHS, const Twine &Name = "")
Value *CreateFCmpULT(Value *LHS, Value *RHS, const Twine &Name = "")

// Memory operations
Value *CreateAlloca(Type *Ty, Value *ArraySize = nullptr, const Twine &Name = "")
Value *CreateLoad(Type *Ty, Value *Ptr, const Twine &Name = "")
Value *CreateStore(Value *Val, Value *Ptr)

// Control flow
Value *CreateBr(BasicBlock *Dest)
Value *CreateCondBr(Value *Cond, BasicBlock *True, BasicBlock *False)
Value *CreateRet(Value *V)

// Function calls
Value *CreateCall(Function *Callee, ArrayRef<Value *> Args, const Twine &Name = "")

// Type conversions
Value *CreateUIToFP(Value *V, Type *DestTy, const Twine &Name = "")
Value *CreatePtrToInt(Value *V, Type *DestTy, const Twine &Name = "")
```

#### 4. **Function** - Function Representation

```cpp
#include "llvm/IR/Function.h"

// Create function type
FunctionType *FT = FunctionType::get(
    Type::getInt32Ty(*TheContext),  // Return type
    {Type::getInt32Ty(*TheContext), Type::getInt32Ty(*TheContext)},  // Parameter types
    false  // Not vararg
);

// Create the function
Function *F = Function::Create(
    FT,
    Function::ExternalLinkage,
    "my_function",
    TheModule.get()
);
```

#### 5. **BasicBlock** - Code Block

```cpp
#include "llvm/IR/BasicBlock.h"

// Create a basic block
BasicBlock *BB = BasicBlock::Create(*TheContext, "entry", TheFunction);

// Set insertion point for IRBuilder
Builder->SetInsertPoint(BB);
```

#### 6. **Type System**

```cpp
#include "llvm/IR/Type.h"
#include "llvm/IR/DerivedTypes.h"

// Basic types
Type *Int32Ty = Type::getInt32Ty(*TheContext);
Type *Int64Ty = Type::getInt64Ty(*TheContext);
Type *FloatTy = Type::getFloatTy(*TheContext);
Type *DoubleTy = Type::getDoubleTy(*TheContext);
Type *VoidTy = Type::getVoidTy(*TheContext);
Type *PtrTy = PointerType::get(*TheContext, 0);  // Opaque pointer

// Array types
ArrayType *ArrayTy = ArrayType::get(Int32Ty, 10);  // [10 x i32]

// Struct types
StructType *StructTy = StructType::create(*TheContext, "MyStruct");
StructTy->setBody({Int32Ty, FloatTy, PtrTy});
```

## Real Example: Kaleidoscope Language Frontend

Here's a complete example from the LLVM Kaleidoscope tutorial showing how to generate LLVM IR:

### Setup (from `llvm/examples/Kaleidoscope/Chapter3/toy.cpp:521-528`)

```cpp
static std::unique_ptr<LLVMContext> TheContext;
static std::unique_ptr<IRBuilder<>> Builder;
static std::unique_ptr<Module> TheModule;
static std::map<std::string, Value *> NamedValues;  // Symbol table

static void InitializeModule() {
    // Open a new context and module.
    TheContext = std::make_unique<LLVMContext>();
    TheModule = std::make_unique<Module>("my cool jit", *TheContext);

    // Create a new builder for the module.
    Builder = std::make_unique<IRBuilder<>>(*TheContext);
}
```

### Generating IR for a Number Literal

From `toy.cpp:413-417`:
```cpp
Value *NumberExprAST::codegen() {
    return ConstantFP::get(*TheContext, APFloat(Val));
}
```

This creates a floating-point constant in LLVM IR.

### Generating IR for Binary Operations

From `toy.cpp:424-444`:
```cpp
Value *BinaryExprAST::codegen() {
    Value *L = LHS->codegen();  // Generate IR for left side
    Value *R = RHS->codegen();  // Generate IR for right side
    if (!L || !R)
        return nullptr;

    switch (Op) {
    case '+':
        return Builder->CreateFAdd(L, R, "addtmp");
    case '-':
        return Builder->CreateFSub(L, R, "subtmp");
    case '*':
        return Builder->CreateFMul(L, R, "multmp");
    case '<':
        L = Builder->CreateFCmpULT(L, R, "cmptmp");
        // Convert bool 0/1 to double 0.0 or 1.0
        return Builder->CreateUIToFP(L, Type::getDoubleTy(*TheContext), "booltmp");
    default:
        return LogErrorV("invalid binary operator");
    }
}
```

**Notice:** The frontend just calls `Builder->CreateXXX()` methods. That's it!

### Generating IR for Function Calls

From `toy.cpp:446-464`:
```cpp
Value *CallExprAST::codegen() {
    // Look up the name in the global module table.
    Function *CalleeF = TheModule->getFunction(Callee);
    if (!CalleeF)
        return LogErrorV("Unknown function referenced");

    // If argument mismatch error.
    if (CalleeF->arg_size() != Args.size())
        return LogErrorV("Incorrect # arguments passed");

    std::vector<Value *> ArgsV;
    for (unsigned i = 0, e = Args.size(); i != e; ++i) {
        ArgsV.push_back(Args[i]->codegen());
        if (!ArgsV.back())
            return nullptr;
    }

    return Builder->CreateCall(CalleeF, ArgsV, "calltmp");
}
```

### Generating IR for Function Definitions

From `toy.cpp:466-481`:
```cpp
Function *PrototypeAST::codegen() {
    // Make the function type: double(double,double) etc.
    std::vector<Type *> Doubles(Args.size(), Type::getDoubleTy(*TheContext));
    FunctionType *FT =
        FunctionType::get(Type::getDoubleTy(*TheContext), Doubles, false);

    Function *F =
        Function::Create(FT, Function::ExternalLinkage, Name, TheModule.get());

    // Set names for all arguments.
    unsigned Idx = 0;
    for (auto &Arg : F->args())
        Arg.setName(Args[Idx++]);

    return F;
}
```

From `toy.cpp:483-515`:
```cpp
Function *FunctionAST::codegen() {
    // First, check for an existing function from a previous 'extern' declaration.
    Function *TheFunction = TheModule->getFunction(Proto->getName());

    if (!TheFunction)
        TheFunction = Proto->codegen();

    if (!TheFunction)
        return nullptr;

    // Create a new basic block to start insertion into.
    BasicBlock *BB = BasicBlock::Create(*TheContext, "entry", TheFunction);
    Builder->SetInsertPoint(BB);

    // Record the function arguments in the NamedValues map.
    NamedValues.clear();
    for (auto &Arg : TheFunction->args())
        NamedValues[std::string(Arg.getName())] = &Arg;

    if (Value *RetVal = Body->codegen()) {
        // Finish off the function.
        Builder->CreateRet(RetVal);

        // Validate the generated code, checking for consistency.
        verifyFunction(*TheFunction);

        return TheFunction;
    }

    // Error reading body, remove function.
    TheFunction->eraseFromParent();
    return nullptr;
}
```

## How Clang Uses These APIs

Clang's CodeGen module (`/clang/lib/CodeGen/`) uses the exact same APIs:

### Clang's Structure

```
/clang/lib/CodeGen/
├── CodeGenModule.h/.cpp    # Module-level code generation
├── CodeGenFunction.h/.cpp  # Function-level code generation
├── CGExpr.cpp              # Expression code generation
├── CGStmt.cpp              # Statement code generation
├── CGDecl.cpp              # Declaration code generation
└── IRBuilder usage throughout all files
```

### Example from Clang

From `clang/lib/CodeGen/CodeGenFunction.h:16`:
```cpp
#include "CGBuilder.h"  // Wrapper around IRBuilder
```

Clang creates a wrapper around IRBuilder but still uses the same LLVM APIs underneath. The pattern is:

1. Parse C/C++ code → AST
2. Walk the AST
3. For each AST node, call `Builder->CreateXXX()` to generate IR
4. Done!

## What Happens After IR Generation?

### The Pipeline After Frontend

```
Frontend (Your Code)
    ↓
Generates LLVM IR
    ↓
┌─────────────────────────────────────────────┐
│  Everything Below is Provided by LLVM!     │
│  You DON'T write any of this code          │
└─────────────────────────────────────────────┘
    ↓
LLVM Optimizer (opt)
    ↓
LLVM Code Generator (llc)
    ↓
Assembly/Object File
    ↓
Linker (lld)
    ↓
Executable
```

### What Language Developers DON'T Need to Do

✅ **What you DO (Frontend only):**
- Lexical analysis (tokenization)
- Parsing (AST construction)
- Semantic analysis (type checking)
- Call LLVM APIs to generate IR

❌ **What you DON'T do (LLVM handles this):**
- Write optimization passes (unless adding new ones)
- Write backend code generation
- Handle target-specific details (x86, ARM, etc.)
- Write assemblers
- Write linkers
- Deal with instruction selection
- Deal with register allocation
- Deal with instruction scheduling

### Using LLVM Tools

After generating IR, you use existing LLVM tools:

```bash
# 1. Your frontend generates IR
my_compiler source.mylang -o output.ll

# 2. Optimize the IR (LLVM's opt tool)
opt -O2 output.ll -S -o optimized.ll

# 3. Generate machine code (LLVM's llc tool)
llc optimized.ll -o output.s

# 4. Assemble and link (LLVM's clang or lld)
clang output.s -o executable
```

Or do it all at once using LLVM libraries:

```cpp
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Target/TargetMachine.h"

// After generating IR in TheModule...

// Run optimizations
legacy::PassManager PM;
PassManagerBuilder Builder;
Builder.OptLevel = 2;
Builder.populateModulePassManager(PM);
PM.run(*TheModule);

// Generate object file
// (Using TargetMachine and code generation APIs)
```

## Summary: The Frontend Developer's Workflow

### Step 1: Include LLVM Headers

```cpp
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Verifier.h"
```

### Step 2: Initialize LLVM Data Structures

```cpp
LLVMContext Context;
Module TheModule("my_module", Context);
IRBuilder<> Builder(Context);
```

### Step 3: Generate IR

Walk your AST and call IRBuilder methods:

```cpp
// For each AST node, generate corresponding IR
Value *CodeGen(ASTNode *node) {
    if (BinaryOp *binop = dyn_cast<BinaryOp>(node)) {
        Value *L = CodeGen(binop->left);
        Value *R = CodeGen(binop->right);
        return Builder.CreateAdd(L, R, "addtmp");
    }
    // ... handle other node types
}
```

### Step 4: Verify IR (Optional but Recommended)

```cpp
#include "llvm/IR/Verifier.h"

if (verifyModule(TheModule, &errs())) {
    errs() << "Error: module verification failed\n";
}
```

### Step 5: Output IR

```cpp
// Print to stdout
TheModule.print(outs(), nullptr);

// Write to file
std::error_code EC;
raw_fd_ostream OS("output.ll", EC);
TheModule.print(OS, nullptr);
```

### Step 6: You're Done!

**That's it!** Now use LLVM's tools:
- `opt` for optimization
- `llc` for code generation
- `lld` for linking

## Comparison with Traditional Compilers

### Traditional Compiler (You Write Everything)

```
┌──────────────────────────────────────┐
│  Frontend (YOU write)                │
│  - Lexer, Parser, Semantic Analysis  │
└──────────────┬───────────────────────┘
               ↓
┌──────────────────────────────────────┐
│  Optimizer (YOU write)               │ ← You write this
│  - Loop optimizations                │
│  - Dead code elimination, etc.       │
└──────────────┬───────────────────────┘
               ↓
┌──────────────────────────────────────┐
│  Backend (YOU write)                 │ ← You write this
│  - Instruction selection              │
│  - Register allocation                │
│  - Code emission                      │
└──────────────┬───────────────────────┘
               ↓
          Assembly Code
```

### LLVM-Based Compiler (You Write Only Frontend)

```
┌──────────────────────────────────────┐
│  Frontend (YOU write)                │
│  - Lexer, Parser, Semantic Analysis  │
│  - Call LLVM APIs to generate IR     │
└──────────────┬───────────────────────┘
               ↓
         ┌──────────┐
         │ LLVM IR  │
         └────┬─────┘
              ↓
┌──────────────────────────────────────┐
│  Optimizer (LLVM provides)           │ ← LLVM handles
└──────────────┬───────────────────────┘
               ↓
┌──────────────────────────────────────┐
│  Backend (LLVM provides)             │ ← LLVM handles
└──────────────┬───────────────────────┘
               ↓
          Assembly Code
```

## Key Insight

**The entire value proposition of LLVM is this:**

> "Write your frontend once using LLVM's IR building APIs, and you get
> hundreds of optimizations and support for dozens of architectures
> for free."

You **only** write code to generate LLVM IR. Everything else is done by LLVM.

## Resources for Frontend Development

### Essential Documentation

1. **LLVM Language Reference** - `/llvm/docs/LangRef.rst`
   - Complete LLVM IR specification

2. **Kaleidoscope Tutorial** - `/llvm/docs/tutorial/MyFirstLanguageFrontend/`
   - Step-by-step guide to building a frontend
   - Shows exactly how to use IRBuilder and other APIs

3. **Doxygen API Reference** - https://llvm.org/doxygen/
   - Complete API documentation for all LLVM classes

4. **LLVM Programmer's Manual** - https://llvm.org/docs/ProgrammersManual.html
   - Conventions and patterns used in LLVM

### Example Frontends in LLVM Project

1. **Clang** - `/clang/lib/CodeGen/`
   - Production C/C++/Objective-C frontend
   - Shows how to handle complex languages

2. **Flang** - `/flang/lib/Lower/`
   - Fortran frontend
   - Shows how to handle array-oriented languages

3. **Kaleidoscope** - `/llvm/examples/Kaleidoscope/`
   - Simple tutorial language
   - Best for learning the basics

## Frequently Asked Questions

### Q: Do I need to understand LLVM's optimization passes?

**A:** No! You just generate IR and call the optimization passes. You don't need to understand their internals unless you want to write new passes.

### Q: Do I need to know about target architectures (x86, ARM, etc.)?

**A:** No! That's handled by LLVM's backend. Your IR is platform-independent.

### Q: Can I mix my language with C/C++?

**A:** Yes! If you generate proper LLVM IR with compatible ABI, you can link with C/C++ code.

### Q: How do I handle language-specific features?

**A:** In your frontend, before generating IR:
- Type checking → Do in your frontend
- Memory management → Generate appropriate IR (mallocs, frees, or GC calls)
- Exceptions → Use LLVM's exception handling IR constructs
- Closures → Generate IR for closure structures and code

### Q: What about debugging information?

**A:** LLVM provides APIs to generate DWARF debug info:
```cpp
#include "llvm/IR/DIBuilder.h"

DIBuilder DBuilder(TheModule);
// Create debug info for functions, variables, etc.
```

### Q: Is generating IR efficient?

**A:** Yes! The IR builder is highly optimized. Major compilers (Clang, Rust, Swift) use it in production.

## Conclusion

**The answer to your question:**

1. **What do language developers use?**
   - LLVM C++ APIs in `/llvm/include/llvm/IR/`
   - Mainly: `LLVMContext`, `Module`, `IRBuilder<>`, `Function`, `BasicBlock`, `Type`

2. **Do they need to do anything after generating IR?**
   - **No!** Just use LLVM's tools (`opt`, `llc`, `lld`)
   - Everything after IR generation is provided by LLVM
   - You don't write optimization or backend code

**The beauty of LLVM:** Write your frontend, generate IR, and you're done!

## Next Steps

To start building your own frontend:

1. Study the Kaleidoscope tutorial: `/llvm/docs/tutorial/MyFirstLanguageFrontend/`
2. Look at the examples: `/llvm/examples/Kaleidoscope/`
3. Read the LLVM IR reference: `/llvm/docs/LangRef.rst`
4. Explore Clang's CodeGen for real-world patterns: `/clang/lib/CodeGen/`

Happy compiler building! 🎉
