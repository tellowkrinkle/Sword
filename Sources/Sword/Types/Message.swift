//
//  Message.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Message Type
public struct Message {
  
  // MARK: Properties

  /// Array of Attachment structs that was sent with the message
  public internal(set) var attachments = [Attachment]()

  /// User struct of the author (not returned if webhook)
  public let author: User?

  /// Content of the message
  public let content: String

  /// Channel struct of the message
  public let channel: TextChannel

  /// If message was edited, this is the time it happened
  public let editedTimestamp: Date?

  /// Array of embeds sent with message
  public internal(set) var embeds = [Embed]()

  /// Message ID
  public let id: MessageID

  /// Whether or not this message mentioned everyone
  public let isEveryoneMentioned: Bool

  /// Whether or not this message is pinned in it's channel
  public let isPinned: Bool

  /// Whether or not this messaged was ttsed
  public let isTts: Bool

  /// Member struct for message
  public internal(set) var member: Member?

  /// Array of Users that were mentioned
  public internal(set) var mentions = [User]()

  /// Array of Roles that were mentioned
  public internal(set) var mentionedRoles = [RoleID]()

  /// Used to validate a message was sent
  public let nonce: Snowflake?

  /// Array of reactions with message
  public internal(set) var reactions = [[String: Any]]()

  /// Time when message was sent
  public let timestamp: Date
  
  /// Determines what type of message was sent
  public let type: Type
  
  /// If message was sent by webhook, this is that webhook's ID
  public let webhookId: WebhookID?

  // MARK: Initializer

  /**
   Creates Message struct

   - parameter sword: Parent class to get guilds from
   - parameter json: JSON representable as a dictionary
  */
  init(_ sword: Sword, _ json: [String: Any]) {
    let attachments = json["attachments"] as! [[String: Any]]
    for attachment in attachments {
      self.attachments.append(Attachment(attachment))
    }

    if json["webhook_id"] == nil {
      self.author = User(sword, json["author"] as! [String: Any])
    }else {
      self.author = nil
    }

    self.content = json["content"] as! String

    self.channel = sword.getChannel(for: ChannelID(json["channel_id"] as! String)!)! as! TextChannel

    if let editedTimestamp = json["edited_timestamp"] as? String {
      self.editedTimestamp = editedTimestamp.date
    }else {
      self.editedTimestamp = nil
    }

    let embeds = json["embeds"] as! [[String: Any]]
    for embed in embeds {
      self.embeds.append(Embed(embed))
    }

    self.id = MessageID(json["id"] as! String)!

    if json["webhook_id"] == nil {
      for (_, guild) in sword.guilds {
        if guild.channels[self.channel.id] != nil {
          self.member = guild.members[self.author!.id]
          break
        }
      }
    }else {
      self.member = nil
    }

    self.isEveryoneMentioned = json["mention_everyone"] as! Bool

    let mentions = json["mentions"] as! [[String: Any]]
    for mention in mentions {
      self.mentions.append(User(sword, mention))
    }

    self.mentionedRoles = (json["mention_roles"] as! [String]).map { RoleID($0)! }

    self.nonce = Snowflake(json["nonce"] as? String)

    if let reactions = json["reactions"] as? [[String: Any]] {
      self.reactions = reactions
    }
    self.isPinned = json["pinned"] as! Bool
    self.timestamp = (json["timestamp"] as! String).date
    self.isTts = json["tts"] as! Bool
    
    if let type = json["type"] as? Int {
      self.type = Type(rawValue: type)!
    }else {
      self.type = Type(rawValue: 0)!
    }
    
    self.webhookId = WebhookID(json["webhook_id"] as? String)
  }

  // MARK: Functions

  /**
   Adds a reaction to self

   - parameter reaction: Either unicode or custom emoji to add to this message
  */
  public func add(reaction: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.channel.addReaction(reaction, to: self.id, then: completion)
  }

  /// Deletes self
  public func delete(then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.channel.deleteMessage(self.id, then: completion)
  }

  /**
   Deletes reaction from self

   - parameter reaction: Either unicode or custom emoji reaction to remove
   - parameter userId: If nil, delete from self else delete from userId
  */
  public func delete(reaction: String, from userId: UserID? = nil, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.channel.deleteReaction(reaction, from: self.id, by: userId ?? nil, then: completion)
  }

  /// Deletes all reactions from self
  public func deleteReactions(then completion: @escaping (RequestError?) -> () = {_ in}) {
    guard let channel = self.channel as? GuildText else {
      completion(nil)
      return
    }

    channel.deleteReactions(from: self.id, then: completion)
  }

  /**
   Edit self's content

   - parameter content: Content to edit from self
  */
  public func edit(with options: [String: Any], then completion: @escaping (Message?, RequestError?) -> () = {_ in}) {
    self.channel.editMessage(self.id, with: options, then: completion)
  }

  /**
   Get array of users from reaction

   - parameter reaction: Either unicode or custom emoji reaction to get users from
  */
  public func get(reaction: String, then completion: @escaping ([User]?, RequestError?) -> ()) {
    self.channel.getReaction(reaction, from: self.id, then: completion)
  }

  /// Pins self
  public func pin(then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.channel.pin(self.id, then: completion)
  }

