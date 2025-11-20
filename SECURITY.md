# Security Policy

## Supported Versions

We actively maintain and provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.1.x   | :white_check_mark: |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in matlab2tikz, please report it responsibly:

### How to Report

1. **Do NOT** open a public issue for security vulnerabilities
2. Send a detailed report to the maintainers via:
   - GitHub Security Advisories: https://github.com/matlab2tikz/matlab2tikz/security/advisories/new
   - Or create a private issue in the repository

### What to Include

Please include the following information in your report:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact of the vulnerability
- Any suggested fixes (if applicable)
- Your contact information for follow-up

### Response Timeline

- **Initial Response**: We aim to respond within 48 hours
- **Status Update**: We will provide status updates every 5-7 days
- **Fix Timeline**: We aim to release a fix within 30 days for critical issues

### Disclosure Policy

- We request that you do not publicly disclose the vulnerability until we have released a fix
- Once a fix is released, we will credit you in the release notes (unless you prefer to remain anonymous)
- We will coordinate with you on the disclosure timeline

## Security Best Practices

When using matlab2tikz:

1. **Keep Updated**: Always use the latest version of matlab2tikz
2. **Validate Input**: Be cautious when converting figures from untrusted sources
3. **LaTeX Security**: Be aware of LaTeX security considerations when compiling generated files
4. **File Permissions**: Ensure appropriate file permissions when saving output files
5. **Code Execution**: Review any custom code or options before execution

## Known Security Considerations

### LaTeX Injection

matlab2tikz generates LaTeX code. Be aware that:

- Malicious MATLAB figures could potentially inject harmful LaTeX commands
- Always review generated `.tex` files before compiling if from untrusted sources
- Use LaTeX in restricted mode when compiling untrusted documents

### File System Access

matlab2tikz writes files to disk:

- Ensure you have proper permissions for the output directory
- Be cautious about overwriting existing files
- Validate file paths to prevent directory traversal attacks

### Code Execution

matlab2tikz executes MATLAB/Octave code:

- Only run matlab2tikz on trusted figures
- Review any custom callbacks or user-defined functions in figures
- Be cautious when using the `externalData` option with untrusted sources

## Acknowledgments

We appreciate the security research community's efforts in responsibly disclosing vulnerabilities. Contributors who report valid security issues will be acknowledged in our security advisories and release notes.

## Questions

If you have questions about this security policy, please open a regular (non-security) issue in our repository.
