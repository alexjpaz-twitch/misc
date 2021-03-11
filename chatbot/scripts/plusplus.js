const ComfyJS = require('comfy.js');

const dbKey = "alexjpaz-twitch/points";

exports.dbKey = dbKey;

const defaultDb = {};

exports.aliases = [
  "score"
];

exports.handleScoreDisplay = (user, message) => {
  const db = JSON.parse(localStorage.getItem(dbKey)) || defaultDb;

  let target = message || user;
  target = target.replace("@","");

  let points = db[target] || {};

  const pointsArray = Object.keys(points)
    .map((p) => {
      return `${points[p]} ${p}`;
    });

  ComfyJS.Say(`/me HSCheers ${target} ${pointsArray.join(", ")}`.slice(0,490));

  localStorage.setItem(dbKey, JSON.stringify(db));
};

exports.handlePoints = (user, message) => {
  const db = JSON.parse(localStorage.getItem(dbKey)) || defaultDb;

  // Parse of message
  const pattern = /@?([A-Za-z0-9_]+) ?(\+\+|\-\-|\+\= ?[0-9]+|\-\= ?[0-9]+) ?(.*)?/;

  const matches = message.match(pattern);

  if(!matches) {
    return;
  }

  let target = matches[1];

  let amount = 0;

  if(matches[2] == "++") {
    amount = 1;
  }

  if(matches[2] == "--") {
    amount = -1;
  }

  // Maybe remove this?
  if(matches[2].startsWith('+=')) {
    amount = +(matches[2].slice(2));
  }

  if(matches[2].startsWith('-=')) {
    amount = -(matches[2].slice(2));
  }

  let reason = matches[3] || "points";

  let userPoints = db[target] || {};

  userPoints[reason] = userPoints[reason] || 0;

  userPoints[reason] += (amount);

  db[target] = userPoints;

  ComfyJS.Say(`/me SeemsGood ${target} has ${userPoints[reason]} ${reason}`);

  localStorage.setItem(dbKey, JSON.stringify(db));
}

exports.onChat = (user, message, flags, self, extra) => {
  exports.handlePoints(user, message);
};

exports.handler = (user, command, message = "", flags) => {
  exports.handleScoreDisplay(user, message);
};
