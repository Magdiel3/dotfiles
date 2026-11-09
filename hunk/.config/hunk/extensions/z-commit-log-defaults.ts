import type { HunkExtensionAPI } from "hunkdiff/extension";

export default function (hunk: HunkExtensionAPI) {
  hunk.on("startup", (_event, ctx) => {
    for (const pane of ["hunk-commit-log:commits", "hunk-commit-log:message"]) {
      if (ctx.panes.isOpen(pane)) {
        ctx.panes.close(pane);
      }
    }
  });
}
