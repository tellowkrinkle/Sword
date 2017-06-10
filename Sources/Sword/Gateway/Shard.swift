//
//  Shard.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation
import Dispatch

#if os(iOS)
import Starscream
#else
import Sockets
import TLS
import URI
import WebSockets

typealias WebSocket = WebSockets.WebSocket
#endif

/// WS class
class Shard {

  // MARK: Properties

  /// Gateway URL for gateway
  var gatewayUrl = ""

  /// Global Event Rate Limiter
  let globalBucket: Bucket

  /// Heartbeat worker
  var heartbeat: Heartbeat?

  /// ID of shard
  let id: Int

  /// Whether or not the shard is connected to gateway
  var isConnected = false

  /// The last sequence sent by Discord
  var lastSeq: Int?

  /// Presence Event Rate Limiter
  let presenceBucket: Bucket

  /// Whether or not the shard is reconnecting
  var isReconnecting = false

  /// WS
  var session: WebSocket?

  /// Session ID of gateway
  var sessionId: String?

  /// Amount of shards bot should be connected to
  let shardCount: Int

  /// Parent class
  let sword: Sword

  // MARK: Initializer

  /**
   Creates Shard Handler

   - parameter sword: Parent class
   - parameter id: ID of the current shard
   - parameter shardCount: Total number of shards bot needs to be connected to
  */
  init(_ sword: Sword, _ id: Int, _ shardCount: Int) {
    self.sword = sword
    self.id = id
    self.shardCount = shardCount

    self.globalBucket = Bucket(
      name: "gg.azoy.sword.gateway.global",
      limit: 120,
      interval: 60
    )

    self.presenceBucket = Bucket(
      name: "gg.azoy.sword.gateway.presence",
      limit: 5,
      interval: 60
    )
  }

  // MARK: Functions

  /**
   Handles gateway events from WS connection with Discord

   - parameter payload: Payload struct that Discord sent as JSON
  */
  func event(_ payload: Payload) {
    if let sequenceNumber = payload.s {
      self.heartbeat?.sequence = sequenceNumber
      self.lastSeq = sequenceNumber
    }

    guard payload.t != nil else {
      self.handleGateway(payload)
      return
    }

    self.handleEvents(payload.d as! [String: Any], payload.t!)
  }

  /// Sends shard identity to WS connection
  func identify() {
    #if os(macOS)
    let osName = "macOS"
    #elseif os(Linux)
    let osName = "Linux"
    #elseif os(iOS)
    let osName = "iOS"
    #endif

    let identity = Payload(
      op: .identify,
      data: [
        "token": self.sword.token,
        "properties": [
          "$os": osName,
          "$browser": "Sword",
          "$device": "Sword"
        ],
        "compress": false,
        "large_threshold": 250,
        "shard": [
          self.id, self.shardCount
        ]
      ]
    ).encode()

    self.send(identity)
  }

  #if !os(iOS)

  /**
   Sends a payload to socket telling it we want to join a voice channel

   - parameter channelId: Channel to join
   - parameter guildId: Guild that the channel belongs to
  */
  func joinVoiceChannel(_ channelId: Snowflake, in guildId: Snowflake) {
    let payload = Payload(
      op: .voiceStateUpdate,
      data: [
        "guild_id": guildId.description,
        "channel_id": channelId.description,
        "self_mute": false,
        "self_deaf": false
      ]
    ).encode()

    self.send(payload)
  }

  /**
   Sends a payload to socket telling it we want to leave a voice channel

   - parameter guildId: Guild we want to remove bot from
  */
  func leaveVoiceChannel(in guildId: Snowflake) {
    let payload = Payload(
      op: .voiceStateUpdate,
      data: [
        "guild_id": guildId.description,
        "channel_id": NSNull(),
        "self_mute": false,
        "self_deaf": false
      ]
    ).encode()

    self.send(payload)
  }

  #endif

  /**
   Used to reconnect to gateway

   - parameter payload: Reconnect payload to send to connection
  */
  func reconnect() {
    #if os(iOS)
    self.session?.disconnect()
    #else
    try? self.session?.close()
    #endif

    self.sword.log("Disconnected from gateway... Resuming session")

    self.isConnected = false
    self.heartbeat = nil

    self.startWS(self.gatewayUrl)
  }

  /// Function to send packet to server to request for offline members for requested guild
  func requestOfflineMembers(for guildId: Snowflake) {
    let payload = Payload(
      op: .requestGuildMember,
      data: [
        "guild_id": guildId.description,
        "query": "",
        "limit": 0
      ]
    ).encode()

    self.send(payload)
  }

  /**
   Sends a payload through WS connection

   - parameter text: JSON text to send through WS connection
   - parameter presence: Whether or not this WS payload updates shard presence
  */
  func send(_ text: String, presence: Bool = false) {
    let item = DispatchWorkItem { [unowned self] in
      #if os(iOS)
      self.session?.write(string: text)
      #else
      try? self.session?.send(text)
      #endif
    }

    presence ? self.presenceBucket.queue(item) : self.globalBucket.queue(item)
  }

  /**
   Starts WS connection with Discord

   - parameter gatewayUrl: URL that WS should connect to
  */
  func startWS(_ gatewayUrl: String) {
    self.gatewayUrl = gatewayUrl

    #if os(iOS)
    self.session = WebSocket(url: URL(string: gatewayUrl)!)
    self.session?.callbackQueue = self.gatewayQueue

    self.session?.onConnect = { [unowned self] in
      self.isConnected = true
    }

    self.session?.onText = { [unowned self] text in
      self.sword.emit(.payload, with: text)
      self.event(Payload(with: text))
    }

    self.session?.onDisconnect = { [unowned self] error in
      self.heartbeat = nil
      self.isConnected = false
      switch CloseOP(rawValue: Int(error!.code))! {
        case .authenticationFailed:
          print("[Sword] Invalid Bot Token")

        case .invalidShard:
          print("[Sword] Invalid Shard (We messed up here. Try again.)")

        case .shardingRequired:
          print("[Sword] Sharding is required for this bot to run correctly.")

        default:
          if self.isReconnecting { self.reconnect() }
      }
    }

    self.session?.connect()
    #else
    let gatewayUri = try! URI(gatewayUrl)
    let tcp = try! TCPInternetSocket(scheme: "https", hostname: gatewayUri.hostname, port: gatewayUri.port ?? 443)
    let stream = try! TLS.InternetSocket(tcp, TLS.Context(.client))
    try? WebSocket.connect(to: gatewayUrl, using: stream) { [unowned self] ws in
      self.session = ws
      self.isConnected = true

      ws.onText = { _, text in
        self.sword.emit(.payload, with: text)
        self.event(Payload(with: text))
      }

      ws.onClose = { _, code, _, _ in
        self.heartbeat = nil
        self.isConnected = false
        switch CloseOP(rawValue: Int(code!))! {
          case .authenticationFailed:
            print("[Sword] Invalid Bot Token")

          case .invalidShard:
            print("[Sword] Invalid Shard (We messed up here. Try again.)")

          case .shardingRequired:
            print("[Sword] Sharding is required for this bot to run correctly.")

          default:
            if self.isReconnecting { self.reconnect() }
        }
      }
    }
    #endif
  }

  /// Used to stop WS connection
  func stop() {
    #if os(iOS)
    self.session?.disconnect()
    #else
    try? self.session?.close()
    #endif

    self.sword.log("Stopping gateway connection...")

    self.isConnected = false
    self.heartbeat = nil
    self.isReconnecting = false
  }

}
