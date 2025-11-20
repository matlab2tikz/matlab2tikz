# matlab2tikz Development Roadmap

This document outlines the future development plans for matlab2tikz. It is intended to provide transparency about priorities and help coordinate community contributions.

## Vision

matlab2tikz aims to be the definitive tool for converting MATLAB/Octave figures to publication-quality LaTeX graphics, with excellent compatibility, maintainability, and ease of use.

## Current Status (v1.1.0)

- ✅ Comprehensive 2D and 3D plot support
- ✅ Support for MATLAB R2014a+ and Octave 4.0+
- ✅ Extensive test suite (100+ test cases)
- ✅ Active community of 40+ contributors
- ✅ Modern CI/CD infrastructure (as of 2024)

## Short Term Goals (Next 3-6 months)

### 1. Release v1.2.0
**Priority:** HIGH
**Status:** Planning

- [ ] Review and merge pending pull requests
- [ ] Address critical bug reports
- [ ] Update version number in source files
- [ ] Create comprehensive release notes
- [ ] Test on latest MATLAB and Octave versions
- [ ] Create release tag and publish

### 2. Code Quality Improvements
**Priority:** HIGH
**Status:** In Progress

- [x] Add EditorConfig for consistent formatting
- [x] Add GitHub Actions CI/CD
- [ ] Implement MATLAB linting (mlint/checkcode)
- [ ] Add pre-commit hooks
- [ ] Address trailing whitespace issues
- [ ] Standardize error messages

### 3. Documentation Enhancements
**Priority:** MEDIUM
**Status:** In Progress

- [x] Update README with modern badges and sections
- [x] Add CITATION.cff for academic use
- [ ] Create API documentation for main functions
- [ ] Add more examples to `test/examples/`
- [ ] Create video tutorials or animated guides
- [ ] Improve wiki with troubleshooting guides

## Medium Term Goals (6-12 months)

### 4. Code Refactoring
**Priority:** HIGH
**Status:** Planning

The main `matlab2tikz.m` file is over 7,000 lines. Refactor into modular components:

- [ ] Create separate files for plot type handlers
  - [ ] `handlers/handleLine.m`
  - [ ] `handlers/handleSurface.m`
  - [ ] `handlers/handleContour.m`
  - etc.
- [ ] Extract utility functions to `utils/` directory
- [ ] Create a proper object-oriented architecture
- [ ] Maintain backward compatibility with existing API
- [ ] Update tests to work with new structure

**Benefits:**
- Easier maintenance and debugging
- Simpler contributions for new features
- Better code organization
- Reduced cyclomatic complexity

### 5. Test Infrastructure Improvements
**Priority:** MEDIUM
**Status:** Planning

- [ ] Add code coverage reporting
- [ ] Integrate with Codecov or similar service
- [ ] Create more unit tests for individual functions
- [ ] Add performance benchmarks
- [ ] Implement visual regression testing
- [ ] Add testing on Windows and macOS (in addition to Linux)

### 6. Address Technical Debt
**Priority:** MEDIUM
**Status:** Planning

Systematically address TODO and FIXME comments:

- [ ] Create issues for each TODO/FIXME
- [ ] Categorize by priority and difficulty
- [ ] Assign to contributors
- [ ] Document decisions for items marked as "won't fix"

Current count: 50+ TODO/FIXME comments in codebase

### 7. Compatibility Updates
**Priority:** MEDIUM
**Status:** Planning

- [ ] Test and verify support for MATLAB R2024a+
- [ ] Test and verify support for Octave 8.0+
- [ ] Update minimum version requirements
- [ ] Add support for new MATLAB graphics features
- [ ] Improve HG2 (Handle Graphics 2) support

## Long Term Goals (1-2 years)

### 8. Enhanced Feature Support
**Priority:** MEDIUM
**Status:** Planned

- [ ] Support for MATLAB App Designer figures
- [ ] Better support for uifigure and web graphics
- [ ] Support for animated plots (convert to separate frames)
- [ ] Enhanced 3D plot capabilities
- [ ] Support for additional plot types:
  - [ ] Geographic plots (geoplot, geobubble, etc.)
  - [ ] Heatmaps and chart types from R2017b+
  - [ ] Parallel coordinate plots
  - [ ] Word clouds

### 9. Performance Improvements
**Priority:** LOW
**Status:** Ideas

- [ ] Optimize large dataset handling
- [ ] Implement caching for repeated conversions
- [ ] Parallelize independent operations
- [ ] Profile and optimize hot paths
- [ ] Add options for quality vs. speed trade-offs

### 10. User Experience Enhancements
**Priority:** MEDIUM
**Status:** Ideas

- [ ] Create a GUI for matlab2tikz
  - Live preview of LaTeX output
  - Interactive option selection
  - Batch conversion support
