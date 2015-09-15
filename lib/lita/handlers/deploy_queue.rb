require 'lita/handlers/deploy/queue'

module Lita
  # Lita Handlers
  module Handlers
    # Handle the deployment queue
    class DeployQueue < Handler
      config :channel_name, required: true

      route(/^queue me$/, :queue_me, command: :true, help:
            { 'pb queue me' => 'Adds yourself into the queue for deploy.' })
      route(/^unqueue me$/, :unqueue_me, command: :true, help:
            { 'pb unqueue me' => 'Removes yourself from the deployment queue' })
      route(/^queue next$/, :queue_next, command: :true, help:
            { 'pb queue next' => 'Releases the queue and call next.' })
      route(/^queue$/, :queue_list, command: :true, help:
            { 'pb queue' => 'Displays who is queued' })

      def queue_me(response)
        pos = queue.push(response.user.mention_name)
        return message response,
                       "@#{response.user.mention_name}, it's  your turn!" \
                         if pos == 0

        response.reply_privately "You are next in queue" if pos == 1
        response.reply_privately "You are #{pos} in queue" if pos > 1
      rescue => e
        response.reply e.to_s
      end

      def unqueue_me(response)
        queue.remove(response.user.mention_name)
        response.reply_privately 'You are no longer in the queue'
      end

      def queue_list(response)
        current = queue.current
        response.reply_privately "It's #{current} turn..." if current
        members = queue.list.to_sentence

        response.reply_privately "The queue is empty" if members.size == 0
        response.reply_privately "This is the current queue: #{members}" if members.size > 0
      end

      def queue_next(response)
        if response.user.mention_name != queue.current && queue.current
          return response.reply_privately "Wait... it's #{queue.current} turn..."
        end
        user = queue.pop
        response.reply_privately "OK! I release the queue."
        message response, "@#{user}, it's your turn!" if user
      end

      private

      def message(response, string)
        robot.send_message(Lita::Source.new(room: room_id), string)
      end

      def room_id
        Lita::Room.find_by_name(config.channel_name).id
      end

      def queue
        @queue ||= Deploy::Queue.new
      end
    end

    Lita.register_handler(DeployQueue)
  end
end
