"
I load a client of the Graphical Language Server Protocol (GLSP) for Pharo, with a Bloc rendering of the diagrams.

Metacello new
	baseline: 'GLSPClient';
	repository: 'github://NicolasAnquetil/Pharo-GLSP-Client:main/src';
	load.

Groups: 'Core' (protocol client, without Bloc), 'Bloc' (Bloc rendering), 'Tests', 'default' (everything).
"
Class {
	#name : 'BaselineOfGLSPClient',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGLSPClient',
	#package : 'BaselineOfGLSPClient'
}

{ #category : 'baselines' }
BaselineOfGLSPClient >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec
				baseline: 'GLSP' with: [ spec repository: 'github://NicolasAnquetil/Pharo-GLSP:main/src' ];
				baseline: 'Bloc' with: [ spec repository: 'github://pharo-graphics/Bloc:v3.0.0/src' ].
			spec
				package: 'GLSP-Client' with: [ spec requires: #( 'GLSP' ) ];
				package: 'GLSP-Client-Tests' with: [ spec requires: #( 'GLSP-Client' ) ];
				package: 'GLSP-Client-Bloc' with: [ spec requires: #( 'GLSP-Client' 'Bloc' ) ];
				package: 'GLSP-Client-Bloc-Tests' with: [ spec requires: #( 'GLSP-Client-Bloc' 'GLSP-Client-Tests' ) ].
			spec
				group: 'Core' with: #( 'GLSP-Client' );
				group: 'Bloc' with: #( 'GLSP-Client-Bloc' );
				group: 'Tests' with: #( 'GLSP-Client-Tests' 'GLSP-Client-Bloc-Tests' );
				group: 'default' with: #( 'Core' 'Bloc' 'Tests' ) ]
]