- [ ] Add MATLAB Live Editor integration
- [ ] Create standalone executable (using MATLAB Compiler)
- [ ] Add progress indicators for large conversions
- [ ] Improve error messages with suggestions

### 11. Ecosystem Integration
**Priority:** LOW
**Status:** Ideas

- [ ] Python bindings via MATLAB Engine API
- [ ] Julia integration via MATLAB.jl
- [ ] R integration via R-MATLAB interface
- [ ] VS Code extension
- [ ] Jupyter notebook magic command
- [ ] Overleaf integration or template

### 12. Advanced Features
**Priority:** LOW
**Status:** Ideas

- [ ] Plugin/extension architecture
  - Allow users to add custom plot type handlers
  - Community-contributed extensions
- [ ] Template system for common document types
- [ ] Style presets (journal-specific, thesis, etc.)
- [ ] Automatic figure optimization suggestions
- [ ] Integration with bibliography managers
- [ ] Support for multiple output formats (SVG, PDF via LaTeX)

## Community Goals

### Contributor Growth
- [ ] Create "good first issue" labels and documentation
- [ ] Organize virtual contributor meetings
- [ ] Create a contributor recognition system
- [ ] Improve onboarding documentation
- [ ] Create video guides for development setup

### Documentation
- [ ] Maintain up-to-date wiki
- [ ] Create comprehensive FAQ
- [ ] Add troubleshooting flowcharts
- [ ] Create comparison with alternatives
- [ ] Add performance benchmarks

### Outreach
- [ ] Present at MATLAB conferences
- [ ] Write blog posts and tutorials
- [ ] Create example gallery on website
- [ ] Engage with academic community
- [ ] Promote in LaTeX and scientific computing communities

## Decision Making

### Priority Levels
- **HIGH:** Critical for next release or addresses major bugs
- **MEDIUM:** Important improvements but not blocking
- **LOW:** Nice to have, longer term improvements

### Status Values
- **Planning:** Under discussion, not yet started
- **In Progress:** Actively being worked on
- **Completed:** Done and merged
- **On Hold:** Waiting for dependencies or decisions
- **Ideas:** Suggested but not yet prioritized

## Contributing to the Roadmap

We welcome community input on our roadmap! You can:

1. **Comment on existing items:**
   - Open an issue to discuss a roadmap item
   - Provide use cases or requirements
   - Volunteer to work on it

2. **Suggest new items:**
   - Create a feature request issue
   - Explain the use case and benefits
   - Estimate effort and complexity

3. **Help prioritize:**
   - Vote on issues (👍 reaction)
   - Share your use cases
   - Explain impact on your work

4. **Contribute code:**
   - Pick an item from the roadmap
   - Follow our [Contributing Guidelines](CONTRIBUTING.md)
   - Submit a pull request

## Version Planning

### Version 1.2.0 (Next Minor Release)
**Target:** Q1 2025
- Infrastructure improvements (GitHub Actions, etc.)
- Bug fixes from recent issues
- Documentation updates
- Compatibility verification with latest MATLAB/Octave

### Version 1.3.0
**Target:** Q3 2025
- Begin code refactoring
- Add new plot type support
- Enhanced error handling
- Performance improvements

### Version 2.0.0 (Major Release)
**Target:** 2026
- Complete code refactoring
- New architecture
- Breaking changes (if necessary)
- Significant feature additions
- Modern MATLAB/Octave features

## Maintenance Commitments

We aim to:
- Respond to issues within 1 week
- Review pull requests within 2 weeks
- Release bug fixes within 1 month of critical issues
- Release minor versions every 6-12 months
- Maintain compatibility with supported MATLAB/Octave versions

## Dependencies and Constraints

### External Dependencies
- MATLAB/Octave version changes
- Pgfplots/TikZ package updates
- LaTeX ecosystem changes
- GitHub Actions availability

### Resource Constraints
- Volunteer-driven development
- Limited maintainer availability
- Need for diverse testing environments
- Access to MATLAB licenses for testing

## Success Metrics

We measure success by:
- User satisfaction (stars, downloads, citations)
- Issue resolution time
- Test coverage percentage
- Number of supported plot types
- Community contributions
- Documentation completeness

## Long-Term Sustainability

To ensure long-term project health:
- Maintain clear documentation
- Keep code modular and testable
- Grow contributor base
- Establish succession planning
- Maintain financial sustainability (if needed)

## Questions or Feedback

Have thoughts on the roadmap?
- Open a discussion on GitHub Discussions
- Comment on related issues
- Join our community calls (when established)
- Reach out to maintainers

---

**Last Updated:** 2024-11-20

**Maintainers:** This roadmap should be reviewed and updated quarterly.
