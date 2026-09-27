/**
 * Web Search Extension - DuckDuckGo HTML to Markdown
 *
 * Searches the web via DuckDuckGo's public HTML interface and outputs
 * results formatted as markdown. No API key required - uses only public
 * endpoints and pi's built-in `pi.exec("curl", [...])` infrastructure.
 *
 * Features:
 * - Zero configuration - works out of the box
 * - Markdown formatting (bold titles, bracketed URLs, descriptions)
 * - Configurable number of results (default: 5)
 * - Auto-discovered from ~/.pi/agent/extensions/
 * - No external dependencies beyond `curl`
 *
 * Limitations:
 * - Relies on DuckDuckGo HTML structure (updates may need regex tweaks)
 * - Rate-limited by DuckDuckGo's reasonable usage policies
 * - JavaScript-rendered content not captured (DDG lite mode provides static HTML)
 * - Maximum practical results: 5-10 per search (to keep responses concise)
 * - May encounter bot protection challenges from DuckDuckGo on automated queries
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const SearchParams = Type.Object({
  query: Type.String({
    description: "Search query text",
    minLength: 1,
  }),
  maxResults: Type.Optional(
    Type.Number({
      description: "Maximum number of results to return",
      minimum: 1,
      maximum: 10,
      default: 5,
    })
  ),
});

/**
 * Extract search results from DuckDuckGo HTML search results page.
 * Parses the "lite" version HTML for stable, fast parsing.
 *
 * @param html Raw HTML from `https://lite.duckduckgo.com/lite/?q=QUERY`
 * @param maxMaximum maximum number of results to extract
 * @returns Object with results array and challenge detection flag
 */
function extractDdgResults(html: string, maxMaximum: number): {
  results: Array<{
    title: string;
    url: string;
    description: string;
  }>;
  hasChallenge: boolean;
} {
  const results: Array<{
    title: string;
    url: string;
    description: string;
  }> = [];

  // Quick check: if HTML contains challenge/anomaly modal, DDG is blocking automated queries
  const hasChallenge = /anomaly-modal/.test(html);
  if (hasChallenge) {
    return { results, hasChallenge: true };
  }

  // DuckDuckGo Lite result pattern:
  // <a class="result-title" href="URL">Title</a>...<span class="result-url-url">https://...</span>...<a class="result-abstract">Description</a>
  const resultPattern = /<a class="result-title"[^>]*>([^<]+)<\/a>[^<]*<a[^>]*class="result-url"[^>]*><span class="result-url-url">([^<]+)<\/span><\/a>[^<]*<a class="result-abstract"[^>]*>([^<]+)<\/a>/gi;

  let match: RegExpExecArray | null;
  let count = 0;

  while ((match = resultPattern.exec(html)) && count < maxMaximum) {
    count++;

    const rawTitle = match[1];
    const rawUrl = match[2];
    const rawDescription = match[3];

    // Strip HTML tags and entities, normalize whitespace
    const title = stripHtml(rawTitle).trim();
    const url = normalizeUrl(rawUrl.trim());
    const description = stripHtml(rawDescription).trim();

    // Skip if we don't have essential data
    if (!title || !url) {
      continue;
    }

    results.push({ title, url, description });
  }

  return { results, hasChallenge: false };
}

