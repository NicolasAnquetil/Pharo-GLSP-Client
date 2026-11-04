# Pharo-GLSP-Client

A client of the [Graphical Language Server Protocol](https://eclipse.dev/glsp/) (GLSP) for Pharo, with a [Bloc](https://github.com/pharo-graphics/Bloc) rendering of the diagrams.

It works with the GLSP server of [Pharo-GLSP](https://github.com/NicolasAnquetil/Pharo-GLSP) and reuses its action and GModel classes.

## Install

```smalltalk
Metacello new
	baseline: 'GLSPClient';
	repository: 'github://NicolasAnquetil/Pharo-GLSP-Client:main/src';
	load.
```

Groups: `Core` (protocol client, no Bloc), `Bloc` (rendering), `Tests`, `default` (everything).

## Packages

- `GLSP-Client`: `GLSPClient` (JSON-RPC requests and notifications), `GLSPClientDiagram` (one open diagram: GModel, dirty state, type hints, tool palette, `GLSPClientDiagramChanged` announcements), `GLSPSocketConnection` (TCP, `GLSPClient host:port:`), `GLSPLoopbackConnection` (client and server in the same image).
- `GLSP-Client-Bloc`: `GLSPBlocEditor` (window with tool palette and diagram), `GLSPBlocDiagramElement` (displays a GModel, follows a `GLSPClientDiagram`), `GLSPBlocViewRegistry` (Bloc view class per GModel type), node, label and edge views.

## Example

With the TaskList server of Pharo-GLSP, in the same image:

```smalltalk
GLSPBlocEditor exampleTaskList.
```

## Using a third-party server: the Eclipse GLSP Java server

The client works with the [Workflow example server](https://github.com/eclipse-glsp/glsp-server) of Eclipse GLSP (Java, 2.8.0).

1. Start the server (Java 17+; the jar is downloaded once from Maven Central and checked against its SHA-256):

   ```sh
   interop/start-workflow-server.sh          # listens on port 5007; another port: interop/start-workflow-server.sh 6000
   ```

   Wait for `The GLSP server is ready to accept new client requests on port: 5007`.

2. Open a workflow model in a window:

   ```smalltalk
   GLSPBlocEditor exampleWorkflow.          "a small sample model, written to the temporary directory"
   GLSPBlocEditor openWorkflow: '/path/to/model.wf' asFileReference host: 'localhost' port: 5007.
   ```

   A bigger model: [example1.wf](https://raw.githubusercontent.com/eclipse-glsp/glsp-client/v2.8.0/examples/workflow-standalone/app/example1.wf) of the Eclipse GLSP examples.
   Closing the window disposes the session on the server and closes the connection.

3. Edit it from a Playground: the window follows the server.

   ```smalltalk
   | diagram |
   diagram := (BlSpace allInstances detect: [ :s | s isOpened and: [ s root children anySatisfy: [ :c | c isKindOf: GLSPBlocEditor ] ] ])
   	root children first diagram.
   diagram dispatch: (GLSPCreateNodeOperation new elementTypeId: 'task:manual'; location: 300 @ 250; yourself).
   diagram undo.
   diagram save.
   ```

Without a window, use the client directly:

```smalltalk
| client diagram |
client := GLSPClient host: 'localhost' port: 5007.
diagram := client openDiagram: 'workflow-diagram'.
diagram requestModel: '/path/to/model.wf' asFileReference asZnUrl printString.   "waits for the model"
diagram root children.
diagram close.
client connection close.
```

`GLSPEclipseWorkflowServerTest` runs the client against this server; it is skipped when no server listens on port 5007
(see [interop/README.md](interop/README.md)).

Limits: the editing tools of the palette are not there yet, elements created on the server get no size yet
(the client answers `requestBounds` with the sizes already in the model), and all nodes look alike.

See [PROGRESS.md](PROGRESS.md) for the development log.
