# New Developer Guide for LLVM Project

Welcome to the LLVM project! This guide will help you get started contributing to one of the largest and most important compiler infrastructure projects in the world.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Repository Structure](#repository-structure)
3. [Prerequisites](#prerequisites)
4. [Building LLVM](#building-llvm)
5. [Development Workflow](#development-workflow)
6. [Testing](#testing)
7. [Coding Standards](#coding-standards)
8. [Contributing](#contributing)
9. [Getting Help](#getting-help)
10. [Common Commands Reference](#common-commands-reference)

---

## Project Overview

The LLVM Project is a collection of modular and reusable compiler and toolchain technologies. Despite its name, LLVM has little to do with traditional virtual machines. The name "LLVM" itself is not an acronym; it is the full name of the project.

### Main Components

- **LLVM Core**: Libraries for building compilers, including intermediate representation (IR), optimizations, code generation, and analysis tools
- **Clang**: C/C++/Objective-C compiler frontend
- **Clang Tools Extra**: Additional Clang-based tools (clang-tidy, clang-format, etc.)
- **LLD**: The LLVM Linker
- **LLDB**: The LLVM Debugger
- **libc++**: C++ Standard Library implementation
- **libc++abi**: C++ ABI library
- **compiler-rt**: Runtime libraries (sanitizers, profile instrumentation, etc.)
- **MLIR**: Multi-Level Intermediate Representation for compiler infrastructure
- **Flang**: Fortran compiler frontend
- **OpenMP**: OpenMP runtime library
- **Polly**: Polyhedral optimizations for LLVM
- **BOLT**: Binary Optimization and Layout Tool

---

## Repository Structure

The LLVM project uses a monorepo structure. Here's what you'll find at the top level:

```
llvm-project/
├── llvm/              # Core LLVM libraries and tools
│   ├── include/       # Public headers
│   ├── lib/           # Implementation files
│   ├── tools/         # Command-line tools (opt, llc, etc.)
│   ├── test/          # Regression tests
│   └── unittests/     # Unit tests
├── clang/             # C/C++/Objective-C compiler
│   ├── include/       # Public headers
│   ├── lib/           # Implementation
│   ├── tools/         # clang binary and related tools
│   └── test/          # Tests
├── clang-tools-extra/ # Additional Clang tools
├── lld/               # LLVM linker
├── lldb/              # LLVM debugger
├── compiler-rt/       # Runtime libraries (sanitizers, etc.)
├── libcxx/            # C++ standard library
├── libcxxabi/         # C++ ABI library
├── mlir/              # Multi-Level IR
├── flang/             # Fortran frontend
├── openmp/            # OpenMP runtime
├── polly/             # Polyhedral optimizer
├── bolt/              # Binary optimizer
├── cmake/             # Common CMake modules
└── runtimes/          # Runtime library build configuration
```

### Key Directories in LLVM Core

- `llvm/include/llvm/`: Public C++ API headers
- `llvm/lib/`: Implementation of libraries
- `llvm/tools/`: Source code for LLVM tools
- `llvm/test/`: Regression tests (using lit test runner)
- `llvm/unittests/`: Unit tests (using Google Test)
- `llvm/docs/`: Documentation (ReStructuredText format)
- `llvm/examples/`: Example code for using LLVM APIs

---

## Prerequisites

### Software Requirements

- **CMake**: Version 3.20 or later
- **C++ Compiler**:
  - GCC 7.1+
  - Clang 5.0+
  - Visual Studio 2019+ (Windows)
  - Apple Clang 10.0+ (macOS)
- **Python**: 3.6 or later (for running tests)
- **Git**: For version control
- **Ninja**: Recommended build system (faster than Make)

### Hardware Requirements

- **Disk Space**: At least 20-30 GB for a full build
- **RAM**: Minimum 8 GB, recommended 16 GB or more
- **CPU**: Multi-core processor recommended (builds can be parallelized)

### Optional but Recommended

- **ccache**: For faster rebuilds
- **LLD**: LLVM's linker (faster than GNU ld)
- **sccache**: Distributed compilation cache

---

## Building LLVM

### Quick Start

Here's the fastest way to get a working LLVM build:

```bash
# 1. Clone the repository (if you haven't already)
git clone https://github.com/llvm/llvm-project.git
cd llvm-project

# 2. Create a build directory
mkdir build
cd build

# 3. Configure with CMake (basic debug build)
cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug \
      -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" \
      ../llvm

# 4. Build (this will take a while - 30 min to 2+ hours depending on your machine)
ninja

# 5. Run tests to verify everything works
ninja check-llvm
ninja check-clang
```

### Build Configuration Options

Here are the most common CMake options you'll use:

#### Essential Options

```bash
# Specify which projects to build
-DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld;lldb"

# Build type (controls optimization and debug info)
-DCMAKE_BUILD_TYPE=Debug          # Full debug info, no optimization
-DCMAKE_BUILD_TYPE=Release        # Optimized, minimal debug info
-DCMAKE_BUILD_TYPE=RelWithDebInfo # Optimized with debug info
-DCMAKE_BUILD_TYPE=MinSizeRel     # Optimized for size

# Installation prefix
-DCMAKE_INSTALL_PREFIX=/usr/local

# Enable assertions (highly recommended for development)
-DLLVM_ENABLE_ASSERTIONS=ON
```

#### Performance Options

```bash
# Use LLD for faster linking (if you have it installed)
-DLLVM_USE_LINKER=lld

# Limit parallel jobs (if you run out of memory)
-DLLVM_PARALLEL_COMPILE_JOBS=4
-DLLVM_PARALLEL_LINK_JOBS=2

# Use ccache for faster rebuilds
-DLLVM_CCACHE_BUILD=ON

# Build only for your host architecture (faster)
-DLLVM_TARGETS_TO_BUILD="X86"  # Or ARM, AArch64, etc.
```

#### Development Options

```bash
# Enable expensive checks (for core development)
-DLLVM_ENABLE_EXPENSIVE_CHECKS=ON

# Build examples
-DLLVM_BUILD_EXAMPLES=ON

# Enable doxygen documentation
-DLLVM_ENABLE_DOXYGEN=ON

# Enable compiler warnings
-DLLVM_ENABLE_WARNINGS=ON
-DLLVM_ENABLE_PEDANTIC=ON
```

### Recommended Development Configuration

For day-to-day development, this configuration provides a good balance:

```bash
cmake -G Ninja \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  -DLLVM_USE_LINKER=lld \
  -DLLVM_CCACHE_BUILD=ON \
  -DLLVM_PARALLEL_LINK_JOBS=2 \
  ../llvm
```

### Incremental Builds

After the initial build, you can rebuild specific targets:

```bash
# Rebuild everything
ninja

# Rebuild just the clang binary
ninja clang

# Rebuild and run LLVM tests
ninja check-llvm

# Rebuild a specific tool
ninja llc
ninja opt
```

---

## Development Workflow

### 1. Setting Up Your Development Environment

```bash
# Configure git
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Filter out user branches (reduces clutter)
git config --add remote.origin.fetch '^refs/heads/users/*'
git config --add remote.origin.fetch '^refs/heads/revert-*'
```

### 2. Creating a Working Branch

```bash
# Always work on a branch, never on main
git checkout -b my-feature-branch

# Keep your branch up to date
git fetch origin
git rebase origin/main
```

### 3. Making Changes

1. **Find the code**: Use tools like `grep`, `git grep`, or IDE search
2. **Understand context**: Read related code, tests, and documentation
3. **Make your changes**: Follow the coding standards (see below)
4. **Build locally**: `ninja` to ensure your code compiles
5. **Run tests**: `ninja check-llvm` or `ninja check-clang`

### 4. Testing Your Changes

```bash
# Run all tests for a project
ninja check-llvm
ninja check-clang

# Run a specific test file
llvm-lit test/path/to/test.ll

# Run tests matching a pattern
llvm-lit -a test/ --filter=pattern
```

### 5. Formatting Your Code

LLVM uses `clang-format` for code formatting:

```bash
# Format a single file
clang-format -i path/to/file.cpp

# Format all changed files
git clang-format
```

### 6. Commit Your Changes

```bash
# Stage your changes
git add path/to/changed/files

# Commit with a descriptive message
git commit

# Commit message format:
# [Component] Brief description (50 chars or less)
#
# More detailed explanation if needed. Wrap at 72 characters.
# Explain what and why, not how.
```

Example commit message:
```
[Clang] Fix crash when parsing template specializations

The parser was not correctly handling partial specializations with
dependent types. This patch adds proper checking before attempting
to instantiate the template.

Fixes #12345
```

---

## Testing

LLVM has a comprehensive testing infrastructure using several frameworks:

### Test Types

1. **Regression Tests** (`test/` directories)
   - Written in LLVM assembly or other source languages
   - Run with `lit` (LLVM Integrated Tester)
   - Use `FileCheck` for output verification

2. **Unit Tests** (`unittests/` directories)
   - Written in C++ using Google Test
   - Test individual classes and functions
   - Run with standard test runners

### Running Tests

```bash
# Run all tests
ninja check-all

# Run tests for specific projects
ninja check-llvm      # LLVM core tests
ninja check-clang     # Clang tests
ninja check-lld       # LLD tests

# Run a single test file
llvm-lit path/to/test.ll

# Run tests in a directory
llvm-lit test/CodeGen/X86/

# Run with verbose output
llvm-lit -v test/path/

# Run tests matching a filter
llvm-lit -a --filter=pattern test/
```

### Writing Tests

Example regression test (test.ll):

```llvm
; RUN: opt -passes=my-pass < %s | FileCheck %s

; CHECK-LABEL: @test_function
define i32 @test_function(i32 %a) {
  ; CHECK: %result = add i32 %a, 1
  %result = add i32 %a, 1
  ret i32 %result
}
```

Example unit test:

```cpp
#include "llvm/...h"
#include "gtest/gtest.h"

TEST(MyTestSuite, BasicTest) {
  // Your test code here
  EXPECT_EQ(expected, actual);
}
```

---

## Coding Standards

LLVM has strict coding standards. Key points:

### C++ Style

- **Naming Conventions**:
  - Types: `UpperCamelCase` (e.g., `MyClass`)
  - Functions: `lowerCamelCase` (e.g., `myFunction()`)
  - Variables: `UpperCamelCase` (e.g., `MyVariable`)
  - Constants: `UpperCamelCase` with `k` prefix (e.g., `kMyConstant`)

- **Formatting**:
  - 80 column limit (flexible to 100 for readability)
  - 2 spaces for indentation (no tabs)
  - Use `clang-format` to auto-format

- **Modern C++**:
  - Use C++17 features (as of 2024)
  - Prefer `auto` when type is obvious
  - Use range-based for loops
  - Prefer smart pointers for ownership

### Code Quality

- **No warnings**: Code must compile without warnings
- **Documentation**: Use Doxygen comments for public APIs
- **Error handling**: Use `llvm::Error` for error propagation
- **LLVM utilities**: Use LLVM's ADT (StringRef, SmallVector, etc.)

### Example Code

```cpp
#include "llvm/ADT/StringRef.h"
#include "llvm/Support/Error.h"

namespace llvm {

/// Brief description of the class.
///
/// More detailed description if needed.
class MyAnalysisPass : public PassInfoMixin<MyAnalysisPass> {
public:
  /// Run the analysis on the given function.
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &AM);

private:
  /// Helper method to process basic blocks.
  void processBasicBlock(BasicBlock &BB);
};

} // namespace llvm
```

Full coding standards: `llvm/docs/CodingStandards.rst`

---

## Contributing

### Before You Start

1. **Check existing work**: Search for related issues and patches
2. **Discuss major changes**: Use Discourse forums or GitHub issues
3. **Read the docs**: Review `llvm/docs/Contributing.html`

### Contribution Process

LLVM uses **GitHub Pull Requests** for contributions.

#### Step-by-Step Guide

1. **Fork and clone** (if you haven't already):
   ```bash
   # Fork the repo on GitHub, then:
   git clone https://github.com/YOUR_USERNAME/llvm-project.git
   cd llvm-project
   git remote add upstream https://github.com/llvm/llvm-project.git
   ```

2. **Create a branch**:
   ```bash
   git checkout -b my-contribution
   ```

3. **Make your changes** following the workflow above

4. **Push to your fork**:
   ```bash
   git push origin my-contribution
   ```

5. **Create a Pull Request** on GitHub:
   - Go to your fork on GitHub
   - Click "Pull Request"
   - Fill in the description explaining your changes

6. **Respond to feedback**:
   - Reviewers will comment on your PR
   - Make requested changes
   - Push updates to your branch (they'll appear in the PR)

### PR Best Practices

- **Keep PRs focused**: One logical change per PR
- **Write good descriptions**: Explain what and why
- **Be responsive**: Reply to reviewer comments promptly
- **Be patient**: Reviews can take time
- **Split large changes**: Break into smaller, reviewable PRs

### Review Process

- PRs require review from project maintainers
- Expect constructive feedback
- You may need to iterate several times
- Once approved, a maintainer will merge your PR

---

## Getting Help

### Communication Channels

- **Discourse Forums**: https://discourse.llvm.org/
  - Best for design discussions and questions
  - Active community

- **Discord**: https://discord.gg/xS7Z362
  - Real-time chat
  - Good for quick questions

- **GitHub Issues**: https://github.com/llvm/llvm-project/issues
  - Bug reports
  - Feature requests

- **Office Hours**: https://llvm.org/docs/GettingInvolved.html#office-hours
  - Regular video calls with maintainers

### Documentation Resources

- **Getting Started**: https://llvm.org/docs/GettingStarted.html
- **LLVM Programmer's Manual**: https://llvm.org/docs/ProgrammersManual.html
- **LLVM Language Reference**: https://llvm.org/docs/LangRef.html
- **Coding Standards**: https://llvm.org/docs/CodingStandards.html
- **Developer Policy**: https://llvm.org/docs/DeveloperPolicy.html

### Finding Your First Issue

Look for issues tagged with:
- `good first issue`
- `beginner friendly`
- `documentation`

Start small and build up your understanding!

---

## Common Commands Reference

### Building

```bash
# Full build
ninja

# Build specific target
ninja clang
ninja llc

# Clean build
ninja clean

# Reconfigure CMake
cmake ../llvm
```

### Testing

```bash
# All tests
ninja check-all

# Project-specific tests
ninja check-llvm
ninja check-clang

# Single test
llvm-lit path/to/test.ll

# Verbose test output
llvm-lit -v path/to/test/
```

### Code Quality

```bash
# Format your code
git clang-format

# Format specific file
clang-format -i file.cpp

# Run clang-tidy
clang-tidy file.cpp -- -I../llvm/include
```

### Git

```bash
# Update your branch
git fetch upstream
git rebase upstream/main

# Amend your last commit
git add .
git commit --amend

# Interactive rebase (clean up commits)
git rebase -i upstream/main
```

### Useful LLVM Tools

```bash
# View LLVM IR
opt -S input.ll

# Optimize LLVM IR
opt -O2 input.ll -o output.ll

# Compile IR to assembly
llc input.ll -o output.s

# Disassemble bitcode
llvm-dis input.bc -o output.ll

# Assemble IR to bitcode
llvm-as input.ll -o output.bc
```

---

## Tips for Success

1. **Start small**: Don't try to tackle major features immediately
2. **Read code**: The best way to learn LLVM's patterns
3. **Run tests frequently**: Catch issues early
4. **Use assertions**: Build with assertions enabled during development
5. **Ask questions**: The community is helpful
6. **Be patient**: LLVM is large; it takes time to understand
7. **Document as you learn**: Help the next developer
8. **Study existing patches**: Learn from approved PRs

---

## Common Pitfalls to Avoid

1. **Building without assertions**: Always use `-DLLVM_ENABLE_ASSERTIONS=ON`
2. **Not running tests**: Always run tests before submitting
3. **Ignoring warnings**: Fix all compiler warnings
4. **Not using clang-format**: Always format your code
5. **Large, unfocused PRs**: Keep changes small and focused
6. **Not reading coding standards**: Follow the established patterns
7. **Building too much**: Only enable projects you're working on
8. **Not using ninja**: Ninja is much faster than make

---

## Next Steps

Now that you have the basics:

1. **Build LLVM** following the instructions above
2. **Run the tests** to ensure everything works
3. **Find a simple issue** to work on
4. **Join the community** on Discourse or Discord
5. **Start contributing**!

Welcome to the LLVM community, and happy hacking!

---

## Additional Resources

- Main website: https://llvm.org/
- Documentation: https://llvm.org/docs/
- Source browser: https://github.com/llvm/llvm-project
- Bug tracker: https://github.com/llvm/llvm-project/issues
- Code review: Pull requests on GitHub
- Blog: https://blog.llvm.org/

Last updated: November 2024
