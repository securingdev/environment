import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("clear", {
    description: "Clear the context of the current session without compression or restart",
    handler: async (args, ctx) => {
      // Use newSession with withSession to get a fresh ctx
      await ctx.newSession({
        setup: (sessionManager) => {
          // Reset the leaf to clear context without compression
          // This effectively clears all conversation history
          sessionManager.resetLeaf();
        },
        withSession: (newCtx) => {
          // newCtx is a fresh ExtensionCommandContext for the new session
          newCtx.ui.notify("Context cleared successfully!", "info");
          return {
            content: [
              {
                type: "text",
                text: "The context of your current session has been fully cleared without compression. The session remains active.",
              },
            ],
          };
        },
      });
    },
  });
}
