import { act } from 'react';
import { createRoot } from 'react-dom/client';
import { MemoryRouter } from 'react-router-dom';
import { afterEach, beforeAll, describe, expect, it } from 'vitest';

import SignInNudge from '../../src/components/SignInNudge';
import { MemberSessionProvider } from '../../src/contexts/MemberSessionContext';
import { saveMemberSession } from '../../src/lib/memberSession';

// Opt into React 19's act warnings environment so createRoot renders quietly.
beforeAll(() => {
  (globalThis as unknown as { IS_REACT_ACT_ENVIRONMENT: boolean }).IS_REACT_ACT_ENVIRONMENT = true;
});

let container: HTMLDivElement | null = null;

afterEach(() => {
  if (container !== null) {
    document.body.removeChild(container);
    container = null;
  }
});

const mount = (): HTMLDivElement => {
  container = document.createElement('div');
  document.body.appendChild(container);
  const root = createRoot(container);
  act(() => {
    root.render(
      <MemoryRouter>
        <MemberSessionProvider>
          <SignInNudge />
        </MemberSessionProvider>
      </MemoryRouter>,
    );
  });
  return container;
};

describe('SignInNudge', () => {
  it('renders sign-in and register links when logged out', () => {
    const el = mount();
    const nudge = el.querySelector('[data-testid="sign-in-nudge"]');
    expect(nudge).not.toBeNull();
    const anchors = Array.from(el.querySelectorAll('a')).map((a) => a.getAttribute('href'));
    expect(anchors).toContain('/login');
    expect(anchors).toContain('/register');
  });

  it('renders nothing when a session is present in localStorage', () => {
    saveMemberSession({
      memberId: '0192b6f7-4c50-73b1-8b71-11223344aabb',
      handle: 'quiztaker_01',
      token: 'jwt.token',
    });

    const el = mount();
    expect(el.querySelector('[data-testid="sign-in-nudge"]')).toBeNull();
  });
});
