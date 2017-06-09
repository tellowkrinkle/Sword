//
//  SnowflakeID.swift
//  Sword
//


/// The stored type of a Discord Snowflake ID.
public typealias SnowflakeID = UInt64

extension SnowflakeID {
  init?(_ optionalString: String?) {
    guard let string = optionalString else { return nil }
    guard let snowflake = SnowflakeID(string) else { return nil }
    self = snowflake
  }
}
