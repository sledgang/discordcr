require "./converters"

module Discord
  enum MessageType : UInt8
    Default                           =  0
    RecipientAdd                      =  1
    RecipientRemove                   =  2
    Call                              =  3
    ChannelNameChange                 =  4
    ChannelIconChange                 =  5
    ChannelPinnedMessage              =  6
    GuildMemberJoin                   =  7
    UserPremiumGuildSubscription      =  8
    UserPremiumGuildSubscriptionTier1 =  9
    UserPremiumGuildSubscriptionTier2 = 10
    UserPremiumGuildSubscriptionTier3 = 11

    def self.new(pull : JSON::PullParser)
      MessageType.new(pull.read_int.to_u8)
    end
  end

  struct Message
    JSON.mapping(
      type: MessageType,
      content: String,
      id: Snowflake,
      channel_id: Snowflake,
      guild_id: Snowflake?,
      author: User,
      member: PartialGuildMember?,
      timestamp: {type: Time, converter: TimestampConverter},
      tts: Bool,
      mention_everyone: Bool,
      mentions: Array(User),
      mention_roles: Array(Snowflake),
      attachments: Array(Attachment),
      embeds: Array(Embed),
      pinned: Bool?,
      reactions: Array(Reaction)?,
      nonce: String | Int64?,
      activity: Activity?
    )
  end

  enum ActivityType : UInt8
    Join        = 1
    Spectate    = 2
    Listen      = 3
    JoinRequest = 5

    def self.new(pull : JSON::PullParser)
      ActivityType.new(pull.read_int.to_u8)
    end
  end

  struct Activity
    JSON.mapping(
      type: ActivityType,
      party_id: String?
    )
  end

  enum ChannelType : UInt8
    GuildText     = 0
    DM            = 1
    GuildVoice    = 2
    GroupDM       = 3
    GuildCategory = 4
    GuildNews     = 5
    GuildStore    = 6

    def self.new(pull : JSON::PullParser)
      ChannelType.new(pull.read_int.to_u8)
    end
  end

  struct Channel
    # :nodoc:
    def initialize(private_channel : PrivateChannel)
      @id = private_channel.id
      @type = private_channel.type
      @recipients = private_channel.recipients
      @last_message_id = private_channel.last_message_id
    end

    JSON.mapping(
      id: Snowflake,
      type: ChannelType,
      guild_id: Snowflake?,
      name: String?,
      permission_overwrites: Array(Overwrite)?,
      topic: String?,
      last_message_id: Snowflake?,
      bitrate: UInt32?,
      user_limit: UInt32?,
      recipients: Array(User)?,
      nsfw: Bool?,
      icon: String?,
      owner_id: Snowflake?,
      application_id: Snowflake?,
      position: Int32?,
      parent_id: Snowflake?,
      rate_limit_per_user: Int32?
    )

    # Produces a string to mention this channel in a message
    def mention
      "<##{id}>"
    end
  end

  struct PartialChannel
    include JSON::Serializable

    def initialize(@name : String,
                   @id : Snowflake? = nil,
                   @type : ChannelType? = nil,
                   @guild_id : Snowflake? = nil,
                   @permission_overwrites : Array(Overwrite)? = nil,
                   @topic : String? = nil,
                   @last_message_id : Snowflake? = nil,
                   @bitrate : UInt32? = nil,
                   @user_limit : UInt32? = nil,
                   @recipients : Array(User)? = nil,
                   @nsfw : Bool? = nil,
                   @icon : Bool? = nil,
                   @owner_id : Snowflake? = nil,
                   @application_id : Snowflake? = nil,
                   @position : Int32? = nil,
                   @rate_limit_per_user : Int32? = nil)
    end
  end

  struct PrivateChannel
    JSON.mapping(
      id: Snowflake,
      type: ChannelType,
      recipients: Array(User),
      last_message_id: Snowflake?
    )
  end

  struct Overwrite
    JSON.mapping(
      id: Snowflake,
      type: String,
      allow: Permissions,
      deny: Permissions
    )
  end

  struct Reaction
    JSON.mapping(
      emoji: ReactionEmoji,
      count: UInt32,
      me: Bool
    )
  end

  struct ReactionEmoji
    JSON.mapping(
      id: Snowflake?,
      name: String
    )
  end

  struct Embed
    def initialize(@title : String? = nil, @type : String = "rich",
                   @description : String? = nil, @url : String? = nil,
                   @timestamp : Time? = nil, @colour : UInt32? = nil,
                   @footer : EmbedFooter? = nil, @image : EmbedImage? = nil,
                   @thumbnail : EmbedThumbnail? = nil, @author : EmbedAuthor? = nil,
                   @fields : Array(EmbedField)? = nil)
    end

    JSON.mapping(
      title: String?,
      type: String,
      description: String?,
      url: String?,
      timestamp: {type: Time?, converter: MaybeTimestampConverter},
      colour: {type: UInt32?, key: "color"},
      footer: EmbedFooter?,
      image: EmbedImage?,
      thumbnail: EmbedThumbnail?,
      video: EmbedVideo?,
      provider: EmbedProvider?,
      author: EmbedAuthor?,
      fields: Array(EmbedField)?
    )

    {% unless flag?(:correct_english) %}
      def color
        colour
      end
    {% end %}
  end

  struct EmbedThumbnail
    def initialize(@url : String)
    end

    JSON.mapping(
      url: String,
      proxy_url: String?,
      height: UInt32?,
      width: UInt32?
    )
  end

  struct EmbedVideo
    JSON.mapping(
      url: String,
      height: UInt32,
      width: UInt32
    )
  end

  struct EmbedImage
    def initialize(@url : String)
    end

    JSON.mapping(
      url: String,
      proxy_url: String?,
      height: UInt32?,
      width: UInt32?
    )
  end

  struct EmbedProvider
    JSON.mapping(
      name: String,
      url: String?
    )
  end

  struct EmbedAuthor
    def initialize(@name : String? = nil, @url : String? = nil, @icon_url : String? = nil)
    end

    JSON.mapping(
      name: String?,
      url: String?,
      icon_url: String?,
      proxy_icon_url: String?
    )
  end

  struct EmbedFooter
    def initialize(@text : String? = nil, @icon_url : String? = nil)
    end

    JSON.mapping(
      text: String?,
      icon_url: String?,
      proxy_icon_url: String?
    )
  end

  struct EmbedField
    def initialize(@name : String, @value : String, @inline : Bool = false)
    end

    JSON.mapping(
      name: String,
      value: String,
      inline: Bool
    )
  end

  struct Attachment
    JSON.mapping(
      id: Snowflake,
      filename: String,
      size: UInt32,
      url: String,
      proxy_url: String,
      height: UInt32?,
      width: UInt32?
    )
  end
end
