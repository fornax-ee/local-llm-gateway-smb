# Decisions and lessons

## Where local AI is worth it

| Use case | Local? | Why |
|---|---|---|
| Visual quality inspection at the line | **Yes** | images stay on site, low latency, works when the internet is down |
| Production data queries ("when will order X be ready?") | **Yes** | confidential data, tight integration with plant systems |
| Shop-floor assistant on shared terminals | **Yes** | no personal accounts needed, data scoped to the workstation |
| General writing, translation, summaries | Usually no | frontier models under a business contract are better |
| Document search over policies and manuals | Usually no | same; local only if documents are strictly confidential |
| Compliance text (declarations, safety data sheets) | No | quality matters more than locality; always human-reviewed |

A local GPU server justified by "we can do everything locally" will disappoint. One justified by two or three production use cases with clear savings will not.

## Location: in the plant, not in the head office

If the plant uses the model for inspection or line assistants, the server belongs in the plant network, behind the plant firewall. A WAN outage should not stop the lines. Same logic as any other production server.

## Gateway before applications

Build the gateway first, even with one model. Every later application then gets a key, a profile and logging for free.

## Logging

Log metadata (key, profile, tokens, latency, status), not prompt content. Content logs duplicate confidential data and create a store that administrators can read.

## Network exposure

The gateway is reachable only from the internal network and approved applications. vLLM backends listen only on the host or a private network, never directly to users.

## Hybrid is normal

A sensible end state is hybrid: local profiles for production and sensitive data, an external business API for heavy general work, both behind the same gateway so applications don't care.
