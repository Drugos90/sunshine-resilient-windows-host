# Security Policy

## Scope

This project documents an availability-focused configuration for a dedicated
Windows streaming host. Automatic sign-in and reduced UAC prompting intentionally
trade local security for unattended recovery. They are not appropriate for every
computer.

## Reporting a Problem

For a vulnerability in these scripts or instructions, use a private GitHub
security advisory after the repository is published. Do not include real
passwords, private keys, certificates, IP addresses, usernames, or Sunshine
configuration files.

Security problems in Sunshine, Moonlight, Tailscale, OpenSSH, or Windows should
be reported to their respective maintainers rather than this documentation
project.

## Explicit Non-Goals

This project does not protect an automatically signed-in desktop from an attacker
with physical access. It also does not guarantee recovery from hardware failure,
Windows boot failure, account lockout, or loss of Tailscale authorization.

