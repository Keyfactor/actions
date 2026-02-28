# Signoff Notification Workflow

Sends email notifications when a PR is labeled "ready for signoff" and optionally syncs the tag to Azure DevOps work items.

## Features

- Sends HTML email to configured recipients when PR is labeled
- Extracts Azure DevOps work item number from branch name (e.g., `ab#1234-feature`)
- Includes links to:
  - PR approval page
  - PR conversation
  - Azure DevOps work item
- Optionally tags Azure DevOps work item with "Ready for Signoff"
- Adds comment to DevOps item with PR link

## Branch Naming Convention

The workflow extracts Azure DevOps work item numbers from branch names using the `ab#<number>` pattern:

| Branch Name | DevOps Item |
|-------------|-------------|
| `ab#1234` | 1234 |
| `ab#1234-feature-name` | 1234 |
| `feature-ab#1234` | 1234 |
| `AB#1234-fix` | 1234 |
| `feature-branch` | None |

## Usage

### As a Standalone Workflow

The workflow triggers automatically when a PR is labeled with "ready for signoff":

```yaml
# In your repository's .github/workflows/ci.yml
name: CI
on:
  pull_request:
    types: [labeled]

jobs:
  signoff-notification:
    if: github.event.label.name == 'ready for signoff'
    uses: Keyfactor/actions/.github/workflows/signoff-notification.yml@v6
    secrets:
      token: ${{ secrets.GITHUB_TOKEN }}
      smtp_server: ${{ secrets.SMTP_SERVER }}
      smtp_username: ${{ secrets.SMTP_USERNAME }}
      smtp_password: ${{ secrets.SMTP_PASSWORD }}
      email_from: ${{ secrets.EMAIL_FROM }}
      azure_devops_token: ${{ secrets.AZURE_DEVOPS_PAT }}
```

### Calling from Another Workflow

```yaml
jobs:
  notify:
    uses: Keyfactor/actions/.github/workflows/signoff-notification.yml@v6
    with:
      recipients: 'team@example.com,lead@example.com'
      devops_org: 'Keyfactor'
      devops_project: 'Integration'
      devops_tag: 'Ready for Signoff'
      sync_devops_tag: true
    secrets:
      token: ${{ secrets.GITHUB_TOKEN }}
      smtp_server: ${{ secrets.SMTP_SERVER }}
      smtp_username: ${{ secrets.SMTP_USERNAME }}
      smtp_password: ${{ secrets.SMTP_PASSWORD }}
      email_from: 'ci@keyfactor.com'
      azure_devops_token: ${{ secrets.AZURE_DEVOPS_PAT }}
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `recipients` | Comma-separated email addresses | No | `${{ vars.SIGNOFF_RECIPIENTS }}` |
| `devops_org_url` | Azure DevOps URL for work item links | No | `https://dev.azure.com/Keyfactor/Integration/_workitems/edit` |
| `devops_org` | Azure DevOps organization name | No | `Keyfactor` |
| `devops_project` | Azure DevOps project name | No | `Integration` |
| `devops_tag` | Tag to apply to work item | No | `Ready for Signoff` |
| `sync_devops_tag` | Whether to tag the DevOps item | No | `true` |

## Secrets

| Secret | Description | Required |
|--------|-------------|----------|
| `token` | GitHub token | Yes |
| `smtp_server` | SMTP server hostname | Yes |
| `smtp_port` | SMTP server port | No (default: 587) |
| `smtp_username` | SMTP authentication username | Yes |
| `smtp_password` | SMTP authentication password | Yes |
| `email_from` | Sender email address | Yes |
| `azure_devops_token` | Azure DevOps PAT | No (required for tag sync) |

## Repository Variables

| Variable | Description |
|----------|-------------|
| `SIGNOFF_RECIPIENTS` | Default email recipients (comma-separated) |

## Azure DevOps PAT Permissions

The Azure DevOps Personal Access Token needs these scopes:
- **Work Items**: Read & Write

## Email Template

The email includes:
- PR number and title
- Author and branch information
- Change statistics (files, additions, deletions)
- Quick Links table:
  - **PR**: Link to pull request
  - **RC**: Link to latest pre-release/release candidate
  - **WB**: Link to working (source) branch
  - **ChangeLog**: Link to CHANGELOG.md on source branch
- Action buttons:
  - Review & Approve (links to GitHub review)
  - View PR
  - DevOps Item (if applicable)

## Azure DevOps Comment

When tagging a DevOps work item, the workflow also adds a comment with:

```
🔔 GitHub PR Ready for Signoff

PR: #123 - Add new feature
RC: v1.2.0-rc.3
WB: ab#456-add-feature
ChangeLog: CHANGELOG.md
```

All items are hyperlinked to their respective URLs.

## Example Email

```
Subject: [Signoff Required] PR #123: Add new feature

🔔 PR Ready for Signoff
───────────────────────
Pull Request #123
Add new feature

Author: @developer
Branch: ab#456-add-feature → release-1.2
Repository: Keyfactor/my-integration

Changes: 5 files, +120, -45

Quick Links:
┌───────────┬──────────────────────────────────┐
│ PR        │ #123 - Add new feature           │
│ RC        │ v1.2.0-rc.3                      │
│ WB        │ ab#456-add-feature               │
│ ChangeLog │ CHANGELOG.md                     │
└───────────┴──────────────────────────────────┘

[✅ Review & Approve] [👁️ View PR] [📋 DevOps Item #456]
```
