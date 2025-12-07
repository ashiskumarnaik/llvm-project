# LLVM Quick Reference Cheat Sheet

A quick reference for common LLVM development tasks.

## Build Commands

```bash
# Initial Configuration
cmake -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  ../llvm

# Build Everything
ninja

# Build Specific Targets
ninja clang                    # Build clang compiler
ninja opt                      # Build optimizer
ninja llc                      # Build LLVM compiler
ninja clang-format            # Build clang-format tool
ninja clang-tidy              # Build clang-tidy tool

# Clean Build
ninja clean
```

## Testing Commands

```bash
# Run All Tests
ninja check-all

# Run Project Tests
ninja check-llvm              # LLVM tests
ninja check-clang             # Clang tests
ninja check-clang-tools       # Clang tools tests

# Run Single Test
llvm-lit path/to/test.ll

# Run Tests in Directory
llvm-lit test/CodeGen/

# Verbose Test Output
llvm-lit -v test/path/

# Run Tests with Filter
llvm-lit --filter=keyword test/

# Run Specific Unit Test
./unittests/Support/SupportTests --gtest_filter=TestName
```

## Code Formatting

```bash
# Format Changed Files (Git)
git clang-format

# Format Specific File
clang-format -i file.cpp

# Check Format (Don't Modify)
clang-format file.cpp | diff file.cpp -

# Format All Files in Directory
find . -name "*.cpp" -o -name "*.h" | xargs clang-format -i
```

## Git Workflow

```bash
# Create Branch
git checkout -b feature-name

# Update Branch from Main
git fetch upstream
git rebase upstream/main

# Stage Changes
git add file1.cpp file2.h

# Commit
git commit -m "[Component] Brief description"

# Amend Last Commit
git add .
git commit --amend

# Push to Fork
git push origin feature-name

# Force Push (After Rebase)
git push -f origin feature-name
```

## LLVM Tools

```bash
# Compile C/C++ to LLVM IR
clang -S -emit-llvm input.c -o output.ll

# Optimize LLVM IR
opt -O2 input.ll -o optimized.ll

# Compile LLVM IR to Object File
llc input.ll -o output.o

# View LLVM IR (Disassemble Bitcode)
llvm-dis input.bc -o output.ll

# Assemble LLVM IR to Bitcode
llvm-as input.ll -o output.bc

# Link Bitcode Files
llvm-link file1.bc file2.bc -o combined.bc

# Analyze IR
opt -analyze -<pass-name> input.ll

# View Assembly
llc -filetype=asm input.ll -o output.s

# View CFG (Control Flow Graph)
opt -dot-cfg input.ll
dot -Tpng cfg.dot -o cfg.png
```

## Debugging

```bash
# Build with Debug Info
cmake -DCMAKE_BUILD_TYPE=Debug ../llvm

# Run Under Debugger
lldb clang
(lldb) run input.c

# Debug Optimizer
lldb opt
(lldb) run -O2 input.ll

# Print LLVM IR During Compilation
clang -mllvm -print-after-all input.c

# Debug Pass Pipeline
opt -debug-pass=Structure input.ll

# Enable Specific Debug Output
opt -debug-only=pass-name input.ll
```

## CMake Options Reference

### Build Types
```bash
-DCMAKE_BUILD_TYPE=Debug          # No optimization, debug info
-DCMAKE_BUILD_TYPE=Release        # Optimized, no debug info
-DCMAKE_BUILD_TYPE=RelWithDebInfo # Optimized with debug info
-DCMAKE_BUILD_TYPE=MinSizeRel     # Optimize for size
```

### Project Selection
```bash
-DLLVM_ENABLE_PROJECTS="clang"
-DLLVM_ENABLE_PROJECTS="clang;lld;lldb"
-DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;compiler-rt"
```

### Performance Options
```bash
-DLLVM_USE_LINKER=lld             # Use LLD (faster linking)
-DLLVM_CCACHE_BUILD=ON            # Enable ccache
-DLLVM_PARALLEL_LINK_JOBS=2       # Limit link jobs
-DLLVM_PARALLEL_COMPILE_JOBS=8    # Limit compile jobs
-DLLVM_OPTIMIZED_TABLEGEN=ON      # Use optimized tablegen
```

### Development Options
```bash
-DLLVM_ENABLE_ASSERTIONS=ON       # Enable assertions (recommended!)
-DLLVM_ENABLE_EXPENSIVE_CHECKS=ON # Extra validation
-DLLVM_ENABLE_WARNINGS=ON         # Enable compiler warnings
-DLLVM_BUILD_EXAMPLES=ON          # Build example code
-DLLVM_TARGETS_TO_BUILD="X86"     # Only build X86 backend
```

## Common File Extensions

- `.ll` - LLVM IR in human-readable text format
- `.bc` - LLVM IR in bitcode (binary) format
- `.td` - TableGen definition files
- `.inc` - Generated include files
- `.def` - Macro definition files
- `.h` / `.hpp` - C++ header files
- `.cpp` - C++ implementation files

## LLVM IR Basics

### Basic Structure
```llvm
; Comment
define i32 @function_name(i32 %param) {
entry:
  %local = add i32 %param, 1
  ret i32 %local
}
```

