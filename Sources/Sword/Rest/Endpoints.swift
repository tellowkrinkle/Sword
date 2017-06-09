//
//  Endpoints.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

enum Endpoint {

  case gateway

  case addPinnedChannelMessage(channel: SnowflakeID, message: SnowflakeID)

  case beginGuildPrune(SnowflakeID)

  case bulkDeleteMessages(SnowflakeID)

  case createChannelInvite(SnowflakeID)

  case createDM

  case createGuild

  case createGuildBan(guild: SnowflakeID, user: SnowflakeID)

  case createGuildChannel(SnowflakeID)

  case createGuildIntegration(SnowflakeID)

  case createGuildRole(SnowflakeID)

  case createMessage(SnowflakeID)

  case createReaction(channel: SnowflakeID, message: SnowflakeID, emoji: AnyEmoji)

  case createWebhook(SnowflakeID)

  case deleteAllReactions(channel: SnowflakeID, message: SnowflakeID)

  case deleteChannel(SnowflakeID)

  case deleteChannelPermission(channel: SnowflakeID, overwrite: SnowflakeID)

  case deleteGuild(SnowflakeID)

  case deleteGuildIntegration(guild: SnowflakeID, integration: SnowflakeID)

  case deleteGuildRole(guild: SnowflakeID, role: SnowflakeID)

  case deleteInvite(SnowflakeID)

  case deleteMessage(channel: SnowflakeID, message: SnowflakeID)

  case deleteOwnReaction(channel: SnowflakeID, message: SnowflakeID, emoji: AnyEmoji)

  case deletePinnedChannelMessage(channel: SnowflakeID, message: SnowflakeID)

  case deleteUserReaction(channel: SnowflakeID, message: SnowflakeID, emoji: AnyEmoji, user: SnowflakeID)

  case deleteWebhook(webhook: SnowflakeID, token: String?)

  case editChannelPermissions(channel: SnowflakeID, overwrite: SnowflakeID)

  case editMessage(channel: SnowflakeID, message: SnowflakeID)

  case executeSlackWebhook(webhook: SnowflakeID, token: String)

  case executeWebhook(webhook: SnowflakeID, token: String)

  case getChannel(SnowflakeID)

  case getChannelInvites(SnowflakeID)

  case getChannelMessage(channel: SnowflakeID, message: SnowflakeID)

  case getChannelMessages(SnowflakeID)

  case getChannelWebhooks(SnowflakeID)

  case getCurrentUser

  case getCurrentUserGuilds

  case getGuild(SnowflakeID)

  case getGuildBans(SnowflakeID)

  case getGuildChannels(SnowflakeID)

  case getGuildEmbed(SnowflakeID)

  case getGuildIntegrations(SnowflakeID)

  case getGuildInvites(SnowflakeID)

  case getGuildMember(guild: SnowflakeID, user: SnowflakeID)

  case getGuildPruneCount(SnowflakeID)

  case getGuildRoles(SnowflakeID)

  case getGuildVoiceRegions(SnowflakeID)

  case getGuildWebhooks(SnowflakeID)

  case getInvite(SnowflakeID)

  case getPinnedMessages(SnowflakeID)

  case getReactions(channel: SnowflakeID, message: SnowflakeID, emoji: AnyEmoji)

  case getUser(SnowflakeID)

  case getUserConnections

  case getUserDM

  case getWebhook(webhook: SnowflakeID, token: String?)

  case groupDMRemoveRecipient(channel: SnowflakeID, user: SnowflakeID) // Currently unused

  case leaveGuild(SnowflakeID)

  case listGuildMembers(SnowflakeID)

  case modifyChannel(SnowflakeID)

  case modifyCurrentUser

  case modifyGuild(SnowflakeID)

  case modifyGuildChannelPositions(SnowflakeID)

  case modifyGuildEmbed(SnowflakeID) // Currently unused

  case modifyGuildIntegration(guild: SnowflakeID, integration: SnowflakeID)

  case modifyGuildMember(guild: SnowflakeID, user: SnowflakeID)

  case modifyGuildRole(guild: SnowflakeID, role: SnowflakeID)

  case modifyGuildRolePositions(SnowflakeID)

  case modifyWebhook(webhook: SnowflakeID, token: String?)

  case removeGuildBan(guild: SnowflakeID, user: SnowflakeID)

  case removeGuildMember(guild: SnowflakeID, user: SnowflakeID)

  case syncGuildIntegration(guild: SnowflakeID, integration: SnowflakeID)

  case triggerTypingIndicator(SnowflakeID)

}
