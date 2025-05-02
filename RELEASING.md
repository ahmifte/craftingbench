<div align="center">

# 📦 Release Process

**Guide for maintaining and releasing CraftingBench**

[![Version](https://img.shields.io/badge/Version-0.2.0%20(Beta)-orange.svg)](../CHANGELOG.md)

</div>

______________________________________________________________________

## 📋 Release Checklist

Before creating a new release, ensure the following steps are completed:

1. ✅ **Update version information in:**
   - `package.json`
   - `USER_GUIDE.md`
   - `architecture.md`
   - `CHANGELOG.md`
   - Template documentation
   - Version badge in all markdown files

2. ✅ **Update the CHANGELOG.md** with:
   - New features
   - Bug fixes
   - Breaking changes
   - Deprecated functionality

3. ✅ **Audit the TypeScript codebase:**
   - Run linting checks: `pnpm lint`
   - Fix any identified issues
   - Ensure type safety across all components

4. ✅ **Test all templates:**
   - Generate test projects for each template
   - Verify that all dependencies are correctly installed
   - Validate that TypeScript compilation works
   - Ensure each template runs as expected

5. ✅ **Update documentation:**
   - Ensure all template documentation is current
   - Update the architecture document if necessary
   - Review and update the user guide

## 🚀 Creating a Release

CraftingBench uses GitHub Releases for distribution:

1. **Create a tag** for the new version:
   ```bash
   git tag v0.X.Y
   git push origin v0.X.Y
   ```

2. **Create a new release** on GitHub:
   - Navigate to the Releases page
   - Create a new release using the tag
   - Copy the changelog entry for this version into the release notes
   - Mark as pre-release if not a stable version

3. **Verify the GitHub Actions workflow** completes successfully:
   - The workflow will automatically:
     - Build the release artifacts
     - Attach them to the GitHub release
     - Update the release notes

## 📢 Announcing the Release

Once the release is created and verified:

1. **Update the installation instructions** if necessary
2. **Notify users** through appropriate channels

## 🔖 Version Numbering

CraftingBench follows [Semantic Versioning](https://semver.org/):

- **Major version (0.x.0)**: Breaking changes
- **Minor version (0.0.x)**: New features, non-breaking
- **Patch version (0.0.0)**: Bug fixes, no new features

> **Note**: While in beta (0.x.y), minor version increases may include breaking changes.

## 🧪 Testing Releases

To test a release before publishing:

1. Create a temporary branch
2. Update version numbers
3. Run through the entire release checklist
4. Create a local installation for testing
5. Verify all templates and functionality work as expected 