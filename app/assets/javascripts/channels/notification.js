App.connect_to_notification_channel = function() {
  App.notification = App.cable.subscriptions.create("NotificationChannel", {
    connected: function() {
      // Called when the subscription is ready for use on the server
      // console.log('Connected');
    },

    disconnected: function() {
      // Called when the subscription has been terminated by the server
      // console.log('Disconnected');
    },

    received: function(data) {
      // Called when there's incoming data on the websocket for this channel
      // console.log('Received notification: ' + data);
      $('.js-notifications-list').prepend(data);
    },
})};
