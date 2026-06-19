# Publishing and Community Contribution Guide

This file describes how to publish the project without exposing private system
information and how to collect feedback before proposing it as official Sunshine
documentation.

## 1. Perform the Privacy Review

Before uploading anything, search every file for:

- your real Windows username
- computer and domain names
- Microsoft account email addresses
- public, LAN, and Tailscale IP addresses
- tailnet and device names
- passwords, PINs, API keys, and SSH private keys
- Sunshine certificates and `sunshine_state.json`
- screenshots containing account or network details

Only the files in this package should be published. Never upload your live
`C:\Sunshine\config` directory, logs, PID files, Startup shortcut, or registry
exports.

## 2. Test the Public Scripts Separately

The scripts use their own directory as the Sunshine installation directory. On a
test copy of the installation:

1. Place all three scripts beside `sunshine.exe`.
2. Launch `sunshine-watchdog.vbs`.
3. Launch it again and verify only one watchdog remains.
4. Stop Sunshine and verify it returns within about 15 seconds.
5. Run `stop-watchdog.ps1` and verify only the watchdog stops.
6. Review `watchdog.log`.
7. Reboot and complete the checklist in the README.

## 3. Create the GitHub Repository

The simplest method does not require Git to be installed:

1. Sign in at https://github.com/.
2. Select **New repository**.
3. Suggested name: `sunshine-resilient-windows-host`.
4. Description: `A resilient Windows Sunshine host with silent crash recovery, Tailscale, SSH, and unattended reboot recovery.`
5. Choose **Public**.
6. Do not initialize another README or license because this package includes them.
7. Create the repository.
8. Select **uploading an existing file**.
9. Drag the contents of this folder into the upload page, including `scripts`.
10. Use the commit message `Initial community guide` and commit to `main`.

Open the public repository in a private browser window and repeat the privacy
review on what GitHub actually displays.

## 4. Create the First Release

After another person has tested the guide:

1. Open the repository's **Releases** page.
2. Select **Draft a new release**.
3. Create tag `v1.0.0`.
4. Title it `Initial tested Windows guide`.
5. State the tested Windows and Sunshine versions.
6. List known limitations, especially autologin and UAC tradeoffs.
7. Publish the release.

Do not attach live configuration archives or credentials.

## 5. Request Community Review

Start with places where the setup is directly relevant:

1. LizardByte organization discussions: https://github.com/orgs/LizardByte/discussions
2. LizardByte Discord: https://app.lizardbyte.dev/discord/
3. Moonlight Streaming subreddit: https://www.reddit.com/r/MoonlightStreaming/

Suggested post title:

```text
Community guide: resilient unattended Sunshine host on Windows with Tailscale and SSH recovery
```

Suggested post body:

```text
I documented a Windows Sunshine host configuration designed to recover after a
reboot or Sunshine process crash. It combines automatic desktop sign-in, a
silent single-instance watchdog, bounded logs, Tailscale connectivity, OpenSSH
recovery, and remote reboot verification.

The guide explicitly documents the local-security tradeoffs of autologin and the
tested UAC policy. It contains no personal configuration or credentials.

I am looking for review on Windows versions, Microsoft versus local accounts,
OpenSSH firewall behavior, update survival, and failure cases.

Repository: <GITHUB_REPOSITORY_URL>
```

Ask reviewers to open GitHub issues rather than exchanging modified scripts in
comments. This keeps fixes visible and reviewable.

## 6. Record Tested Environments

Add a table to the README after receiving reports:

```text
| Windows | Account | GPU | Sunshine | Result | Notes |
|---------|---------|-----|----------|--------|-------|
```

Do not list tester IP addresses, usernames, computer names, or email addresses.

## 7. Propose Upstream Documentation

After multiple independent tests:

1. Read LizardByte's current contribution instructions:
   https://github.com/LizardByte/.github/blob/master/CONTRIBUTING.md
2. Search existing Sunshine issues and pull requests for a Windows resilient-host guide.
3. Open a LizardByte organization discussion first and link the community repository.
4. Ask maintainers whether they prefer an external community-guide link or a documentation pull request.
5. If invited, fork `LizardByte/Sunshine`, place the guide where maintainers specify, and open a focused pull request.
6. Keep the watchdog scripts in the community repository unless maintainers explicitly want them upstream.

Do not represent the guide as official Sunshine documentation until the
maintainers merge or formally link it.

## 8. Maintain It

- Test after important Sunshine and Windows releases.
- Use GitHub issues for defects and compatibility reports.
- Update commands only after reproducing them.
- Keep a changelog of security-impacting changes.
- Preserve the threat-model warning even if users request its removal.
- Never accept credentials, private keys, or configuration archives in issues.
