// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library socket.server;

import 'package:analysis_server/src/analysis_server.dart';
import 'package:analysis_server/src/channel/channel.dart';
import 'package:analysis_server/src/plugin/server_plugin.dart';
import 'package:analysis_server/src/protocol.dart';
import 'package:analysis_server/src/services/index/index.dart';
import 'package:analysis_server/src/services/index/local_file_index.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/instrumentation/instrumentation.dart';
import 'package:analyzer/source/pub_package_map_provider.dart';
import 'package:analyzer/src/generated/sdk_io.dart';


/**
 * Creates and runs an [Index].
 */
Index _createIndex() {
  Index index = createLocalFileIndex();
  index.run();
  return index;
}


/**
 * Instances of the class [SocketServer] implement the common parts of
 * http-based and stdio-based analysis servers.  The primary responsibility of
 * the SocketServer is to manage the lifetime of the AnalysisServer and to
 * encode and decode the JSON messages exchanged with the client.
 */
class SocketServer {
  final AnalysisServerOptions analysisServerOptions;
  final DirectoryBasedDartSdk defaultSdk;
  final InstrumentationService instrumentationService;
  final ServerPlugin serverPlugin;

  /**
   * The analysis server that was created when a client established a
   * connection, or `null` if no such connection has yet been established.
   */
  AnalysisServer analysisServer;

  SocketServer(this.analysisServerOptions, this.defaultSdk,
      this.instrumentationService, this.serverPlugin);

  /**
   * Create an analysis server which will communicate with the client using the
   * given serverChannel.
   */
  void createAnalysisServer(ServerCommunicationChannel serverChannel) {
    if (analysisServer != null) {
      RequestError error = new RequestError(
          RequestErrorCode.SERVER_ALREADY_STARTED,
          "Server already started");
      serverChannel.sendResponse(new Response('', error: error));
      serverChannel.listen((Request request) {
        serverChannel.sendResponse(new Response(request.id, error: error));
      });
      return;
    }
    PhysicalResourceProvider resourceProvider =
        PhysicalResourceProvider.INSTANCE;
    analysisServer = new AnalysisServer(
        serverChannel,
        resourceProvider,
        new PubPackageMapProvider(resourceProvider, defaultSdk),
        _createIndex(),
        analysisServerOptions,
        defaultSdk,
        instrumentationService,
        rethrowExceptions: false);
    _initializeHandlers(analysisServer);
  }

  /**
   * Initialize the handlers to be used by the given [server].
   */
  void _initializeHandlers(AnalysisServer server) {
    server.handlers = serverPlugin.createDomains(server);
  }
}
