# Repository Upgrades - 2024

This document describes the comprehensive upgrades made to the matlab2tikz repository to modernize its infrastructure and improve maintainability.

## Overview

The matlab2tikz repository has been significantly upgraded with modern development practices, improved documentation, and enhanced CI/CD infrastructure. These changes bring the project in line with current best practices for open-source software development.

## Major Improvements

### 1. Modern CI/CD Infrastructure

#### GitHub Actions Workflows
**Replaced:** Outdated Travis CI configuration
**Added:** Three comprehensive GitHub Actions workflows

- **`test.yml`** - Automated testing workflow
  - Tests on multiple Octave versions (6.4.0, 7.3.0, 8.4.0)
  - Tests on latest MATLAB version (R2023b)
  - Automated code quality checks
  - Test result artifacts with 30-day retention
  - Runs on pushes to master, develop, and claude/** branches
  - Runs on pull requests

- **`release.yml`** - Automated release workflow
  - Triggered by version tags (v*.*.*)
  - Automatic creation of release archives
  - GitHub Release creation with changelog extraction
  - Release artifact management

- **`dependabot.yml`** - Dependency management
  - Automatic updates for GitHub Actions
  - Monthly schedule
  - Proper labeling and commit messages

**Benefits:**
- Faster, more reliable testing
- Support for multiple MATLAB/Octave versions
- Automated release process
- Better visibility of test results
- Native GitHub integration

### 2. Enhanced GitHub Templates

#### Issue Templates
Created structured issue templates using GitHub's YAML format:

- **`bug_report.yml`** - Comprehensive bug reporting
  - Required prerequisites checklist
  - Structured fields for reproduction steps
  - Version information collection
  - Environment details
  - Clear validation requirements

- **`feature_request.yml`** - Structured feature requests
  - Problem statement and use case
  - Proposed solution description
  - Alternative solutions
  - Pgfplots/TikZ reference integration
  - Examples and context

- **`config.yml`** - Template configuration
  - Links to discussions for questions
  - Reference to wiki for common problems
  - Link to Pgfplots bug tracker for upstream issues

**Benefits:**
- More consistent and complete issue reports
- Faster triage and resolution
- Better user guidance
- Reduced back-and-forth communication

#### Pull Request Template
Created comprehensive PR template:

- Change type categorization
- Related issue linking
- Testing checklist
- Environment information
- Review checklist for maintainers
- Breaking change documentation

**Benefits:**
- More thorough pull request descriptions
- Better testing documentation
- Clearer review process
- Reduced integration issues

### 3. Code Quality Infrastructure

#### EditorConfig (`.editorconfig`)
Added editor configuration for consistent coding style:

- UTF-8 encoding standard
- LF line endings
- Trailing whitespace removal
- Consistent indentation (4 spaces for MATLAB)
- Maximum line lengths
- File-type-specific settings

#### Git Attributes (`.gitattributes`)
Added comprehensive Git attributes:

- Automatic text file detection
- Line ending normalization
- Binary file handling for MATLAB formats
- Export exclusion for development files
- Proper handling of LaTeX files

**Benefits:**
- Consistent code formatting across editors
- Proper line ending handling across platforms
- Cleaner diffs and merges
- Smaller distribution archives

### 4. Community and Governance

#### Code of Conduct (`CODE_OF_CONDUCT.md`)
Added Contributor Covenant Code of Conduct 2.0:

- Clear community standards
- Enforcement guidelines
- Reporting mechanisms
- Community impact guidelines

#### Security Policy (`SECURITY.md`)
Added comprehensive security policy:

- Supported versions table
- Vulnerability reporting process
- Response timeline commitments
- Security best practices
- Known security considerations

**Benefits:**
- Healthier community environment
- Clear expectations for behavior
- Transparent security handling
- Better trust and adoption

### 5. Academic Integration

#### Citation File (`CITATION.cff`)
Added CFF (Citation File Format) file:

- Structured citation information
- GitHub integration for easy citation
- BibTeX export support
- Zenodo DOI integration
- Author attribution
- Related software references

**Benefits:**
- Easier academic citation
- Better research visibility
- Proper attribution
- Integration with citation managers

### 6. Documentation Improvements

#### README Updates
Enhanced the README.md with:

- Updated CI badges (GitHub Actions instead of Travis)
- License badge
- Clearer version requirements
- Separated requirements section
- Contributing guidelines section
- Citation information
- Security policy reference
- License information

**Benefits:**
- Better first impression
- Clearer requirements
- More discoverable information
- Professional appearance

## File Changes Summary

### New Files Added
```
.github/
├── workflows/
│   ├── test.yml              # Automated testing
│   ├── release.yml           # Automated releases
│   └── dependabot.yml        # Dependency management
├── ISSUE_TEMPLATE/
│   ├── bug_report.yml        # Bug report template
│   ├── feature_request.yml   # Feature request template
│   └── config.yml            # Template configuration
└── PULL_REQUEST_TEMPLATE.md  # PR template

.editorconfig                  # Editor configuration
.gitattributes                 # Git attributes
CODE_OF_CONDUCT.md             # Code of conduct
SECURITY.md                    # Security policy
CITATION.cff                   # Citation information
UPGRADE_2024.md               # This file
```

### Modified Files
```
README.md                      # Enhanced with new sections
```

### Deprecated Files (Not Removed)
```
.travis.yml                    # Kept for historical reference
```

## Migration Guide

### For Users
No action required. All changes are backward compatible and improve the user experience.

### For Contributors

1. **Issue Reporting**
   - Use the new issue templates when reporting bugs or requesting features
   - Fill out all required fields for faster resolution

2. **Pull Requests**
   - Use the PR template to structure your contributions
   - Run tests locally before submitting
   - Follow the checklist in the template

3. **Code Style**
   - Install an EditorConfig plugin for your editor
   - Your editor will automatically use the correct formatting

4. **Security**
   - Report security issues through GitHub Security Advisories
   - Do not create public issues for vulnerabilities

### For Maintainers

1. **CI/CD**
   - GitHub Actions will automatically run on new PRs
   - Check the Actions tab for test results
   - Release workflow triggers on version tags

2. **Dependencies**
   - Dependabot will create PRs for GitHub Actions updates
   - Review and merge monthly dependency updates

3. **Issue Management**
   - Use the "needs-triage" label for new issues
   - Structured templates make triage easier

4. **Releases**
   - Create a tag like `v1.2.0` to trigger automated release
   - Release notes are extracted from CHANGELOG.md

## Technical Details

### GitHub Actions Environments

#### Test Workflow
- **Runners:** ubuntu-latest
- **MATLAB Version:** R2023b
- **Octave Versions:** 6.4.0, 7.3.0, 8.4.0
- **Timeout:** Default (360 minutes)
- **Artifacts:** Test results retained for 30 days

#### Release Workflow
- **Trigger:** Git tags matching `v*.*.*`
- **Permissions:** `contents: write` for creating releases
- **Artifacts:** Release packages retained for 90 days

### Code Quality Checks

The lint job in `test.yml` performs:
1. Trailing whitespace detection
2. File encoding verification
3. TODO/FIXME comment reporting

These checks run on every push and PR.

## Future Improvements

While this upgrade significantly modernizes the repository, there are additional improvements that could be made in the future:

### Short Term
1. Add more example files in `test/examples/`
2. Create a pre-commit hooks configuration
3. Add code coverage reporting
4. Implement automated MATLAB linting

### Medium Term
1. Refactor `matlab2tikz.m` into multiple modules
2. Address TODO and FIXME comments systematically
3. Update minimum MATLAB/Octave versions
4. Add more comprehensive integration tests

### Long Term
1. Create a graphical user interface
2. Add support for newer MATLAB graphics features
3. Implement plugin architecture for extensibility
4. Consider Julia/Python bindings

## Compatibility

All improvements are backward compatible:

- **MATLAB/Octave:** No changes to minimum requirements
- **LaTeX:** No changes to package requirements
- **Git:** All new files use standard formats
- **Existing Workflows:** No breaking changes to existing scripts or usage

## Testing

These upgrades have been designed with the following testing considerations:

1. **Automated Testing:** GitHub Actions workflows test on multiple environments
2. **Backward Compatibility:** No breaking changes to user-facing functionality
3. **Documentation:** All new features are documented
4. **Best Practices:** Following GitHub and open-source community standards

## Questions and Feedback

If you have questions about these upgrades:

1. Check this document first
2. Review the new documentation files
3. Create a discussion in the GitHub Discussions area
4. Open an issue using the appropriate template

## Credits

These upgrades were implemented to bring matlab2tikz in line with modern open-source best practices and to ensure the project's continued success and maintainability.

## Version History

- **2024-11-20:** Initial comprehensive upgrade
  - GitHub Actions CI/CD
  - Issue and PR templates
  - Code quality infrastructure
  - Community and governance files
  - Academic integration (CITATION.cff)
  - Documentation improvements

---

*This document will be updated as additional improvements are made to the repository.*
