//
//  Channel.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Generic Channel structure
public protocol Channel {

  // MARK: Properties

  /// Parent class
  weak var sword: Sword? { get }

  /// The id of the channel
  var id: Snowflake { get }

  /// The last message's id
  var lastMessageId: Snowflake? { get }

  /// Collection of messages mapped by message id
  var messages: [Snowflake: Message] { get }

}

public extension Channel {

  // MARK: Functions

  /**
   Adds a reaction (unicode or custom emoji) to message

   - parameter reaction: Unicode or custom emoji reaction
   - parameter messageId: Message to add reaction to
  */
  public func addReaction(_ reaction: AnyEmoji, to messageId: Snowflake, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword?.addReaction(reaction, to: messageId, in: self.id, then: completion)
  }

  /// Deletes the current channel, whether it be a DMChannel or GuildChannel
  public func delete(then completion: @escaping (Channel?, RequestError?) -> () = {_ in}) {
    self.sword?.deleteChannel(self.id, then: completion)
  }

  /**
   Deletes a message from this channel

   - parameter messageId: Message to delete
  */
  public func deleteMessage(_ messageId: Snowflake, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword?.deleteMessage(messageId, from: self.id, then: completion)
  }

  /**
   Bulk deletes messages

   - parameter messages: Array of message ids to delete
  */
  public func deleteMessages(_ messages: [Snowflake], then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword?.deleteMessages(messages, from: self.id, then: completion)
  }

  /**
   Deletes a reaction from message by user

   - parameter reaction: Unicode or custom emoji to delete
   - parameter messageId: Message to delete reaction from
   - parameter userId: If nil, deletes bot's reaction from, else delete a reaction from user
  */
  public func deleteReaction(_ reaction: AnyEmoji, from messageId: Snowflake, by userId: Snowflake? = nil, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword?.deleteReaction(reaction, from: messageId, by: userId, in: self.id, then: completion)
  }

  /**
   Edits a message's content

   - parameter messageId: Message to edit
   - parameter content: Text to change message to
  */
  public func editMessage(_ messageId: Snowflake, to content: String, then completion: @escaping (Message?, RequestError?) -> () = {_ in}) {
    self.sword?.editMessage(messageId, to: content, in: self.id, then: completion)
  }

  /**
   Gets a message from this channel

   - parameter messageId: Id of message you want to get
  **/
  public func getMessage(_ messageId: Snowflake, then completion: @escaping (Message?, RequestError?) -> ()) {
    self.sword?.getMessage(messageId, from: self.id, then: completion)
  }

  /**
   Gets an array of messages from this channel

   #### Option Params ####

   - **around**: Message Id to get messages around
   - **before**: Message Id to get messages before this one
   - **after**: Message Id to get messages after this one
   - **limit**: Number of how many messages you want to get (1-100)

   - parameter options: Dictionary containing optional options regarding how many messages, or when to get them
  **/
  public func getMessages(with options: [String: Any]? = nil, then completion: @escaping ([Message]?, RequestError?) -> ()) {
    self.sword?.getMessages(from: self.id, with: options, then: completion)
  }

  /**
   Gets an array of users who used reaction from message

   - parameter reaction: Unicode or custom emoji to get
   - parameter messageId: Message to get reaction users from
  */
  public func getReaction(_ reaction: AnyEmoji, from messageId: Snowflake, then completion: @escaping ([User]?, RequestError?) -> ()) {
    self.sword?.getReaction(reaction, from: messageId, in: self.id, then: completion)
  }

  /// Get Pinned messages for this channel
  public func getPinnedMessages(then completion: @escaping ([Message]?, RequestError?) -> () = {_ in}) {
    self.sword?.getPinnedMessages(from: self.id, then: completion)
  }

  /**
   Pins a message to this channel

   - parameter messageId: Message to pin
  */
  public func pin(_ messageId: Snowflake, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword?.pin(messageId, in: self.id, then: completion)
  }

  /**
   Sends a message to channel

   - parameter message: Message to send
  */
  public func send(_ message: Any, then completion: @escaping (Message?, RequestError?) -> () = {_ in}) {
    self.sword?.send(message, to: self.id, then: completion)
  }

  /**
   Unpins a pinned message from this channel

   - parameter messageId: Pinned message to unpin
  */
  public func unpin(_ messageId: Snowflake, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword?.unpin(messageId, from: self.id, then: completion)
  }

}
