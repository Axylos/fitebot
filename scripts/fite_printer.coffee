Table = require 'cli-table2'
util = require 'util'

print_fites = (fites) ->
    config = {
        head: ['ID', 'Left', '', 'Right'],
        colWidths: [5, 40, 5, 40]

    }
    table = new Table(config)

    fites.forEach (fite) ->
        table.push([fite.rank, fmt_fiter(fite, 'left'), 'VS', fmt_fiter(fite, 'right')])

    "```" + table.toString() + "```"


print_pending_fites = (fites) ->
    config = {
        head: ['Left', 'Right'],
        colWidths: [40, 40]

    }
    table = new Table(config)

    fites.forEach (fite) ->
        table.push([fite.left_fiter, fite.right_fiter])

    "```" + table.toString() + "```"

fmt_fiter = (fite, pos) ->
    if pos == 'left'
        choice = 'left_fiter'
    else
        choice = 'right_fiter'
    resp = util.format("%s (%d)", fite[choice], fite.vote_count)
    resp

module.exports = {
    print_pending_fites: print_pending_fites
    print_fites: print_fites
}
