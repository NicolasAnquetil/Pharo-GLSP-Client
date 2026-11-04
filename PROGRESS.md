# Bloc GLSP client

Bloc `v3.0.0` (pharo-graphics/Bloc) loaded in the image; Bloc itself is not modified.
Packages: `GLSP-Client` (protocol client, no Bloc), `GLSP-Client-Bloc` (rendering), and their `-Tests`.

## Client step 1 — Reading GModels ✅ 7 tests
- `GLSPGModelElement class >> fromJSON:` (extension methods of `GLSP-Client`): element class from the type prefix
  (graph, comp, port, edge, label) or from the structure (`sourceId` → edge, `text` → label, else node).

## Client step 2 — Protocol client ✅ 10 tests
- `GLSPClient`: JSON-RPC requests with one semaphore per id and a timeout, notifications, `process` routing.
- `GLSPClientDiagram`: current GModel, dirty state, type hints, palette; announces `GLSPClientDiagramChanged`.
- `GLSPLoopbackConnection` (+ server-side `GLSPCallbackTransport`): client and server in the same image, no socket.

## Client step 3 — Bloc rendering ✅ 8 tests
- `GLSPBlocDiagramElement`, `GLSPBlocViewRegistry` (type → view class), views `GLSPBlocNodeView`,
  `GLSPBlocLabelView`, `GLSPBlocEdgeView` (line clipped on the borders of the nodes, from the GModel bounds).

## Client step 4 — Incremental update, following a live diagram ✅ 7 tests (31 client tests)
- Views kept by GModel id on updateModel (moved / updated / reparented), removed and added views, edges recomputed.
- `diagram:` follows a `GLSPClientDiagram`; in an open space, updates are enqueued as Bloc tasks.
- Checked visually with a headless PNG export of the TaskList example.
