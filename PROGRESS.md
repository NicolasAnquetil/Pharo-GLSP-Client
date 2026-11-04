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

## Client step 5 — Editor window ✅ 6 tests (37 client tests)
- `GLSPBlocEditor`: tool palette (`GLSPBlocPaletteElement`, groups and items sorted by `sortString`) + diagram element.
- `GLSPBlocEditor openOn: aClientDiagram` opens it in a `BlSpace`; the title is the model file name, with a `*` when dirty;
  closing the window disposes the client session. `GLSPBlocEditor exampleTaskList` opens a demo.
- `GLSPTBlocUIProcess`: changes coming from the server are applied in the UI process of Bloc (`BlSpace>>deferOrValue:`).
- Tests show the spaces on `BlHeadlessHost`: no window, but the real Bloc UI process runs (`settle`).

## Client step 6 — Socket connection ✅ 17 new tests (54 client tests)
- `GLSPSocketConnection` (`GLSPClient host:port:`): TCP + Content-Length framing (reuses the server's `GLSPStreamTransport`),
  a reader process delivers the server messages; an error on one message does not stop the reader (`lastError`).
- The server closing the connection fails the pending requests at once; no server listening → `GLSPClientError`.
- Over a socket, actions are asynchronous: `GLSPClientDiagram >> request:` answers the response action (same `responseId`),
  `dispatch:andWaitFor:` waits for an action kind; `requestModel:`, `requestTypeHints`, `requestToolPalette` wait for their response.
- `GLSPSocketClientTest` reruns all the client tests through a real socket (server of the image on a free port).

## Client step 7 — Eclipse GLSP Java server ✅ 11 new tests (65 client tests)
- Interop target: the Workflow example server of Eclipse GLSP (Java, 2.8.0, from Maven Central), on a plain socket
  (`interop/start-workflow-server.sh`). Handshake and serverActions worked as is.
- Found by probing: the server needs the client to compute the layout. It sends `requestBounds` only to clients declaring that
  kind, and the model only after `computedBounds`. Without it, the model never comes.
- `GLSPRequestBoundsAction`, `GLSPComputedBoundsAction`; the client diagram answers with a pluggable bounds computer,
  `GLSPGModelBoundsComputer` by default (the sizes and positions already in the GModel).
- `GLSPEclipseWorkflowServerTest` (skipped without server): initialize, model, type hints and palette, create, delete, undo, save.
- The full example1.wf displays in the Bloc editor, with the Workflow tool palette.
- Known gap: elements created on the server come without size, and the GModel computer has none to give.
