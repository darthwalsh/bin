# Enabling GitHub Actions

This repository now includes a GitHub Actions workflow for automated testing on Linux.

## Workflow Configuration

The workflow is defined in `.github/workflows/test.yml` and includes:
- **Runs on**: Ubuntu (latest)
- **PowerShell Support**: Automatically installs PowerShell Core
- **Testing Framework**: Pester 5.x
- **Dependencies**: ripgrep (required by some scripts)

## Steps to Enable GitHub Actions

Since GitHub Actions workflows are automatically enabled when the `.github/workflows/` directory exists in your repository, the workflow should already be active once this PR is merged.

### Manual Steps (if needed):

1. **Check Actions tab**: 
   - Go to https://github.com/darthwalsh/bin/actions
   - You should see the "Tests" workflow listed

2. **Enable Actions (if disabled)**:
   - If you don't see the Actions tab, go to repository Settings
   - Click on "Actions" in the left sidebar
   - Under "Actions permissions", select "Allow all actions and reusable workflows"
   - Click "Save"

3. **Trigger a test run**:
   - The workflow runs automatically on:
     - Push to `main` or `master` branches
     - Pull requests to `main` or `master` branches
   - You can also manually trigger it:
     - Go to the Actions tab
     - Click on "Tests" workflow
     - Click "Run workflow" button
     - Select the branch and click "Run workflow"

## Workflow Triggers

The workflow is configured to run:
- On push to `main` or `master` branches
- On pull requests targeting `main` or `master` branches
- Manually via the GitHub Actions UI (workflow_dispatch)

## Viewing Test Results

1. Go to the Actions tab in your repository
2. Click on a workflow run to see details
3. Click on the "test" job to see the full test output
4. Test results will show as ✅ (passed) or ❌ (failed)

## Local Testing

Before pushing changes, you can run tests locally following the instructions in [tests/README.md](tests/README.md).

## Troubleshooting

If the workflow doesn't appear:
1. Ensure the `.github/workflows/test.yml` file is committed and pushed
2. Check that Actions are enabled in repository settings
3. Verify you have the necessary permissions (repo owner/admin can always enable Actions)

If tests fail in CI but pass locally:
1. Check the workflow logs for specific error messages
2. Ensure all dependencies are installed in the workflow
3. Verify PATH and environment variables are set correctly
