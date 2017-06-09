//
//  SnowflakeID.swift
//  Sword
//


/// The stored type of a Discord Snowflake ID.  Currently a String, could be a UInt64 in the future.
public typealias SnowflakeID = String

extension SnowflakeID {
  init?(_ optionalString: String?) {
    guard let string = optionalString else { return nil }
    guard let snowflake = SnowflakeID(string) else { return nil }
    self = snowflake
  }
}
