module.exports = function(robot) {

  robot.hear(/new one/i,  function(res) {
      res.reply("it fucking worked");
  })
}
