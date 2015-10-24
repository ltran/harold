require "./spec_helper"

Spec2.describe Harold do
  before do
    Harold.start
  end

  context "simple pub-sub example" do
    let(events) { [] of String }

    it "is received by one subscriber" do
      e = events

      spawn do
        Harold.subscribe(topic :: String).each do |message|
          e << message
        end
      end

      sleep 0

      Harold.publish(topic :: String, "hello world")
      Harold.publish(topic :: String, "some stuff")
      Harold.publish(not_a_topic :: String, "no stuff")

      expect(events).to eq(["hello world", "some stuff"])
    end
  end

  describe "when there are multiple subscribers" do
    let(events) { [] of {String, String} }

    it "is received by subscribers of concrete topic" do
      e = events

      spawn do
        Harold.subscribe(topic :: String).each do |message|
          e << {"first", message}
        end
      end

      sleep 0

      spawn do
        Harold.subscribe(topic :: String).each do |message|
          e << {"second", message}
        end
      end

      sleep 0

      spawn do
        Harold.subscribe(other_topic :: String).each do |message|
          e << {"third", message}
        end
      end

      sleep 0

      Harold.publish(topic :: String, "hello world")
      Harold.publish(topic :: String, "some test")
      Harold.publish(other_topic :: String, "other message")
      Harold.publish(not_a_topic :: String, "not a message")

      expect(events).to eq([
        {"first", "hello world"},
        {"second", "hello world"},
        {"first", "some test"},
        {"second", "some test"},
        {"third", "other message"},
      ])
    end
  end

  context "when different message types used" do
    let(events) { [] of {String, String} }

    it "is considered as different topics" do
      e = events

      spawn do
        Harold.subscribe(topic :: String).each do |message|
          e << {"string", message}
        end
      end

      sleep 0

      spawn do
        Harold.subscribe(topic :: Int32).each do |message|
          e << {"int32", "#{message.inspect} :: #{message.class}"}
        end
      end

      sleep 0

      Harold.publish(topic :: String, "hello world")
      Harold.publish(topic :: Int32, 42)
      Harold.publish(topic :: Bool, true)

      expect(events).to eq([
        {"string", "hello world"},
        {"int32", "42 :: Int32"},
      ])
    end

    context "when types are complex" do
      it "still works correctly" do
        e = events

        spawn do
          Harold.subscribe(topic :: Array(String)).each do |message|
            e << {"array of strings", "#{message.inspect} :: #{message.class}"}
          end
        end

        sleep 0

        spawn do
          Harold.subscribe(topic :: Array(Int32)).each do |message|
            e << {"array of ints", "#{message.inspect} :: #{message.class}"}
          end
        end

        sleep 0

        Harold.publish(topic :: Array(Int32), [52, 42, 37])
        Harold.publish(topic :: Array(String), ["hello", "world"])

        expect(events).to eq([
          {"array of ints", "[52, 42, 37] :: Array(Int32)"},
          {"array of strings", "[\"hello\", \"world\"] :: Array(String)"},
        ])
      end
    end
  end

  after do
    Harold.stop
  end
end
