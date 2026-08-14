// gk-managed:{"events":["permission.asked","permission.replied","session.compacted","session.created","session.deleted","session.error","session.idle","session.status","session.updated","tool.execute.after","tool.execute.before"],"executable":"/Users/caongoccuong/Library/Application Support/GitKrakenCLI/gk"}
import { spawn } from "node:child_process";

const EVENTS = new Set(["permission.asked","permission.replied","session.compacted","session.created","session.deleted","session.error","session.idle","session.status","session.updated","tool.execute.after","tool.execute.before"]);
const EXECUTABLE = "/Users/caongoccuong/Library/Application Support/GitKrakenCLI/gk";
const MAX_HOOK_INPUT_BYTES = 1024 * 1024;

function getString(value) {
  return typeof value === "string" && value.length > 0 ? value : "";
}

function extractSessionID(event) {
  return (
    getString(event?.properties?.info?.id) ||
    getString(event?.properties?.sessionID) ||
    getString(event?.properties?.sessionId) ||
    getString(event?.properties?.session_id) ||
    getString(event?.properties?.id) ||
    getString(event?.sessionID) ||
    getString(event?.sessionId) ||
    getString(event?.session_id) ||
    getString(event?.id)
  );
}

function extractToolName(payload) {
  return (
    getString(payload?.input?.tool) ||
    getString(payload?.event?.properties?.part?.tool) ||
    getString(payload?.event?.properties?.tool) ||
    ""
  );
}

function buildHookInput(eventName, sessionID, cwd, payload) {
  const toolName = extractToolName(payload);
  const hookInput = {
    hook_event_name: eventName,
    session_id: sessionID || "",
    cwd,
    tool_name: toolName || null,
    source: null,
    model: null,
    reason: null,
    agent_id: null,
    agent_type: null,
    hook_payload: payload || null,
  };

  const serializedInput = JSON.stringify(hookInput);
  const payloadBytes = Buffer.byteLength(serializedInput, "utf8");
  if (payloadBytes <= MAX_HOOK_INPUT_BYTES) {
    return serializedInput;
  }

  return JSON.stringify({
    ...hookInput,
    hook_payload: { truncated: true, originalBytes: payloadBytes },
  });
}

function runHook(eventName, sessionID, cwd, payload) {
  if (!EVENTS.has(eventName)) return;
  try {
    const input = buildHookInput(eventName, sessionID, cwd, payload);
    const child = spawn(EXECUTABLE, ["ai", "hook", "run", "--host", "opencode"], {
      stdio: ["pipe", "ignore", "ignore"],
      windowsHide: true,
    });
    child.on("error", () => {});
    child.stdin.on("error", () => {});
    child.stdin.end(input);
    child.unref();
  } catch (_) {
    // Hooks must never block OpenCode
  }
}

export const server = async (ctx) => {
  const cwd = ctx.directory || ctx.worktree || process.cwd();
  const hooks = {};

  // General event hook — forwards native dot names as-is.
  hooks.event = async ({ event }) => {
    const type = event?.type ?? "";
    if (type === "tool.execute.before" || type === "tool.execute.after") return;
    const sessionID = extractSessionID(event);
    runHook(type, sessionID, cwd, { event });
  };

  // Dedicated tool hooks — provide structured sessionID and tool name.
  if (EVENTS.has("tool.execute.before")) {
    hooks["tool.execute.before"] = async (input, output) => {
      runHook(
        "tool.execute.before",
        getString(input?.sessionID) || getString(input?.sessionId) || getString(input?.session_id),
        cwd,
        { input, output }
      );
    };
  }
  if (EVENTS.has("tool.execute.after")) {
    hooks["tool.execute.after"] = async (input, output) => {
      runHook(
        "tool.execute.after",
        getString(input?.sessionID) || getString(input?.sessionId) || getString(input?.session_id),
        cwd,
        { input, output }
      );
    };
  }

  return hooks;
};
