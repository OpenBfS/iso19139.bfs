# iso19139.bfs: ISO19139 BfS 1.0 schema plugin

This is the ISO19139 BfS Version 1.0 schema plugin for GeoNetwork 4.x or greater version.

## Installing the plugin

### GeoNetwork version to use with this plugin

Use GeoNetwork 4.0.0+ version.
It'll not be supported in previous versions so don't plug it into it!

### Adding the plugin to the source code

The best approach is to add the plugin as a submodule into GeoNetwork schema module.

```
./add-schema.sh iso19139.bfs https://github.com/OpenBfS/iso19139.bfs 4.0.x
```

### Build the application

Once the application is build, the war file contains the schema plugin:

```
$ mvn clean install -Penv-prod
```

### Deploy the profile in an existing installation

After building the application, it's possible to deploy the schema plugin manually in an existing GeoNetwork installation:

- Copy the content of the folder schemas/iso19139.bfs/src/main/plugin to INSTALL_DIR/geonetwork/WEB-INF/data/config/schema_plugins/iso19139.bfs

- (optional, because iso19139.bfs does not have any java-classes yet): Copy the jar file schemas/iso19139.bfs/target/schema-iso19139.bfs-4.0.4-SNAPSHOT.jar to INSTALL_DIR/geonetwork/WEB-INF/lib. If there's no changes to the profile Java code or the configuration (config-spring-geonetwork.xml), the jar file is not required to be deployed each time.
