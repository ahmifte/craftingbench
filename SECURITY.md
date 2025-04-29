# Security Policy

## Current Release Status

**⚠️ CraftingBench is currently in BETA (v0.2.0)**

CraftingBench is currently in active development and has not reached a stable 1.0.0 release. While we strive to ensure the security and reliability of the codebase, beta versions may contain bugs or security issues that have not yet been identified or addressed.

Users should be aware that:
- APIs and interfaces may change between releases
- Breaking changes may be introduced without major version increments
- Security features are still being developed and improved

## Supported Versions

| Version | Supported          | Status      |
| ------- | ------------------ | ----------- |
| 0.2.x   | :white_check_mark: | Active Beta |
| 0.1.x   | :x:                | Deprecated  |

We currently only support the latest release (0.2.x). We strongly recommend using the most recent release available via GitHub Releases.

## GitHub Releases

CraftingBench releases are managed through GitHub Releases. Each release is tagged and includes:

1. A detailed changelog
2. An installation tarball
3. Installation instructions

To install the latest release, you can use our installation script:

```bash
curl -fsSL https://raw.githubusercontent.com/ahmifte/craftingbench/v0.2.0/install.sh | bash
```

For security reasons, we recommend:
- Verifying the integrity of downloaded files
- Reviewing the installation script before execution
- Only using official releases from the GitHub repository

## Reporting a Vulnerability

If you discover a security vulnerability in CraftingBench, please report it by following these steps:

1. **DO NOT** disclose the vulnerability publicly
2. **DO NOT** create a public GitHub issue
3. Email your findings to the project maintainer at [security@example.com](mailto:security@example.com) with:
   - A description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if available)

The maintainers will acknowledge receipt of your vulnerability report as soon as possible and will provide regular updates about the progress towards remediation.

## Security Best Practices

When using CraftingBench to generate project templates:

1. **Review Generated Code**: Always review templates after generation
2. **Verify Dependencies**: Check that dependencies introduced by templates are up-to-date and secure
3. **Limit Shell Access**: Be cautious about executing shell commands from templates
4. **Keep Updated**: Always use the latest release to benefit from security improvements

## Future Security Improvements

As we approach a stable release, we plan to implement additional security measures:

- Code signing for releases
- SHA256 checksums for release files
- Dependency vulnerability scanning
- Improved sandboxing for template execution

## Disclaimer

CraftingBench is provided "as is" without warranty of any kind. Use at your own risk. The authors assume no liability for damages resulting from the use of this software. 