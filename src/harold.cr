module Harold
  extend self

  macro subscribe(topic)
    %channel = ::Harold::Subscription({{topic.type.id}}).new
    ::Harold::Subscriptions({{topic.type.id}})
      .instance[{{topic.id.stringify}}]
      .<< %channel
    %channel
  end

  macro publish(topic, value)
    ::Harold::Subscriptions({{topic.type.id}})
      .instance[{{topic.id.stringify}}]
      .each do |channel|
      channel.send({{value}})
    end
  end

  def start
  end

  def stop
    cleaners.each &.clear
  end

  def cleaners
    @@cleaners ||= [] of SubscriptionsCleaner
  end

  def register(subscriptions)
    cleaners << SubscriptionsCleaner.new(subscriptions)
  end

  class Subscriptions(T)
    def self.instance
      @@instance ||= new
    end

    def initialize
      ::Harold.register(self)
    end

    def [](topic)
      topics[topic] ||= [] of Subscription(T)
      topics[topic]
    end

    def topics
      @_topics ||= {} of String => Array(Subscription(T))
    end

    def clear
      topics.each do |_, channels|
        channels.each &.close
      end

      @@instance = nil
    end
  end

  class SubscriptionsCleaner
    getter unwrap
    def initialize(@unwrap)
    end

    delegate clear, unwrap
  end

  class Subscription(T)
    getter unwrap
    def initialize
      @unwrap = Channel(T).new
    end

    delegate close, unwrap
    delegate closed?, unwrap
    delegate receive, unwrap
    delegate send, unwrap

    def each
      while !closed?
        yield(receive)
      end
    rescue e : Channel::ClosedError
    end
  end
end