/** Remove all HTML tags and decode common HTML entities. */
function stripHtml(str: string): string {
  return str
    .replace(/<[^>]*>/g, "")           // Remove every <...> tag
    .replace(/&[a-z]+;/gi, " ")        // Replace &amp; &lt; &gt; etc. with space
    .replace(/&#[0-9]+;/g, " ")        // Replace &#123; numeric entities
    .replace(/\s+/g, " ")              // Collapse multiple whitespace
    .trim();
}

/** Ensure URL is absolute (prepend https:// if needed). */
function normalizeUrl(url: string): string {
  // DDG typically returns absolute URLs, but handle edge cases
  if (!url) return url;

  // If already an absolute URL starting with http:// or https://, return as-is
  if (/^https?:\/\//i.test(url)) return url;

  // If it starts with // (protocol-relative), prepend https:
  if (url.startsWith("//")) return "https:" + url;

  // Otherwise, prepend https://
  return "https://" + url;
}

/** Format a single result as markdown. */
function resultToMarkdown(i: number, r: {
  title: string;
  url: string;
  description: string;
}): string {
  return `${i + 1}. **${r.title}**\n` +
    `   [${r.url}]\n` +
    `   ${r.description || "No description available"}`;
}

/** Format all results as a single markdown string. */
function formatMarkdown(results: Array<{
  title: string;
  url: string;
  description: string;
}>): string {
  if (results.length === 0) {
    return "_No search results found._";
  }

  return results.map(resultToMarkdown).join("\n\n");
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "web-search",
    label: "Web Search (Markdown)",
    description: "Search the web via DuckDuckGo and return results as markdown. No API key required.",
    parameters: SearchParams,

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const query = (params.query || "").trim();
      const maxResults = params.maxResults ?? 5;

      if (!query) {
        return {
          content: [{ type: "text", text: "Error: Empty search query. Provide a non-empty query string." }],
          details: { query: "", resultsReturned: 0, hasChallenge: false },
        };
      }

      // Step 1: Fetch DuckDuckGo search results (HTML, "lite" mode)
      // Using pi's exec with curl - "curl" is a safe, allowed command
      const ddgResponse = await pi.exec("curl", [
        "-s",           // Silent - don't show progress
        "-L",           // Follow redirects
        "--max-time", "15", // Maximum 15 seconds timeout
        "https://lite.duckduckgo.com/lite/?q=" + encodeURIComponent(query),
      ], {
        cwd: ctx?.cwd,
        timeout: 30_000, // 30 second overall timeout
      });

      // Handle curl errors
      if (ddgResponse.code !== 0) {
        const errorMsg = ddgResponse.stderr || ddgResponse.stdout || "Unknown curl error";
        return {
          content: [{ type: "text", text: `Search failed: ${errorMsg}` }],
          details: { query, error: errorMsg, resultsReturned: 0, hasChallenge: false },
        };
      }

      // Step 2: Parse results from HTML (includes challenge detection)
      const parseResult = extractDdgResults(ddgResponse.stdout, maxResults);

      // Handle challenge page (bot protection)
      if (parseResult.hasChallenge) {
        return {
          content: [{ type: "text", text: "Search blocked: DuckDuckGo detected automated queries. Please try again later or use a different search approach." }],
          details: { query, resultsReturned: 0, hasChallenge: true },
        };
      }

      const results = parseResult.results;

      if (results.length === 0) {
        return {
          content: [{ type: "text", text: "No search results found. Try a different query or check your network connection." }],
          details: { query, resultsReturned: 0, hasChallenge: false },
        };
      }

      // Step 3: Format as markdown
      const markdownOutput = formatMarkdown(results);

      // Step 4: Return results
      const output = `Search results for "${query}" (Markdown - ${results.length} results):\n\n${markdownOutput}`;

      return {
        content: [{ type: "text", text: output }],
        details: {
          query,
          resultsReturned: results.length,
          maxRequested: maxResults,
          searchEngine: "duckduckgo",
          hasChallenge: false,
        },
      };
    },
  });

  // Optional: Register a /search command for direct user invocation
  pi.registerCommand("search", {
    description: "Search the web and display results in markdown format",
    handler: async (args, ctx) => {
      const query = (args || "").trim();

      if (!query) {
        ctx?.ui?.notify("Usage: /search <query>", "warning");
        return;
      }

      try {
        const result = await pi.executeTool("web-search", { query });

        if (result.content?.[0]?.type === "text") {
          ctx?.ui?.notify(`Search results for: ${query}`, "info");
          // Set the editor text to the markdown output for easy viewing
          ctx?.ui?.setEditorText(result.content[0].text);
        } else {
          ctx?.ui?.notify("Search tool returned unexpected format", "error");
        }
      } catch (err: any) {
        ctx?.ui?.notify(`Search error: ${err.message || "Unknown error"}`, "error");
      }
    },
  });
}