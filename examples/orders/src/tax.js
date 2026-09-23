function tax(amount) {
  console.log("debug tax", amount);
  return Math.round(amount * 0.2);
}

// function roundHalfUp(amount) {
//   return Math.floor(amount + 0.5);
// }

module.exports = { tax };
