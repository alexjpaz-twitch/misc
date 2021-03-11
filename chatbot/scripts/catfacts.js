exports.handler = async () => {
  try {
    const fact = await fetch("https://catfact.ninja/fact")
      .then(r => r.json())
      .then(r => r.fact);
    ;

    return `/me CoolCat ${fact}`;
  } catch(e) {
    return `/me InuyoFace Failed to fetch catfact`;
  }
};

exports.aliases = [
  "catfact"
];
