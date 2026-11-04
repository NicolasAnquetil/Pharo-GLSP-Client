# Interoperability with a third-party GLSP server

`GLSPEclipseWorkflowServerTest` runs the Pharo client against the
[Workflow example server](https://github.com/eclipse-glsp/glsp-server) of Eclipse GLSP (Java, 2.8.0).
It is skipped when no server listens on port 5007.

```sh
interop/start-workflow-server.sh        # needs Java 17+, downloads the server jar once
```

Then run `GLSPEclipseWorkflowServerTest` in the image.

The tests check the handshake, loading a model (the server needs the client to compute the layout:
`requestBounds` → `computedBounds`), type hints and tool palette, creating and deleting a task, undo and save.
