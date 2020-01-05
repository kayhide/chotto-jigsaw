const ActionCable = require("@rails/actioncable");

exports.createConsumer = ActionCable.createConsumer;

exports._createSubscription = identifier => funcs => consumer => (onError, onSuccess) => {
  const sub = consumer.subscriptions.create(
    identifier, {
      received: data => {
        console.log("received: " + data.action);
        if (!sub.token) {
          if (data.action === "init" && data.token) {
            sub.token = data.token;
            onSuccess(sub);
          } else {
            onError("Bad initialization");
          };
        } else if (sub["receive_" + data.action]) {
          sub["receive_" + data.action](data);
        } else if (funcs[data.action]) {
          if (sub.token != data.token) {
            funcs[data.action](data)();
          };
        };
      }
    });
  return (cancelError, cancelerError, cancelerSuccess) => {
    cancelerSuccess();
  };
};

const request = (sub, action, onError, onSuccess) => {
  sub[`receive_${action}`] = data => {
    if (data.success) {
      if (data.content) {
        onSuccess(JSON.parse(data.content));
      } else {
        onSuccess();
      };
    } else {
      onError("Response is not success");
    };
  };
  sub.perform(`request_${action}`, {});
  return (cancelError, cancelerError, cancelerSuccess) => {
    cancelerSuccess();
  };
};

exports._requestContent = sub => (onError, onSuccess) =>
  request(sub, "content", onError, onSuccess);

exports._requestUpdate = sub => (onError, onSuccess) =>
  request(sub, "update", onError, onSuccess);


exports.perform = sub => name => payload => () =>
  sub.perform(name, payload);
