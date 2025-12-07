# Developer Documentation

Welcome to the LLVM Project developer documentation! This directory contains guides and references to help you get started with LLVM development.

## Available Guides

### 1. [New Developer Guide](NEW_DEVELOPER_GUIDE.md) ⭐ START HERE

**A comprehensive guide for new contributors to the LLVM project.**

This guide covers:
- Project overview and components
- Repository structure
- Prerequisites and setup
- Building LLVM from source
- Development workflow
- Testing infrastructure
- Coding standards
- Contributing process
- Getting help and community resources

**Who should read this**: Anyone new to LLVM development or wanting a complete overview.

---

### 2. [Quick Reference](QUICK_REFERENCE.md)

**A cheat sheet for common LLVM development tasks.**

Quick access to:
- Build commands and CMake options
- Testing commands
- Git workflow
- LLVM tools usage
- Code formatting
- Debugging techniques
- Common file extensions
- LLVM IR basics
- FileCheck patterns
- Troubleshooting tips

**Who should read this**: Developers who need quick command references while working.

---

### 3. [Architecture Guide](ARCHITECTURE_GUIDE.md)

**Deep dive into LLVM's internal architecture and design.**

Covers:
- High-level architecture overview
- LLVM core components (IR, Analysis, Transforms, CodeGen)
- Clang architecture and compilation pipeline
- Code organization and structure
- Key subsystems (Pass Manager, Target Machine, etc.)
- Data structures and utilities (ADT)
- Pass infrastructure
- Target backend architecture
- Common patterns and idioms

**Who should read this**: Developers who want to understand how LLVM works internally.

---

## Quick Start Path

If you're new to LLVM, follow this path:

1. **Read**: [New Developer Guide](NEW_DEVELOPER_GUIDE.md)
   - Get overview of the project
   - Set up your development environment
   - Build LLVM for the first time

2. **Build**: Follow the build instructions
   ```bash
   cmake -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo \
     -DLLVM_ENABLE_PROJECTS="clang" \
     -DLLVM_ENABLE_ASSERTIONS=ON \
     ../llvm
   ninja
   ```

3. **Test**: Verify your build works
   ```bash
   ninja check-llvm
   ninja check-clang
   ```

4. **Reference**: Bookmark [Quick Reference](QUICK_REFERENCE.md)
   - Keep it open while coding
   - Use for common commands

5. **Learn**: Read [Architecture Guide](ARCHITECTURE_GUIDE.md)
   - Understand the codebase structure
   - Learn about components you'll work with

6. **Contribute**: Find a starter issue
   - Look for "good first issue" tags
   - Start with small, focused changes
   - Join the community discussions

---

## Additional Resources

### Official LLVM Documentation
- **Main Site**: https://llvm.org/
- **Getting Started**: https://llvm.org/docs/GettingStarted.html
- **Programmer's Manual**: https://llvm.org/docs/ProgrammersManual.html
- **Language Reference**: https://llvm.org/docs/LangRef.html
- **Coding Standards**: https://llvm.org/docs/CodingStandards.html
- **All Documentation**: https://llvm.org/docs/

### Community Resources
- **Discourse Forums**: https://discourse.llvm.org/
  - Best for questions and discussions
  - Active and helpful community
- **Discord Chat**: https://discord.gg/xS7Z362
  - Real-time chat
  - Quick questions
- **GitHub Issues**: https://github.com/llvm/llvm-project/issues
  - Bug reports
  - Feature requests
- **Office Hours**: https://llvm.org/docs/GettingInvolved.html#office-hours
  - Weekly video calls with maintainers

### Learning Resources
- **LLVM Blog**: https://blog.llvm.org/
- **Conference Talks**: Search for "LLVM Developers' Meeting" on YouTube
- **Tutorial Series**: Various online tutorials about LLVM IR and pass writing
- **Examples**: Check `llvm/examples/` directory in the repository

---

## Project-Specific Files

Other important files in the repository:

- **README.md**: Project overview (in root directory)
- **CONTRIBUTING.md**: How to contribute (in root directory)
- **CODE_OF_CONDUCT.md**: Community guidelines (in root directory)
- **LICENSE.TXT**: Apache 2.0 License with LLVM Exception

---

## Tips for Success

1. **Start Small**: Don't try to understand everything at once
2. **Read Code**: The best way to learn is by reading existing code
3. **Ask Questions**: The community is friendly and helpful
4. **Run Tests**: Always run tests before and after changes
5. **Follow Standards**: Use `clang-format` and follow coding conventions
6. **Be Patient**: LLVM is large; it takes time to become familiar
7. **Contribute Early**: Start contributing even while learning

---

## Document Organization

These guides are designed to complement each other:

```
NEW_DEVELOPER_GUIDE.md
    ├─> Comprehensive introduction
    ├─> Build instructions
    ├─> Development workflow
    └─> Contributing guide

QUICK_REFERENCE.md
    ├─> Command cheat sheet
    ├─> Common patterns
    └─> Quick lookups

ARCHITECTURE_GUIDE.md
    ├─> Internal structure
    ├─> Component details
    └─> Design patterns
```

Use them together:
- **Starting out**: Read the New Developer Guide
- **Day-to-day work**: Keep Quick Reference handy
- **Understanding code**: Consult Architecture Guide
- **Contributing**: Follow Contributing section in New Developer Guide

---

## Keeping Updated

LLVM is actively developed. To stay current:

- Follow the [LLVM Blog](https://blog.llvm.org/)
- Join [Discourse forums](https://discourse.llvm.org/)
- Watch the repository for important changes
- Attend LLVM Developers' Meetings (virtual options available)
- Read release notes for each LLVM version

---

## Contributing to These Docs

Found an issue or want to improve these guides?

1. These are community-maintained documents
2. Feel free to submit improvements
3. Follow the same process as code contributions
4. Keep the guides accurate and beginner-friendly

---

## Document Versions

These guides were created in November 2024 and reflect:
- LLVM 18+ build system and practices
- New Pass Manager (NPM) as default
- Modern CMake-based build
- Current GitHub-based workflow

If you're using an older version of LLVM, some details may differ.

---

## Need Help?

If you're stuck:

1. Check the relevant guide in this directory
2. Search the [Discourse forums](https://discourse.llvm.org/)
3. Ask in [Discord chat](https://discord.gg/xS7Z362)
4. Open an issue on GitHub (for bugs)
5. Attend office hours for direct help

Welcome to the LLVM community! Happy hacking! 🚀
