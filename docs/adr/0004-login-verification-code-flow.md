# ADR 0004: Login Verification Code Flow for quzzes

- Status: Accepted
- Date: 2026-04-11
- Deciders: Quiz App Team

## Context

The new business requirement states that when a user attempts to log in to *quzzes*, we must:

1. Display the message: “quzzesアカウントの安全性を確保するために、IDを確認する必要があります。確認コードを送信してください。”
2. Trigger a verification flow that sends a confirmation code to the user.

Drivers:
- Strengthen account takeover prevention before granting access to quiz authoring / management surfaces.
- Offer a consistent UX across web and mobile clients when additional verification is required.
- Keep the behavior explicit in project documentation so future changes to authentication respect this flow.

## Decision

We will:

1. Introduce an intermediate verification step in the authentication UI (web + mobile).
   - When login is initiated, the UI shows the mandated message and offers a “Send verification code” action.
2. Extend the authentication API (or stub) to send / simulate a confirmation code.
3. Require successful code confirmation before issuing session tokens.
4. Document the wording and flow inside `quiz.md` (requirements) and implementation specs.

## Consequences

### Positive

- Users always see a clear explanation before extra verification, reducing confusion.
- Security posture improves by defaulting to ID confirmation.
- The message and flow are standardized, easing QA and localization.

### Negative

- Adds another step to the login UX, which may feel slower for trusted devices.
- Requires API and UI work across multiple clients (web, mobile, admin).
- Test automation must handle the new verification step.

## Alternatives Considered

1. Silent verification without user messaging  
   - Rejected: violates the new requirement and risks confusing users when codes arrive unexpectedly.

2. Limiting the flow to admin-web only  
   - Rejected: the requirement explicitly targets “quzzes” accounts generally, so all clients must align.

## Notes

- Implementation tasks include updating the auth context/hooks, mobile Flutter auth screens, and backend stubs.
- The verification code transport (email/SMS) is determined by environment configuration and can be mocked locally.
