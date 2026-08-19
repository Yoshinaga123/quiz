import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import {
  clearMemberSession,
  loadMemberSession,
  saveMemberSession,
  type MemberSession,
} from '../lib/memberSession';

interface MemberSessionContextValue {
  session: MemberSession | null;
  setSession: (session: MemberSession) => void;
  clearSession: () => void;
}

const MemberSessionContext = createContext<MemberSessionContextValue | null>(null);

export function MemberSessionProvider({ children }: { children: ReactNode }) {
  const [session, setSessionState] = useState<MemberSession | null>(() => loadMemberSession());

  useEffect(() => {
    if (session === null) {
      clearMemberSession();
    } else {
      saveMemberSession(session);
    }
  }, [session]);

  const setSession = useCallback((next: MemberSession) => {
    setSessionState(next);
  }, []);

  const clearSession = useCallback(() => {
    setSessionState(null);
  }, []);

  const value = useMemo<MemberSessionContextValue>(
    () => ({ session, setSession, clearSession }),
    [session, setSession, clearSession],
  );

  return <MemberSessionContext.Provider value={value}>{children}</MemberSessionContext.Provider>;
}

export function useMemberSession(): MemberSessionContextValue {
  const value = useContext(MemberSessionContext);
  if (value === null) {
    throw new Error('useMemberSession must be used within <MemberSessionProvider>');
  }
  return value;
}
