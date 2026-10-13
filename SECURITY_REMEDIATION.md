# Credential remediation — 13 October 2026

Configure AI_PROXY_URL to an authenticated, rate-limited backend that stores OPENROUTER_API_KEY server-side and accepts the existing chat-completions request format. AI_PROXY_URL is public non-secret configuration. No shared provider key belongs in Flutter source, assets, or dart-define. Text uses the existing local fallback until a proxy is configured; online image inspection is unavailable.

## Required owner actions

- Revoke/rotate all previously exposed provider credentials; removing source does not revoke them.
- Review provider usage, billing, account and database access logs.
- Coordinate cleanup of affected branches/tags/history. Old commits, cached views, clones, forks, releases and deployed bundles may retain credential material.
- Redeploy/rebuild affected applications after configuring rotated server-side secrets. Never restore old credentials to source.
- Use dummy test fixtures and secret scanning/push protection. Base64 or splitting a credential is not protection.

No credential values are recorded in this document. Git history has not been rewritten by this source-cleanup commit.
