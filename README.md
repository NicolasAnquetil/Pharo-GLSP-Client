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

- `GLSP-Client`: `GLSPClient` (JSON-RPC requests and notifications), `GLSPClientDiagram` (one open diagram: GModel, dirty state, type hints, tool palette, `GLSPClientDiagramChanged` announcements), `GLSPLoopbackConnection` (client and server in the same image).
- `GLSP-Client-Bloc`: `GLSPBlocDiagramElement` (displays a GModel, follows a `GLSPClientDiagram`), `GLSPBlocViewRegistry` (Bloc view class per GModel type), node, label and edge views.

## Example

```smalltalk
| server client diagram element |
server := GLSPServer new registerDiagramModule: GLSPTaskListDiagramModule new; yourself.
client := GLSPClient loopbackOn: server.
diagram := client openDiagram: 'tasklist-diagram'.
diagram requestModel: '/path/to/example.tasklist' asFileReference asZnUrl printString.
element := GLSPBlocDiagramElement new extent: 420 @ 230; yourself.
element diagram: diagram.
element openInNewSpace.
```

See [PROGRESS.md](PROGRESS.md) for the development log.