### Common Instructions
```llvm
%result = add i32 %a, %b        ; Addition
%result = sub i32 %a, %b        ; Subtraction
%result = mul i32 %a, %b        ; Multiplication
%result = sdiv i32 %a, %b       ; Signed division
%result = icmp eq i32 %a, %b    ; Integer comparison
%ptr = alloca i32               ; Stack allocation
%val = load i32, i32* %ptr      ; Load from memory
store i32 %val, i32* %ptr       ; Store to memory
br label %dest                  ; Unconditional branch
br i1 %cond, label %t, label %f ; Conditional branch
ret i32 %val                    ; Return
```

### Common Types
```llvm
i1, i8, i16, i32, i64          ; Integer types
float, double                   ; Floating point
i32*, i8**                      ; Pointer types
[10 x i32]                      ; Array type
{i32, i8}                       ; Structure type
<4 x i32>                       ; Vector type
void                            ; No return type
```

## FileCheck Basics

```llvm
; RUN: opt -passes=my-pass < %s | FileCheck %s

define i32 @test() {
; CHECK-LABEL: @test()
; CHECK: %result = add
; CHECK-NOT: sub
; CHECK-NEXT: ret i32
  %result = add i32 1, 2
  ret i32 %result
}
```

### FileCheck Directives
- `CHECK:` - Must appear in order
- `CHECK-NEXT:` - Must be on next line
- `CHECK-NOT:` - Must not appear
- `CHECK-LABEL:` - Defines a section
- `CHECK-DAG:` - Can appear in any order
- `CHECK-SAME:` - Must be on same line

## Code Review Checklist

Before submitting a PR:

- [ ] Code compiles without warnings
- [ ] All tests pass (`ninja check-all`)
- [ ] Code is formatted (`git clang-format`)
- [ ] New tests added for new functionality
- [ ] Documentation updated if needed
- [ ] Commit message follows format
- [ ] Changes are focused and minimal
- [ ] No debugging code left in

## Useful Environment Variables

```bash
# Print IR after each pass
export LLVM_PRINT_AFTER_ALL=1

# Print IR before each pass
export LLVM_PRINT_BEFORE_ALL=1

# Debug specific pass
export LLVM_DEBUG_ONLY=pass-name

# Increase lit parallelism
export LIT_MAX_WORKERS=8
```

## Directory Navigation

```bash
# Core libraries
llvm/lib/IR/                  # IR classes
llvm/lib/Analysis/            # Analysis passes
llvm/lib/Transforms/          # Transformation passes
llvm/lib/CodeGen/             # Code generation
llvm/lib/Target/X86/          # X86 backend

# Headers
llvm/include/llvm/IR/         # IR public headers
llvm/include/llvm/Analysis/   # Analysis headers
llvm/include/llvm/Support/    # Support utilities

# Tests
llvm/test/                    # Regression tests
llvm/unittests/               # Unit tests

# Clang
clang/lib/Sema/              # Semantic analysis
clang/lib/Parse/             # Parser
clang/lib/CodeGen/           # Code generation
clang/include/clang/AST/     # AST headers
```

## Getting Help

```bash
# List all CMake options
cmake -LAH

# List all ninja targets
ninja -t targets

# Show build statistics
ninja -d stats

# Explain why a target is built
ninja -t query target-name

# View dependency graph
ninja -t graph target-name | dot -Tpng > graph.png
```

## Common Patterns

### Creating a Pass
```cpp
#include "llvm/IR/PassManager.h"

class MyPass : public PassInfoMixin<MyPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &AM);
};
```

### Iterating Over Instructions
```cpp
for (BasicBlock &BB : F) {
  for (Instruction &I : BB) {
    // Process instruction
  }
}
```

### Using StringRef
```cpp
StringRef Name = F.getName();  // No copy
if (Name.starts_with("test_"))
  // ...
```

### Error Handling
```cpp
Expected<Value> Result = someFunction();
if (!Result)
  return Result.takeError();
Value V = *Result;
```

## Performance Tips

1. Use `ccache` for faster rebuilds
2. Use `lld` for faster linking
3. Limit parallel link jobs to avoid OOM
4. Build only needed targets
5. Use `RelWithDebInfo` for development
6. Only build backends you need

## Troubleshooting

### Build Issues
```bash
# Clean and rebuild
ninja clean
cmake ../llvm
ninja

# Reconfigure from scratch
rm -rf build/*
cmake -G Ninja ../llvm

# Check CMake cache
cmake -LAH | grep OPTION_NAME
```

### Test Failures
```bash
# Run single failing test verbosely
llvm-lit -v path/to/test.ll

# Show test output
llvm-lit -a path/to/test.ll

# Debug test
llvm-lit --debug path/to/test.ll
```

### Linker Issues
```bash
# Out of memory during linking
-DLLVM_PARALLEL_LINK_JOBS=1

# Use LLD
-DLLVM_USE_LINKER=lld

# Use gold linker
-DLLVM_USE_LINKER=gold
```

---

Quick links:
- Full Guide: `NEW_DEVELOPER_GUIDE.md`
- LLVM Docs: https://llvm.org/docs/
- Discourse: https://discourse.llvm.org/
