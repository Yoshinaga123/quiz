import { afterAll, beforeAll } from "vitest";

const methods = ["log", "info", "warn", "error", "debug"] as const;

const original: Record<(typeof methods)[number], (...args: unknown[]) => void> = {
  log: console.log.bind(console),
  info: console.info.bind(console),
  warn: console.warn.bind(console),
  error: console.error.bind(console),
  debug: console.debug.bind(console),
};

function thrower(method: (typeof methods)[number]) {
  return (...args: unknown[]) => {
    throw new Error(`Unexpected console.${method} call: ${args.join(" ")}`);
  };
}

beforeAll(() => {
  for (const method of methods) {
    console[method] = thrower(method);
  }
});

afterAll(() => {
  for (const method of methods) {
    console[method] = original[method];
  }
});