  /**
   Replies to a channel
   
   - parameter message: String to send to channel
  */
  public func reply(with message: String, then completion: @escaping (Message?, RequestError?) -> () = {_ in}) {
    self.channel.send(message, then: completion)
  }
  
  /**
   Replies to a channel
   
   #### Message Options ####
   
   Refer to Discord's documentation on the message body https://discordapp.com/developers/docs/resources/channel#create-message-json-params
   
   - parameter message: Dictionary containing information on the message
  */
  public func reply(with message: [String: Any], then completion: @escaping (Message?, RequestError?) -> () = {_ in}) {
    self.channel.send(message, then: completion)
  }
  
  /**
   Replies to a channel with an Embed
   
   - parameter message: Embed to send to channel
  */
  public func reply(with message: Embed, then completion: @escaping (Message?, RequestError?) -> () = {_ in}) {
    self.channel.send(message, then: completion)
  }
  
}

extension Message {
  
  /// Depicts what kind of message was sent in chat
  public enum `Type`: Int {
    
    /// Regular sent message
    case `default`
    
    /// Someone was added to group message
    case recipientAdd
    
    /// Someone was removed from group message
    case recipientRemove
    
    /// Someone called the group message
    case call
    
    /// Somone changed the group's name message
    case channelNameChange
    
    /// Someone changed the group's icon message
    case channelIconChange
    
    /// Somone pinned a message in this channel message
    case channelPinnedMessage
    
    /// Someone just joined the guild message
    case guildMemberJoin
  }
  
}

/// Attachment Type
public struct Attachment {
  
  // MARK: Properties
  
  /// The filename for this Attachment
  public let filename: String
  
  /// Height of image (if image)
  public let height: Int?
  
  /// ID of attachment
  public let id: AttachmentID
  
  /// The proxied URL for this attachment
  public let proxyUrl: String
  
  /// Size of the file in bytes
  public let size: Int
  
  /// The original URL of the attachment
  public let url: String
  
  /// Width of image (if image)
  public let width: Int?
  
  // MARK: Initializer
  
  /**
   Creates an Attachment struct
   
   - parameter json: JSON to decode into Attachment struct
   */
  init(_ json: [String: Any]) {
    self.filename = json["filename"] as! String
    self.height = json["height"] as? Int
    self.id = AttachmentID(json["id"] as! String)!
    self.proxyUrl = json["proxy_url"] as! String
    self.size = json["size"] as! Int
    self.url = json["url"] as! String
    self.width = json["width"] as? Int
  }
  
}

/// Embed Type
public struct Embed {
  
  // MARK: Properties
  
  /// Author dictionary from embed
  public var author: [String: Any]?
  
  /// Side panel color of embed
  public var color: Int?
  
  /// Description of the embed
  public var description: String?
  
  /// Fields for the embed
  public var fields: [[String: Any]]?
  
  /// Footer dictionary from embed
  public var footer: [String: Any]?
  
  /// Image data from embed
  public var image: [String: Any]?
  
  /// Provider from embed
  public var provider: [String: Any]?
  
  /// Thumbnail data from embed
  public var thumbnail: [String: Any]?
  
  /// Title of the embed
  public var title: String?
  
  /// Type of embed
  public let type: String
  
  /// URL of the embed
  public var url: String?
  
  /// Video data from embed
  public var video: [String: Any]?
  
  // MARK: Initializers
  
  /// Creates an Embed Structure
  public init() {
    self.type = "rich"
  }
  
  /**
   Creates an Embed Structure
   
   - parameter json: JSON representable as a dictionary
  */
  init(_ json: [String: Any]) {
    self.author = json["author"] as? [String: Any]
    self.color = json["color"] as? Int
    self.description = json["description"] as? String
    self.fields = json["fields"] as? [[String: Any]]
    self.footer = json["footer"] as? [String: Any]
    self.image = json["image"] as? [String: Any]
    self.provider = json["provider"] as? [String: Any]
    self.thumbnail = json["thumbnail"] as? [String: Any]
    self.title = json["title"] as? String
    self.type = json["type"] as! String
    self.url = json["url"] as? String
    self.video = json["video"] as? [String: Any]
  }
  
  /**
   Adds a field to the embed
   
   - parameter name: Name to give field
   - parameter value: Text that will be displayed underneath name
   - parameter inline: Whether or not to keep this field inline with others
  */
  public mutating func addField(_ name: String, value: String, inline: Bool = false) {
    self.fields?.append(["name": name, "value": value, "inline": inline])
  }
  
  /// Converts embed to dictionary
  public func encode() -> [String: Any] {
    var embed = [String: Any]()
    
    if self.author != nil { embed["author"] = self.author! }
    if self.color != nil { embed["color"] = self.color! }
    if self.description != nil { embed["description"] = self.description! }
    if self.fields != nil { embed["fields"] = self.fields! }
    if self.footer != nil { embed["footer"] = self.footer! }
    if self.image != nil { embed["image"] = self.image! }
    if self.thumbnail != nil { embed["thumbnail"] = self.thumbnail! }
    if self.title != nil { embed["title"] = self.title! }
    if self.url != nil { embed["url"] = self.url! }
    
    return embed
  }
  
}
